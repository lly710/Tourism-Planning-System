package org.example.springboot.entity;


import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("accommodation_room_type")
@Schema(description = "住宿房型实体类")
public class AccommodationRoomType {

    @TableId(type = IdType.AUTO)
    @Schema(description = "房型 ID")
    private Long id;

    @Schema(description = "所属住宿 ID")
    private Long accommodationId;

    @Schema(description = "房型名称")
    private String roomName;

    @Schema(description = "房间面积（平方米）")
    private Integer roomArea;

    @Schema(description = "床型（大床/双床/多床）")
    private String bedType;

    @Schema(description = "最大入住人数")
    private Integer maxOccupancy;

    @Schema(description = "是否有窗：0-无，1-有")
    private Integer hasWindow;

    @Schema(description = "是否含早餐：0-不含，1-含")
    private Integer breakfast;

    @Schema(description = "参考价格（每晚）")
    private BigDecimal price;

    @Schema(description = "优惠价格")
    private BigDecimal discountPrice;

    @Schema(description = "该类型房间总数")
    private Integer totalRooms;

    @Schema(description = "房型描述")
    private String description;

    @Schema(description = "设施（如：WiFi,空调，电视等，逗号分隔）")
    private String facilities;

    @Schema(description = "房型图片 URL")
    private String imageUrl;

    @Schema(description = "状态：1-可预订，0-不可预订")
    private Integer status;

    @Schema(description = "创建时间")
    private LocalDateTime createTime;

    @Schema(description = "更新时间")
    private LocalDateTime updateTime;

    @TableField(exist = false)
    @Schema(description = "所属住宿名称")
    private String accommodationName;
}