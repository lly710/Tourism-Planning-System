package org.example.springboot.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.annotation.Resource;
import org.example.springboot.common.Result;
import org.example.springboot.entity.AccommodationBooking;
import org.example.springboot.entity.User;
import org.example.springboot.service.AccommodationBookingService;
import org.example.springboot.util.JwtTokenUtils;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.Map;

@Tag(name = "住宿订单管理接口")
@RestController
@RequestMapping("/accommodation/booking")
public class AccommodationBookingController {

    @Resource
    private AccommodationBookingService accommodationBookingService;

    @Operation(summary = "创建住宿订单")
    @PostMapping
    public Result<?> createBooking(@RequestBody AccommodationBooking booking) {
        return Result.success(accommodationBookingService.createBooking(booking));
    }

    @Operation(summary = "支付住宿订单")
    @PostMapping("/{id}/pay")
    public Result<?> payBooking(@PathVariable Long id, @RequestParam String paymentMethod) {
        accommodationBookingService.payBooking(id, paymentMethod);
        return Result.success();
    }

    @Operation(summary = "取消住宿订单")
    @PostMapping("/{id}/cancel")
    public Result<?> cancelBooking(@PathVariable Long id) {
        accommodationBookingService.cancelBooking(id);
        return Result.success();
    }

    @Operation(summary = "退款住宿订单（管理员）")
    @PostMapping("/{id}/refund")
    public Result<?> refundBooking(@PathVariable Long id) {
        accommodationBookingService.refundBooking(id);
        return Result.success();
    }

    @Operation(summary = "完成住宿订单（管理员）")
    @PostMapping("/{id}/complete")
    public Result<?> completeBooking(@PathVariable Long id) {
        accommodationBookingService.completeBooking(id);
        return Result.success();
    }

    @Operation(summary = "获取当前用户住宿订单列表")
    @GetMapping("/my")
    public Result<?> getMyBookings(@RequestParam(required = false) Integer status,
                                   @RequestParam(defaultValue = "1") Integer currentPage,
                                   @RequestParam(defaultValue = "10") Integer size) {
        User currentUser = JwtTokenUtils.getCurrentUser();
        if (currentUser == null) {
            return Result.error("用户未登录");
        }
        Page<AccommodationBooking> page = accommodationBookingService.getUserBookings(currentUser.getId(), status, currentPage, size);
        return Result.success(page);
    }

    @Operation(summary = "获取住宿订单详情")
    @GetMapping("/{id}")
    public Result<?> getBookingDetail(@PathVariable Long id) {
        return Result.success(accommodationBookingService.getBookingDetail(id));
    }

    @Operation(summary = "根据订单号查询住宿订单")
    @GetMapping("/status")
    public Result<?> getBookingByOrderNo(@RequestParam String orderNo) {
        AccommodationBooking booking = accommodationBookingService.getBookingByOrderNo(orderNo);
        if (booking == null) {
            return Result.error("订单不存在");
        }
        return Result.success(booking);
    }

    @Operation(summary = "管理员分页查询住宿订单")
    @GetMapping("/admin/page")
    public Result<?> getAllBookings(@RequestParam(defaultValue = "") String orderNo,
                                    @RequestParam(defaultValue = "") String guestName,
                                    @RequestParam(defaultValue = "") String guestPhone,
                                    @RequestParam(required = false) Integer status,
                                    @RequestParam(defaultValue = "1") Integer currentPage,
                                    @RequestParam(defaultValue = "10") Integer size) {
        User currentUser = JwtTokenUtils.getCurrentUser();
        if (currentUser == null || !"ADMIN".equals(currentUser.getRoleCode())) {
            return Result.error("无权限访问");
        }
        Page<AccommodationBooking> page = accommodationBookingService.getAllBookings(
                orderNo, guestName, guestPhone, status, currentPage, size);
        return Result.success(page);
    }

    @Operation(summary = "当前用户住宿订单统计")
    @GetMapping("/my/stats")
    public Result<?> getMyBookingStats() {
        User currentUser = JwtTokenUtils.getCurrentUser();
        if (currentUser == null) {
            return Result.error("用户未登录");
        }
        return Result.success(accommodationBookingService.getUserBookingStats(currentUser.getId()));
    }

    @Operation(summary = "管理员查看住宿订单统计")
    @GetMapping("/stats")
    public Result<?> getBookingStats() {
        User currentUser = JwtTokenUtils.getCurrentUser();
        if (currentUser == null || !"ADMIN".equals(currentUser.getRoleCode())) {
            return Result.error("无权限访问");
        }
        Map<String, Object> stats = accommodationBookingService.getAdminBookingStats();
        return Result.success(stats);
    }

    @Operation(summary = "查询房型在指定日期区间的可订余量")
    @GetMapping("/check-availability")
    public Result<?> checkAvailability(@RequestParam Long roomTypeId,
                                       @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate checkInDate,
                                       @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate checkOutDate) {
        return Result.success(accommodationBookingService.checkAvailability(roomTypeId, checkInDate, checkOutDate));
    }

    @Operation(summary = "删除住宿订单")
    @DeleteMapping("/{id}")
    public Result<?> deleteBooking(@PathVariable Long id) {
        accommodationBookingService.deleteBooking(id);
        return Result.success("订单删除成功");
    }
}
