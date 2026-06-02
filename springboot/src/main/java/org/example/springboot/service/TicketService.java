package org.example.springboot.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import jakarta.annotation.Resource;
import org.apache.commons.lang3.StringUtils;
import org.example.springboot.entity.ScenicSpot;
import org.example.springboot.entity.Ticket;
import org.example.springboot.exception.ServiceException;
import org.example.springboot.mapper.ScenicSpotMapper;
import org.example.springboot.mapper.TicketMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class TicketService {

    @Resource
    private TicketMapper ticketMapper;

    @Resource
    private ScenicSpotMapper scenicSpotMapper;

    public Page<Ticket> getTicketsByPage(String ticketName, String ticketType, Long scenicId, Integer currentPage, Integer size) {
        LambdaQueryWrapper<Ticket> queryWrapper = new LambdaQueryWrapper<>();

        if (StringUtils.isNotBlank(ticketName)) {
            queryWrapper.like(Ticket::getTicketName, ticketName);
        }
        if (StringUtils.isNotBlank(ticketType)) {
            queryWrapper.eq(Ticket::getTicketType, ticketType);
        }
        if (scenicId != null) {
            queryWrapper.eq(Ticket::getScenicId, scenicId);
        }

        queryWrapper.eq(Ticket::getStatus, 1);
        queryWrapper.orderByDesc(Ticket::getCreateTime);
        return ticketMapper.selectPage(new Page<>(currentPage, size), queryWrapper);
    }

    public Ticket getTicketById(Long id) {
        Ticket ticket = ticketMapper.selectById(id);
        if (ticket == null) {
            throw new ServiceException("门票不存在");
        }
        return ticket;
    }

    @Transactional
    public void addTicket(Ticket ticket) {
        ScenicSpot scenicSpot = scenicSpotMapper.selectById(ticket.getScenicId());
        if (scenicSpot == null) {
            throw new ServiceException("关联的景点不存在");
        }

        if (ticket.getStatus() == null) {
            ticket.setStatus(1);
        }

        ticketMapper.insert(ticket);
    }

    @Transactional
    public void updateTicket(Ticket ticket) {
        Ticket existTicket = ticketMapper.selectById(ticket.getId());
        if (existTicket == null) {
            throw new ServiceException("门票不存在");
        }

        if (ticket.getScenicId() != null && !ticket.getScenicId().equals(existTicket.getScenicId())) {
            ScenicSpot scenicSpot = scenicSpotMapper.selectById(ticket.getScenicId());
            if (scenicSpot == null) {
                throw new ServiceException("关联的景点不存在");
            }
        }

        ticketMapper.updateById(ticket);
    }

    @Transactional
    public void deleteTicket(Long id) {
        Ticket ticket = ticketMapper.selectById(id);
        if (ticket == null) {
            throw new ServiceException("门票不存在");
        }

        ticketMapper.deleteById(id);
    }

    public Page<Ticket> getTicketsByScenicId(Long scenicId, Integer currentPage, Integer size) {
        LambdaQueryWrapper<Ticket> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Ticket::getScenicId, scenicId);
        queryWrapper.eq(Ticket::getStatus, 1);
        queryWrapper.orderByAsc(Ticket::getPrice);
        return ticketMapper.selectPage(new Page<>(currentPage, size), queryWrapper);
    }

    @Transactional
    public void updateTicketStock(Long ticketId, Integer quantity) {
        if (quantity == null || quantity <= 0) {
            throw new ServiceException("扣减数量必须大于 0");
        }

        Ticket ticket = ticketMapper.selectById(ticketId);
        if (ticket == null) {
            throw new ServiceException("门票不存在");
        }

        int affected = ticketMapper.deductStock(ticketId, quantity);
        if (affected <= 0) {
            throw new ServiceException("门票库存不足");
        }
    }

    @Transactional
    public void restoreTicketStock(Long ticketId, Integer quantity) {
        if (quantity == null || quantity <= 0) {
            throw new ServiceException("恢复数量必须大于 0");
        }

        Ticket ticket = ticketMapper.selectById(ticketId);
        if (ticket == null) {
            throw new ServiceException("门票不存在");
        }

        ticketMapper.restoreStock(ticketId, quantity);
    }
}
