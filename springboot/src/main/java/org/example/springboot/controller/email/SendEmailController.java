package org.example.springboot.controller.email;

import jakarta.annotation.Resource;
import org.example.springboot.common.Result;
import org.example.springboot.entity.User;
import org.example.springboot.exception.ServiceException;
import org.example.springboot.service.EmailService;
import org.example.springboot.service.UserService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@CrossOrigin(origins = "*", maxAge = 3600)
@RequestMapping("/email")
public class SendEmailController {
    private static final Logger LOGGER = LoggerFactory.getLogger(SendEmailController.class);

    @Resource
    private EmailService emailService;

    @Resource
    private UserService userService;

    @GetMapping("/code/{email}")
    public Result<?> sendCode(@PathVariable String email) {
        try {
            // 发注册验证码时直接查数据库，避免旧的邮箱缓存导致误判。
            if (userService.existsByEmailDirect(email)) {
                return Result.error("邮箱已被注册");
            }

            String code = emailService.sendVerificationCodeAsync(email);
            LOGGER.info("验证码邮件发送成功：{}", email);
            return Result.success(code);
        } catch (Exception e) {
            LOGGER.error("验证码发送失败：{}", e.getMessage(), e);
            return Result.error("验证码发送失败：" + e.getMessage());
        }
    }

    @GetMapping("/findByEmail/{email}")
    public Result<?> findByEmail(@PathVariable String email) {
        LOGGER.info("FIND BY EMAIL: {}", email);

        try {
            User user = userService.getByEmail(email);
            if (user == null) {
                return Result.error("邮箱不存在");
            }

            String code = emailService.sendResetPasswordEmailAsync(email);
            LOGGER.info("密码重置邮件发送成功：{}", email);
            return Result.success(code);
        } catch (ServiceException e) {
            if ("邮箱不存在".equals(e.getMessage())) {
                return Result.error("邮箱不存在");
            }
            LOGGER.error("密码重置邮件发送失败：{}", e.getMessage(), e);
            return Result.error("密码重置邮件发送失败：" + e.getMessage());
        } catch (Exception e) {
            LOGGER.error("密码重置邮件发送异常：{}", e.getMessage(), e);
            return Result.error("邮件发送异常，请联系管理员");
        }
    }

    @GetMapping("/notify/{email}")
    public Result<?> sendNotification(
            @PathVariable String email,
            @RequestParam String subject,
            @RequestParam String content) {
        try {
            try {
                userService.getByEmail(email);
            } catch (ServiceException e) {
                return Result.error("邮箱不存在");
            }

            emailService.sendNotificationEmailAsync(email, subject, content);
            LOGGER.info("通知邮件发送成功：{}", email);
            return Result.success("通知邮件发送成功");
        } catch (Exception e) {
            LOGGER.error("通知邮件发送异常：{}", e.getMessage(), e);
            return Result.error("通知邮件发送失败：" + e.getMessage());
        }
    }

    @GetMapping("/verify")
    public Result<?> verifyEmailCode(@RequestParam String email, @RequestParam String code) {
        try {
            boolean verified = emailService.verifyCode(email, code);
            if (verified) {
                return Result.success(true);
            }
            return Result.error("验证码错误或已过期");
        } catch (Exception e) {
            LOGGER.error("验证码校验失败：{}", e.getMessage(), e);
            return Result.error("验证码校验失败：" + e.getMessage());
        }
    }
}
