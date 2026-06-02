package org.example.springboot.service;

import jakarta.annotation.Resource;
import org.example.springboot.entity.TicketOrder;
import org.example.springboot.exception.ServiceException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

@Service
public class AlipayService {
    private static final Logger LOGGER = LoggerFactory.getLogger(AlipayService.class);

    @Resource
    private TicketOrderService ticketOrderService;

    /**
     * 生成模拟支付宝支付表单
     */
    public String createMockAlipayForm(Long orderId) {
        TicketOrder order = ticketOrderService.getOrderDetail(orderId);
        if (order == null) {
            throw new ServiceException("订单不存在");
        }

        LOGGER.info("生成模拟支付宝支付表单，订单ID: {}, 订单号: {}", orderId, order.getOrderNo());
        return "<div style='text-align: center; padding: 50px;'>正在加载支付页面...</div>";
    }

    /**
     * 模拟支付宝支付
     */
    public void mockAlipayPayment(Long orderId) {
        LOGGER.info("开始处理模拟支付宝支付，订单ID: {}", orderId);

        TicketOrder order = ticketOrderService.getOrderDetail(orderId);
        if (order == null) {
            throw new ServiceException("订单不存在");
        }

        if (order.getStatus() == 1) {
            LOGGER.info("订单已支付，无需重复处理");
            return;
        }

        if (order.getStatus() != 0) {
            throw new ServiceException("订单状态异常，无法支付");
        }

        try {
            Thread.sleep(1000);
            ticketOrderService.payOrder(orderId, "ALIPAY");
            LOGGER.info("模拟支付宝支付成功，订单ID: {}, 订单号: {}", orderId, order.getOrderNo());
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new ServiceException("支付处理被中断");
        } catch (Exception e) {
            LOGGER.error("模拟支付宝支付失败，订单ID: {}, 错误: {}", orderId, e.getMessage(), e);
            throw new ServiceException("支付处理失败: " + e.getMessage());
        }
    }
}
