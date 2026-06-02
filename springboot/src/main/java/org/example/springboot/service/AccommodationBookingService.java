package org.example.springboot.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import jakarta.annotation.Resource;
import org.apache.commons.lang3.StringUtils;
import org.example.springboot.entity.Accommodation;
import org.example.springboot.entity.AccommodationBooking;
import org.example.springboot.entity.AccommodationRoomType;
import org.example.springboot.entity.User;
import org.example.springboot.exception.ServiceException;
import org.example.springboot.mapper.AccommodationBookingMapper;
import org.example.springboot.mapper.AccommodationMapper;
import org.example.springboot.mapper.AccommodationRoomTypeMapper;
import org.example.springboot.mapper.UserMapper;
import org.example.springboot.util.JwtTokenUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class AccommodationBookingService {

    @Resource
    private AccommodationBookingMapper accommodationBookingMapper;

    @Resource
    private AccommodationMapper accommodationMapper;

    @Resource
    private AccommodationRoomTypeMapper accommodationRoomTypeMapper;

    @Resource
    private UserMapper userMapper;

    @Transactional
    public AccommodationBooking createBooking(AccommodationBooking booking) {
        User currentUser = JwtTokenUtils.getCurrentUser();
        if (currentUser == null) {
            throw new ServiceException("用户未登录");
        }

        validateBookingParams(booking);
        AccommodationRoomType roomType = loadAndValidateRoomType(booking.getRoomTypeId());
        Accommodation accommodation = loadAndValidateAccommodation(roomType, booking.getAccommodationId());

        int availableRooms = getAvailableRooms(roomType.getId(), booking.getCheckInDate(), booking.getCheckOutDate(), null);
        if (availableRooms < booking.getRooms()) {
            throw new ServiceException("当前房型余量不足，可预订房间数：" + Math.max(availableRooms, 0));
        }

        booking.setUserId(currentUser.getId());
        booking.setAccommodationId(accommodation.getId());
        booking.setOrderNo(generateOrderNo());
        booking.setStatus(0);
        booking.setPaymentMethod(null);
        booking.setPaymentTime(null);

        int nights = calculateNights(booking.getCheckInDate(), booking.getCheckOutDate());
        booking.setNights(nights);
        booking.setTotalAmount(calculateTotalAmount(roomType, booking.getRooms(), nights));

        accommodationBookingMapper.insert(booking);
        fillBookingDetails(booking);
        booking.setAvailableRooms(Math.max(availableRooms - booking.getRooms(), 0));
        return booking;
    }

    @Transactional
    public void payBooking(Long bookingId, String paymentMethod) {
        AccommodationBooking booking = getOwnedBookingForWrite(bookingId, false);
        if (booking.getStatus() != 0) {
            throw new ServiceException("只有待支付订单可以支付");
        }
        if (StringUtils.isBlank(paymentMethod)) {
            throw new ServiceException("支付方式不能为空");
        }
        booking.setStatus(1);
        booking.setPaymentMethod(paymentMethod);
        booking.setPaymentTime(java.time.LocalDateTime.now());
        accommodationBookingMapper.updateById(booking);
    }

    @Transactional
    public void cancelBooking(Long bookingId) {
        AccommodationBooking booking = getOwnedBookingForWrite(bookingId, false);
        if (booking.getStatus() != 0) {
            throw new ServiceException("只有待支付订单可以取消");
        }
        booking.setStatus(2);
        accommodationBookingMapper.updateById(booking);
    }

    @Transactional
    public void refundBooking(Long bookingId) {
        AccommodationBooking booking = getOwnedBookingForWrite(bookingId, true);
        if (booking.getStatus() != 1) {
            throw new ServiceException("只有已支付订单可以退款");
        }
        booking.setStatus(3);
        accommodationBookingMapper.updateById(booking);
    }

    @Transactional
    public void completeBooking(Long bookingId) {
        AccommodationBooking booking = getOwnedBookingForWrite(bookingId, true);
        if (booking.getStatus() != 1) {
            throw new ServiceException("只有已支付订单可以完成");
        }
        booking.setStatus(4);
        accommodationBookingMapper.updateById(booking);
    }

    public Page<AccommodationBooking> getUserBookings(Long userId, Integer status, Integer currentPage, Integer size) {
        LambdaQueryWrapper<AccommodationBooking> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(AccommodationBooking::getUserId, userId);
        if (status != null) {
            queryWrapper.eq(AccommodationBooking::getStatus, status);
        }
        queryWrapper.orderByDesc(AccommodationBooking::getCreateTime);
        Page<AccommodationBooking> page = accommodationBookingMapper.selectPage(new Page<>(currentPage, size), queryWrapper);
        page.getRecords().forEach(this::fillBookingDetails);
        return page;
    }

    public Page<AccommodationBooking> getAllBookings(String orderNo, String guestName, String guestPhone, Integer status,
                                                     Integer currentPage, Integer size) {
        LambdaQueryWrapper<AccommodationBooking> queryWrapper = new LambdaQueryWrapper<>();
        if (StringUtils.isNotBlank(orderNo)) {
            queryWrapper.like(AccommodationBooking::getOrderNo, orderNo);
        }
        if (StringUtils.isNotBlank(guestName)) {
            queryWrapper.like(AccommodationBooking::getGuestName, guestName);
        }
        if (StringUtils.isNotBlank(guestPhone)) {
            queryWrapper.like(AccommodationBooking::getGuestPhone, guestPhone);
        }
        if (status != null) {
            queryWrapper.eq(AccommodationBooking::getStatus, status);
        }
        queryWrapper.orderByDesc(AccommodationBooking::getCreateTime);
        Page<AccommodationBooking> page = accommodationBookingMapper.selectPage(new Page<>(currentPage, size), queryWrapper);
        page.getRecords().forEach(this::fillBookingDetails);
        return page;
    }

    public AccommodationBooking getBookingDetail(Long bookingId) {
        AccommodationBooking booking = accommodationBookingMapper.selectById(bookingId);
        if (booking == null) {
            throw new ServiceException("订单不存在");
        }
        fillBookingDetails(booking);
        return booking;
    }

    public AccommodationBooking getBookingByOrderNo(String orderNo) {
        if (StringUtils.isBlank(orderNo)) {
            return null;
        }
        LambdaQueryWrapper<AccommodationBooking> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(AccommodationBooking::getOrderNo, orderNo);
        AccommodationBooking booking = accommodationBookingMapper.selectOne(queryWrapper);
        if (booking != null) {
            fillBookingDetails(booking);
        }
        return booking;
    }

    @Transactional
    public void deleteBooking(Long bookingId) {
        AccommodationBooking booking = getOwnedBookingForWrite(bookingId, false);
        if (booking.getStatus() != 2 && booking.getStatus() != 3 && booking.getStatus() != 4) {
            throw new ServiceException("只有已取消、已退款或已完成订单可以删除");
        }
        accommodationBookingMapper.deleteById(bookingId);
    }

    public Map<String, Object> getUserBookingStats(Long userId) {
        LambdaQueryWrapper<AccommodationBooking> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(AccommodationBooking::getUserId, userId);
        List<AccommodationBooking> bookings = accommodationBookingMapper.selectList(queryWrapper);
        return buildStats(bookings);
    }

    public Map<String, Object> getAdminBookingStats() {
        List<AccommodationBooking> bookings = accommodationBookingMapper.selectList(null);
        return buildStats(bookings);
    }

    public Map<String, Object> checkAvailability(Long roomTypeId, LocalDate checkInDate, LocalDate checkOutDate) {
        if (roomTypeId == null) {
            throw new ServiceException("房型ID不能为空");
        }
        if (checkInDate == null || checkOutDate == null) {
            throw new ServiceException("入住和离店日期不能为空");
        }
        if (!checkOutDate.isAfter(checkInDate)) {
            throw new ServiceException("离店日期必须晚于入住日期");
        }
        AccommodationRoomType roomType = loadAndValidateRoomType(roomTypeId);
        int availableRooms = getAvailableRooms(roomTypeId, checkInDate, checkOutDate, null);
        Map<String, Object> result = new HashMap<>();
        result.put("roomTypeId", roomTypeId);
        result.put("roomName", roomType.getRoomName());
        result.put("checkInDate", checkInDate);
        result.put("checkOutDate", checkOutDate);
        result.put("totalRooms", roomType.getTotalRooms());
        result.put("availableRooms", availableRooms);
        result.put("bookable", availableRooms > 0);
        return result;
    }

    private AccommodationBooking getOwnedBookingForWrite(Long bookingId, boolean adminOnly) {
        User currentUser = JwtTokenUtils.getCurrentUser();
        if (currentUser == null) {
            throw new ServiceException("用户未登录");
        }
        AccommodationBooking booking = accommodationBookingMapper.selectById(bookingId);
        if (booking == null) {
            throw new ServiceException("订单不存在");
        }
        boolean isAdmin = "ADMIN".equals(currentUser.getRoleCode());
        if (adminOnly && !isAdmin) {
            throw new ServiceException("无权限执行该操作");
        }
        if (!adminOnly && !booking.getUserId().equals(currentUser.getId()) && !isAdmin) {
            throw new ServiceException("无权限操作此订单");
        }
        return booking;
    }

    private void validateBookingParams(AccommodationBooking booking) {
        if (booking == null) {
            throw new ServiceException("订单参数不能为空");
        }
        if (booking.getRoomTypeId() == null) {
            throw new ServiceException("房型ID不能为空");
        }
        if (booking.getCheckInDate() == null || booking.getCheckOutDate() == null) {
            throw new ServiceException("入住和离店日期不能为空");
        }
        if (!booking.getCheckOutDate().isAfter(booking.getCheckInDate())) {
            throw new ServiceException("离店日期必须晚于入住日期");
        }
        if (booking.getRooms() == null || booking.getRooms() <= 0) {
            throw new ServiceException("预订房间数量必须大于0");
        }
        if (StringUtils.isBlank(booking.getGuestName())) {
            throw new ServiceException("入住人姓名不能为空");
        }
        if (StringUtils.isBlank(booking.getGuestPhone())) {
            throw new ServiceException("入住人手机号不能为空");
        }
    }

    private AccommodationRoomType loadAndValidateRoomType(Long roomTypeId) {
        AccommodationRoomType roomType = accommodationRoomTypeMapper.selectById(roomTypeId);
        if (roomType == null) {
            throw new ServiceException("房型不存在");
        }
        if (roomType.getStatus() == null || roomType.getStatus() != 1) {
            throw new ServiceException("当前房型不可预订");
        }
        if (roomType.getTotalRooms() == null || roomType.getTotalRooms() <= 0) {
            throw new ServiceException("当前房型库存不足");
        }
        return roomType;
    }

    private Accommodation loadAndValidateAccommodation(AccommodationRoomType roomType, Long accommodationId) {
        Long realAccommodationId = roomType.getAccommodationId();
        if (accommodationId != null && !accommodationId.equals(realAccommodationId)) {
            throw new ServiceException("房型与住宿信息不匹配");
        }
        Accommodation accommodation = accommodationMapper.selectById(realAccommodationId);
        if (accommodation == null) {
            throw new ServiceException("住宿不存在");
        }
        return accommodation;
    }

    private int getAvailableRooms(Long roomTypeId, LocalDate checkInDate, LocalDate checkOutDate, Long excludeBookingId) {
        AccommodationRoomType roomType = accommodationRoomTypeMapper.selectById(roomTypeId);
        if (roomType == null) {
            throw new ServiceException("房型不存在");
        }
        Integer bookedRooms = accommodationBookingMapper.sumBookedRooms(roomTypeId, checkInDate, checkOutDate, excludeBookingId);
        int totalRooms = roomType.getTotalRooms() == null ? 0 : roomType.getTotalRooms();
        return Math.max(totalRooms - (bookedRooms == null ? 0 : bookedRooms), 0);
    }

    private int calculateNights(LocalDate checkInDate, LocalDate checkOutDate) {
        return (int) ChronoUnit.DAYS.between(checkInDate, checkOutDate);
    }

    private BigDecimal calculateTotalAmount(AccommodationRoomType roomType, Integer rooms, int nights) {
        BigDecimal unitPrice = roomType.getDiscountPrice() != null ? roomType.getDiscountPrice() : roomType.getPrice();
        if (unitPrice == null) {
            throw new ServiceException("房型价格未配置");
        }
        return unitPrice.multiply(BigDecimal.valueOf(rooms.longValue()))
                .multiply(BigDecimal.valueOf(nights));
    }

    private void fillBookingDetails(AccommodationBooking booking) {
        Accommodation accommodation = accommodationMapper.selectById(booking.getAccommodationId());
        if (accommodation != null) {
            booking.setAccommodationName(accommodation.getName());
        }

        AccommodationRoomType roomType = accommodationRoomTypeMapper.selectById(booking.getRoomTypeId());
        if (roomType != null) {
            booking.setRoomName(roomType.getRoomName());
            booking.setAvailableRooms(getAvailableRooms(roomType.getId(), booking.getCheckInDate(), booking.getCheckOutDate(), booking.getId()));
        }

        User user = userMapper.selectById(booking.getUserId());
        if (user != null) {
            booking.setUsername(user.getUsername());
        }
    }

    private Map<String, Object> buildStats(List<AccommodationBooking> bookings) {
        Map<String, Object> stats = new HashMap<>();
        stats.put("total", bookings.size());
        stats.put("pending", 0);
        stats.put("paid", 0);
        stats.put("cancelled", 0);
        stats.put("refunded", 0);
        stats.put("completed", 0);
        BigDecimal totalAmount = BigDecimal.ZERO;

        for (AccommodationBooking booking : bookings) {
            totalAmount = totalAmount.add(booking.getTotalAmount() == null ? BigDecimal.ZERO : booking.getTotalAmount());
            if (booking.getStatus() == null) {
                continue;
            }
            switch (booking.getStatus()) {
                case 0 -> stats.put("pending", (Integer) stats.get("pending") + 1);
                case 1 -> stats.put("paid", (Integer) stats.get("paid") + 1);
                case 2 -> stats.put("cancelled", (Integer) stats.get("cancelled") + 1);
                case 3 -> stats.put("refunded", (Integer) stats.get("refunded") + 1);
                case 4 -> stats.put("completed", (Integer) stats.get("completed") + 1);
                default -> {
                }
            }
        }
        stats.put("totalAmount", totalAmount);
        return stats;
    }

    private String generateOrderNo() {
        String dateStr = java.time.LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        String randomStr = UUID.randomUUID().toString().replace("-", "").substring(0, 6);
        return "HTL" + dateStr + randomStr.toUpperCase();
    }
}
