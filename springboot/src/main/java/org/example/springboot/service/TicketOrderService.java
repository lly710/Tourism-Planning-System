package org.example.springboot.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import jakarta.annotation.Resource;
import org.apache.commons.lang3.StringUtils;
import org.example.springboot.entity.ScenicSpot;
import org.example.springboot.entity.Ticket;
import org.example.springboot.entity.TicketOrder;
import org.example.springboot.entity.User;
import org.example.springboot.exception.ServiceException;
import org.example.springboot.mapper.ScenicSpotMapper;
import org.example.springboot.mapper.TicketMapper;
import org.example.springboot.mapper.TicketOrderMapper;
import org.example.springboot.mapper.UserMapper;
import org.example.springboot.util.JwtTokenUtils;
import org.example.springboot.util.RedisLockUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class TicketOrderService {

    private static final Logger logger = LoggerFactory.getLogger(TicketOrderService.class);
    private static final long CREATE_ORDER_LOCK_EXPIRE_SECONDS = 10L;

    @Resource
    private TicketOrderMapper ticketOrderMapper;

    @Resource
    private TicketMapper ticketMapper;

    @Resource
    private ScenicSpotMapper scenicSpotMapper;

    @Resource
    private UserMapper userMapper;

    @Resource
    private TicketService ticketService;

    @Resource
    private EmailService emailService;

    @Resource
    private RedisLockUtil redisLockUtil;

    @Transactional
    public TicketOrder createOrder(TicketOrder order) {
        User currentUser = JwtTokenUtils.getCurrentUser();
        if (currentUser == null) {
            throw new ServiceException("用户未登录");
        }
        if (order == null || order.getTicketId() == null) {
            throw new ServiceException("门票信息不能为空");
        }
        if (order.getQuantity() == null || order.getQuantity() <= 0) {
            throw new ServiceException("购票数量必须大于 0");
        }

        String lockKey = "ticket:order:" + order.getTicketId();
        String lockValue = redisLockUtil.tryLock(lockKey, CREATE_ORDER_LOCK_EXPIRE_SECONDS);
        if (lockValue == null) {
            throw new ServiceException("当前购票人数较多，请稍后重试");
        }

        try {
            order.setUserId(currentUser.getId());

            Ticket ticket = ticketMapper.selectById(order.getTicketId());
            if (ticket == null) {
                throw new ServiceException("门票不存在");
            }
            if (ticket.getStatus() == null || ticket.getStatus() != 1) {
                throw new ServiceException("该门票暂不可预订");
            }

            order.setOrderNo(generateOrderNo());
            order.setStatus(0);
            order.setTotalAmount(resolveOrderAmount(ticket, order.getQuantity()));

            // 先原子扣库存，再落订单，避免高并发下超卖。
            ticketService.updateTicketStock(order.getTicketId(), order.getQuantity());
            ticketOrderMapper.insert(order);

            try {
                sendOrderMessage(order, "create");
            } catch (Exception e) {
                logger.error("发送订单创建消息失败，但订单已创建成功。订单号：{}，错误：{}", order.getOrderNo(), e.getMessage(), e);
            }

            return order;
        } finally {
            redisLockUtil.releaseLock(lockKey, lockValue);
        }
    }

    @Transactional
    public void payOrder(Long orderId, String paymentMethod) {
        TicketOrder order = ticketOrderMapper.selectById(orderId);
        if (order == null) {
            throw new ServiceException("订单不存在");
        }
        if (order.getStatus() == null || order.getStatus() != 0) {
            throw new ServiceException("订单状态不正确，无法支付");
        }

        order.setStatus(1);
        order.setPaymentMethod(paymentMethod);
        order.setPaymentTime(LocalDateTime.now());
        ticketOrderMapper.updateById(order);

        try {
            sendOrderMessage(order, "pay");
        } catch (Exception e) {
            logger.error("发送订单支付消息失败，但订单状态已更新成功。订单号：{}，错误：{}", order.getOrderNo(), e.getMessage(), e);
        }
    }

    @Transactional
    public void cancelOrder(Long orderId) {
        User currentUser = JwtTokenUtils.getCurrentUser();
        if (currentUser == null) {
            throw new ServiceException("用户未登录");
        }

        TicketOrder order = ticketOrderMapper.selectById(orderId);
        if (order == null) {
            throw new ServiceException("订单不存在");
        }
        if (!order.getUserId().equals(currentUser.getId()) && !"ADMIN".equals(currentUser.getRoleCode())) {
            throw new ServiceException("无权操作此订单");
        }
        if (order.getStatus() == null || order.getStatus() != 0) {
            throw new ServiceException("只有待支付的订单可以取消");
        }

        order.setStatus(2);
        ticketOrderMapper.updateById(order);
        ticketService.restoreTicketStock(order.getTicketId(), order.getQuantity());

        try {
            sendOrderMessage(order, "cancel");
        } catch (Exception e) {
            logger.error("发送订单取消消息失败，但订单已取消成功。订单号：{}，错误：{}", order.getOrderNo(), e.getMessage(), e);
        }
    }

    @Transactional
    public void refundOrder(Long orderId) {
        User currentUser = JwtTokenUtils.getCurrentUser();
        if (currentUser == null) {
            throw new ServiceException("用户未登录");
        }

        TicketOrder order = ticketOrderMapper.selectById(orderId);
        if (order == null) {
            throw new ServiceException("订单不存在");
        }
        if (!"ADMIN".equals(currentUser.getRoleCode())) {
            throw new ServiceException("无权执行退款操作");
        }
        if (order.getStatus() == null || order.getStatus() != 1) {
            throw new ServiceException("只有已支付的订单可以退款");
        }

        order.setStatus(3);
        ticketOrderMapper.updateById(order);
        ticketService.restoreTicketStock(order.getTicketId(), order.getQuantity());

        try {
            sendOrderMessage(order, "refund");
        } catch (Exception e) {
            logger.error("发送订单退款消息失败，但订单已退款成功。订单号：{}，错误：{}", order.getOrderNo(), e.getMessage(), e);
        }
    }

    @Transactional
    public void completeOrder(Long orderId) {
        User currentUser = JwtTokenUtils.getCurrentUser();
        if (currentUser == null) {
            throw new ServiceException("用户未登录");
        }

        TicketOrder order = ticketOrderMapper.selectById(orderId);
        if (order == null) {
            throw new ServiceException("订单不存在");
        }
        if (!"ADMIN".equals(currentUser.getRoleCode())) {
            throw new ServiceException("无权执行此操作");
        }
        if (order.getStatus() == null || order.getStatus() != 1) {
            throw new ServiceException("只有已支付的订单可以标记为已完成");
        }

        order.setStatus(4);
        ticketOrderMapper.updateById(order);

        try {
            sendOrderMessage(order, "complete");
        } catch (Exception e) {
            logger.error("发送订单完成消息失败，但订单已完成成功。订单号：{}，错误：{}", order.getOrderNo(), e.getMessage(), e);
        }
    }

    public Page<TicketOrder> getUserOrders(Long userId, Integer status, Integer currentPage, Integer size) {
        LambdaQueryWrapper<TicketOrder> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(TicketOrder::getUserId, userId);
        if (status != null) {
            queryWrapper.eq(TicketOrder::getStatus, status);
        }
        queryWrapper.orderByDesc(TicketOrder::getCreateTime);

        Page<TicketOrder> page = ticketOrderMapper.selectPage(new Page<>(currentPage, size), queryWrapper);
        for (TicketOrder order : page.getRecords()) {
            fillOrderDetails(order);
        }
        return page;
    }

    public Page<TicketOrder> getAllOrders(String orderNo, String visitorName, String visitorPhone, Integer status,
                                          Integer currentPage, Integer size) {
        LambdaQueryWrapper<TicketOrder> queryWrapper = new LambdaQueryWrapper<>();
        if (StringUtils.isNotBlank(orderNo)) {
            queryWrapper.like(TicketOrder::getOrderNo, orderNo);
        }
        if (StringUtils.isNotBlank(visitorName)) {
            queryWrapper.like(TicketOrder::getVisitorName, visitorName);
        }
        if (StringUtils.isNotBlank(visitorPhone)) {
            queryWrapper.like(TicketOrder::getVisitorPhone, visitorPhone);
        }
        if (status != null) {
            queryWrapper.eq(TicketOrder::getStatus, status);
        }
        queryWrapper.orderByDesc(TicketOrder::getCreateTime);

        Page<TicketOrder> page = ticketOrderMapper.selectPage(new Page<>(currentPage, size), queryWrapper);
        for (TicketOrder order : page.getRecords()) {
            fillOrderDetails(order);
        }
        return page;
    }

    public TicketOrder getOrderDetail(Long orderId) {
        TicketOrder order = ticketOrderMapper.selectById(orderId);
        if (order == null) {
            throw new ServiceException("订单不存在");
        }
        fillOrderDetails(order);
        return order;
    }

    private void fillOrderDetails(TicketOrder order) {
        Ticket ticket = ticketMapper.selectById(order.getTicketId());
        if (ticket != null) {
            order.setTicketName(ticket.getTicketName());
            ScenicSpot scenicSpot = scenicSpotMapper.selectById(ticket.getScenicId());
            if (scenicSpot != null) {
                order.setScenicName(scenicSpot.getName());
            }
        }

        User user = userMapper.selectById(order.getUserId());
        if (user != null) {
            order.setUsername(user.getUsername());
        }
    }

    private String generateOrderNo() {
        String dateStr = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        String randomStr = UUID.randomUUID().toString().replace("-", "").substring(0, 4);
        return dateStr + randomStr;
    }

    private BigDecimal resolveOrderAmount(Ticket ticket, Integer quantity) {
        BigDecimal unitPrice = ticket.getDiscountPrice() != null ? ticket.getDiscountPrice() : ticket.getPrice();
        return unitPrice.multiply(BigDecimal.valueOf(quantity));
    }

    public TicketOrder getOrderByOrderNo(String orderNo) {
        if (StringUtils.isBlank(orderNo)) {
            return null;
        }

        LambdaQueryWrapper<TicketOrder> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(TicketOrder::getOrderNo, orderNo);
        TicketOrder order = ticketOrderMapper.selectOne(queryWrapper);
        if (order != null) {
            fillOrderDetails(order);
        }
        return order;
    }

    @Transactional
    public void deleteOrder(Long orderId) {
        User currentUser = JwtTokenUtils.getCurrentUser();
        if (currentUser == null) {
            throw new ServiceException("用户未登录");
        }

        TicketOrder order = ticketOrderMapper.selectById(orderId);
        if (order == null) {
            throw new ServiceException("订单不存在");
        }

        boolean isAdmin = "ADMIN".equals(currentUser.getRoleCode());
        if (!order.getUserId().equals(currentUser.getId()) && !isAdmin) {
            throw new ServiceException("无权操作此订单");
        }

        if (order.getStatus() == null || (order.getStatus() != 2 && order.getStatus() != 3 && order.getStatus() != 4)) {
            throw new ServiceException("只有已完成、已退款或已取消的订单可以删除");
        }

        ticketOrderMapper.deleteById(orderId);
    }

    private void sendOrderMessage(TicketOrder order, String eventType) {
        try {
            logger.info("订单事件：{}，订单号：{}，状态：{}", eventType, order.getOrderNo(), order.getStatus());

            switch (eventType) {
                case "create":
                    logger.info("订单创建通知：订单号 {} 已创建", order.getOrderNo());
                    break;
                case "pay":
                    logger.info("订单支付通知：订单号 {} 已支付", order.getOrderNo());
                    break;
                case "cancel":
                    logger.info("订单取消通知：订单号 {} 已取消", order.getOrderNo());
                    break;
                case "refund":
                    logger.info("订单退款通知：订单号 {} 已退款", order.getOrderNo());
                    break;
                case "complete":
                    logger.info("订单完成通知：订单号 {} 已完成", order.getOrderNo());
                    break;
                default:
                    logger.info("订单通知：订单号 {} 事件 {}", order.getOrderNo(), eventType);
                    break;
            }
        } catch (Exception e) {
            logger.error("发送订单消息失败，但订单处理继续：{}", e.getMessage(), e);
        }
    }

    private void sendOrderNotificationEmail(TicketOrder order, String subject, String content) {
        logger.info("邮件通知（已禁用）：订单号 {}，主题：{}，内容：{}", order.getOrderNo(), subject, content);
    }

    public Map<String, Object> getUserOrderStats(Long userId) {
        LambdaQueryWrapper<TicketOrder> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(TicketOrder::getUserId, userId);

        List<TicketOrder> allOrders = ticketOrderMapper.selectList(queryWrapper);
        Map<String, Object> stats = new HashMap<>();
        stats.put("total", allOrders.size());
        stats.put("pending", 0);
        stats.put("paid", 0);
        stats.put("cancelled", 0);
        stats.put("refunded", 0);
        stats.put("completed", 0);

        for (TicketOrder order : allOrders) {
            switch (order.getStatus()) {
                case 0:
                    stats.put("pending", (Integer) stats.get("pending") + 1);
                    break;
                case 1:
                    stats.put("paid", (Integer) stats.get("paid") + 1);
                    break;
                case 2:
                    stats.put("cancelled", (Integer) stats.get("cancelled") + 1);
                    break;
                case 3:
                    stats.put("refunded", (Integer) stats.get("refunded") + 1);
                    break;
                case 4:
                    stats.put("completed", (Integer) stats.get("completed") + 1);
                    break;
                default:
                    break;
            }
        }

        return stats;
    }

    private String getOrderStatusText(Integer status) {
        switch (status) {
            case 0:
                return "待支付";
            case 1:
                return "已支付";
            case 2:
                return "已取消";
            case 3:
                return "已退款";
            case 4:
                return "已完成";
            default:
                return "未知状态";
        }
    }
}
