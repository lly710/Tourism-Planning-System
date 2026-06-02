package org.example.springboot.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.annotation.Resource;
import org.example.springboot.common.Result;
import org.example.springboot.service.AlipayService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "支付宝支付接口")
@RestController
@RequestMapping("/alipay")
public class AlipayController {
    private static final Logger LOGGER = LoggerFactory.getLogger(AlipayController.class);

    @Resource
    private AlipayService alipayService;

    @Operation(summary = "生成支付宝支付表单（模拟支付）")
    @GetMapping("/pay/{orderId}")
    public Result<String> pay(@PathVariable Long orderId) {
        String formHtml = alipayService.createMockAlipayForm(orderId);
        return Result.success(formHtml);
    }

    @Operation(summary = "模拟支付宝支付")
    @PostMapping("/mock-pay/{orderId}")
    public Result<?> mockPay(@PathVariable Long orderId) {
        try {
            alipayService.mockAlipayPayment(orderId);
            return Result.success("支付成功");
        } catch (Exception e) {
            LOGGER.error("模拟支付失败: {}", e.getMessage(), e);
            return Result.error("支付失败: " + e.getMessage());
        }
    }
}
