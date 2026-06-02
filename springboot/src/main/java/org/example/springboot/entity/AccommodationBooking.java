package org.example.springboot.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.annotation.FieldStrategy;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("accommodation_booking")
@Schema(description = "住宿订单实体")
public class AccommodationBooking {

    @TableId(type = IdType.AUTO)
    @Schema(description = "订单ID")
    private Long id;

    @Schema(description = "订单编号")
    private String orderNo;

    @Schema(description = "用户ID")
    private Long userId;

    @Schema(description = "住宿ID")
    private Long accommodationId;

    @Schema(description = "房型ID")
    private Long roomTypeId;

    @Schema(description = "入住日期")
    private LocalDate checkInDate;

    @Schema(description = "离店日期")
    private LocalDate checkOutDate;

    @Schema(description = "入住晚数")
    @TableField(value = "nights", insertStrategy = FieldStrategy.NEVER, updateStrategy = FieldStrategy.NEVER)
    private Integer nights;

    @Schema(description = "预订房间数量")
    private Integer rooms;

    @Schema(description = "入住人姓名")
    private String guestName;

    @Schema(description = "入住人手机号")
    private String guestPhone;

    @Schema(description = "身份证号")
    private String idCard;

    @Schema(description = "订单总金额")
    private BigDecimal totalAmount;

    @Schema(description = "订单状态：0-待支付，1-已支付，2-已取消，3-已退款，4-已完成")
    private Integer status;

    @Schema(description = "支付时间")
    private LocalDateTime paymentTime;

    @Schema(description = "支付方式")
    private String paymentMethod;

    @Schema(description = "备注")
    private String remark;

    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @Schema(description = "更新时间")
    private LocalDateTime updateTime;

    @TableField(exist = false)
    @Schema(description = "住宿名称")
    private String accommodationName;

    @TableField(exist = false)
    @Schema(description = "房型名称")
    private String roomName;

    @TableField(exist = false)
    @Schema(description = "用户名")
    private String username;

    @TableField(exist = false)
    @Schema(description = "可订房间数")
    private Integer availableRooms;
}
