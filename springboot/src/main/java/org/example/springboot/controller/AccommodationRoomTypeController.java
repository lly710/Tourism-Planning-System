package org.example.springboot.controller;


import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.annotation.Resource;
import org.example.springboot.common.Result;
import org.example.springboot.entity.AccommodationRoomType;
import org.example.springboot.service.AccommodationRoomTypeService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "住宿房型接口")
@RestController
@RequestMapping("/accommodation/type")
public class AccommodationRoomTypeController {
    private static final Logger LOGGER = LoggerFactory.getLogger(AccommodationRoomTypeController.class);

    @Resource
    private AccommodationRoomTypeService accommodationRoomService;

    @Operation(summary = "分页查询房型列表")
    @GetMapping("/page")
    public Result<?> getRoomsByPage(
            @RequestParam(required = false) Long accommodationId,
            @RequestParam(required = false) String roomName,
            @RequestParam(required = false) String minPrice,
            @RequestParam(required = false) String maxPrice,
            @RequestParam(required = false) Integer status,
            @RequestParam(defaultValue = "1") Integer currentPage,
            @RequestParam(defaultValue = "10") Integer size) {

        try {
            LOGGER.info("分页查询房型列表，参数：accommodationId={}, roomName={}, price={}~{}, status={}, page={}, size={}",
                    accommodationId, roomName, minPrice, maxPrice, status, currentPage, size);

            Page<AccommodationRoomType> page = accommodationRoomService.getRoomsByPage(
                    accommodationId, roomName, minPrice, maxPrice, status, currentPage, size);

            return Result.success(page);
        } catch (Exception e) {
            LOGGER.error("查询房型列表失败", e);
            return Result.error("查询房型列表失败：" + e.getMessage());
        }
    }

    @Operation(summary = "获取房型详情")
    @GetMapping("/{id}")
    public Result<?> getRoomById(@PathVariable Long id) {
        try {
            LOGGER.info("获取房型详情，id={}", id);

            AccommodationRoomType room = accommodationRoomService.getRoomById(id);

            if (room == null) {
                return Result.error("房型信息不存在");
            }

            return Result.success(room);
        } catch (Exception e) {
            LOGGER.error("获取房型详情失败", e);
            return Result.error("获取房型详情失败：" + e.getMessage());
        }
    }

    @Operation(summary = "根据住宿 ID 获取可用房型")
    @GetMapping("/available/{accommodationId}")
    public Result<?> getAvailableRoomsByAccommodationId(@PathVariable Long accommodationId) {
        try {
            LOGGER.info("获取可用房型列表，accommodationId={}", accommodationId);

            List<AccommodationRoomType> rooms = accommodationRoomService.getAvailableRoomsByAccommodationId(accommodationId);

            return Result.success(rooms);
        } catch (Exception e) {
            LOGGER.error("获取可用房型列表失败", e);
            return Result.error("获取可用房型列表失败：" + e.getMessage());
        }
    }

    @Operation(summary = "添加房型信息")
    @PostMapping
    public Result<?> addRoom(@RequestBody AccommodationRoomType room) {
        try {
            LOGGER.info("添加房型信息：{}", room);

            boolean result = accommodationRoomService.addRoom(room);

            if (result) {
                return Result.success(room);
            } else {
                return Result.error("添加房型信息失败");
            }
        } catch (Exception e) {
            LOGGER.error("添加房型信息失败", e);
            return Result.error("添加房型信息失败：" + e.getMessage());
        }
    }

    @Operation(summary = "更新房型信息")
    @PutMapping("/{id}")
    public Result<?> updateRoom(@PathVariable Long id, @RequestBody AccommodationRoomType room) {
        try {
            LOGGER.info("更新房型信息，id={}，数据：{}", id, room);

            room.setId(id);
            boolean result = accommodationRoomService.updateRoom(room);

            if (result) {
                return Result.success(room);
            } else {
                return Result.error("更新房型信息失败");
            }
        } catch (Exception e) {
            LOGGER.error("更新房型信息失败", e);
            return Result.error("更新房型信息失败：" + e.getMessage());
        }
    }

    @Operation(summary = "删除房型信息")
    @DeleteMapping("/{id}")
    public Result<?> deleteRoom(@PathVariable Long id) {
        try {
            LOGGER.info("删除房型信息，id={}", id);

            boolean result = accommodationRoomService.deleteRoom(id);

            if (result) {
                return Result.success();
            } else {
                return Result.error("删除房型信息失败");
            }
        } catch (Exception e) {
            LOGGER.error("删除房型信息失败", e);
            return Result.error("删除房型信息失败：" + e.getMessage());
        }
    }
}
