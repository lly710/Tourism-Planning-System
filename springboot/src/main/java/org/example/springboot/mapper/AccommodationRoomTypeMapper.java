package org.example.springboot.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.example.springboot.entity.AccommodationRoomType;

@Mapper
public interface AccommodationRoomTypeMapper extends BaseMapper<AccommodationRoomType> {
    // 使用 MyBatis-Plus 提供的方法，无需额外定义 SQL
}