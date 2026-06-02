package org.example.springboot.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.example.springboot.entity.AccommodationBooking;

import java.time.LocalDate;

@Mapper
public interface AccommodationBookingMapper extends BaseMapper<AccommodationBooking> {

    @Select("""
            SELECT COALESCE(SUM(rooms), 0)
            FROM accommodation_booking
            WHERE room_type_id = #{roomTypeId}
              AND status IN (0, 1)
              AND check_in_date < #{checkOutDate}
              AND check_out_date > #{checkInDate}
              AND (#{excludeBookingId} IS NULL OR id <> #{excludeBookingId})
            """)
    Integer sumBookedRooms(@Param("roomTypeId") Long roomTypeId,
                           @Param("checkInDate") LocalDate checkInDate,
                           @Param("checkOutDate") LocalDate checkOutDate,
                           @Param("excludeBookingId") Long excludeBookingId);
}
