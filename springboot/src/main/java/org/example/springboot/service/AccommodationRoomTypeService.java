package org.example.springboot.service;


import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.toolkit.StringUtils;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import jakarta.annotation.Resource;
import org.example.springboot.entity.Accommodation;
import org.example.springboot.entity.AccommodationRoomType;
import org.example.springboot.mapper.AccommodationMapper;
import org.example.springboot.mapper.AccommodationRoomTypeMapper;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class AccommodationRoomTypeService {
    @Resource
    private AccommodationRoomTypeMapper accommodationRoomMapper;

    @Resource
    private AccommodationMapper accommodationMapper;

    /**
     * 分页查询房型列表
     * @param accommodationId 住宿 ID
     * @param roomName 房型名称
     * @param minPrice 最低价格
     * @param maxPrice 最高价格
     * @param status 状态
     * @param currentPage 当前页码
     * @param size 每页记录数
     * @return 分页数据
     */
    public Page<AccommodationRoomType> getRoomsByPage(Long accommodationId, String roomName,
                                                      String minPrice, String maxPrice,
                                                      Integer status,
                                                      Integer currentPage, Integer size) {
        LambdaQueryWrapper<AccommodationRoomType> queryWrapper = new LambdaQueryWrapper<>();

        // 添加查询条件
        if (accommodationId != null) {
            queryWrapper.eq(AccommodationRoomType::getAccommodationId, accommodationId);
        }

        if (StringUtils.isNotBlank(roomName)) {
            queryWrapper.like(AccommodationRoomType::getRoomName, roomName);
        }

        if (StringUtils.isNotBlank(minPrice)) {
            queryWrapper.ge(AccommodationRoomType::getPrice, new BigDecimal(minPrice));
        }

        if (StringUtils.isNotBlank(maxPrice)) {
            queryWrapper.le(AccommodationRoomType::getPrice, new BigDecimal(maxPrice));
        }

        if (status != null) {
            queryWrapper.eq(AccommodationRoomType::getStatus, status);
        }

        // 按价格升序排序
        queryWrapper.orderByAsc(AccommodationRoomType::getPrice);

        Page<AccommodationRoomType> page = accommodationRoomMapper.selectPage(new Page<>(currentPage, size), queryWrapper);

        // 获取关联的住宿信息
        List<Long> accommodationIds = page.getRecords().stream()
                .map(AccommodationRoomType::getAccommodationId)
                .filter(id -> id != null)
                .collect(Collectors.toList());

        if (!accommodationIds.isEmpty()) {
            List<Accommodation> accommodations = accommodationMapper.selectBatchIds(accommodationIds);
            Map<Long, String> accommodationNameMap = accommodations.stream()
                    .collect(Collectors.toMap(Accommodation::getId, Accommodation::getName));

            // 设置关联的住宿名称
            page.getRecords().forEach(room -> {
                if (room.getAccommodationId() != null) {
                    room.setAccommodationName(accommodationNameMap.get(room.getAccommodationId()));
                }
            });
        }

        return page;
    }

    /**
     * 获取房型详情
     * @param id 房型 ID
     * @return 房型详情
     */
    public AccommodationRoomType getRoomById(Long id) {
        AccommodationRoomType room = accommodationRoomMapper.selectById(id);
        if (room != null && room.getAccommodationId() != null) {
            // 查询关联住宿信息
            Accommodation accommodation = accommodationMapper.selectById(room.getAccommodationId());
            if (accommodation != null) {
                room.setAccommodationName(accommodation.getName());
            }
        }
        return room;
    }

    /**
     * 根据住宿 ID 获取所有可用房型
     * @param accommodationId 住宿 ID
     * @return 房型列表
     */
    public List<AccommodationRoomType> getAvailableRoomsByAccommodationId(Long accommodationId) {
        LambdaQueryWrapper<AccommodationRoomType> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(AccommodationRoomType::getAccommodationId, accommodationId)
                .eq(AccommodationRoomType::getStatus, 1)
                .orderByAsc(AccommodationRoomType::getPrice);
        return accommodationRoomMapper.selectList(queryWrapper);
    }

    /**
     * 添加房型信息
     * @param room 房型信息
     * @return 是否成功
     */
    public boolean addRoom(AccommodationRoomType room) {
        return accommodationRoomMapper.insert(room) > 0;
    }

    /**
     * 更新房型信息
     * @param room 房型信息
     * @return 是否成功
     */
    public boolean updateRoom(AccommodationRoomType room) {
        return accommodationRoomMapper.updateById(room) > 0;
    }

    /**
     * 删除房型信息
     * @param id 房型 ID
     * @return 是否成功
     */
    public boolean deleteRoom(Long id) {
        return accommodationRoomMapper.deleteById(id) > 0;
    }
}
