package org.example.springboot.util;


import cn.hutool.core.date.DateUtil;
import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.baomidou.mybatisplus.core.toolkit.StringUtils;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.annotation.PostConstruct;
import jakarta.annotation.Resource;
import jakarta.servlet.http.HttpServletRequest;
import org.example.springboot.entity.User;
import org.example.springboot.service.UserService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.util.Date;
import java.util.Map;

@Component
public class JwtTokenUtils {
    //因为下面的方法都是 static，所以需要把 Service 变成静态才能用。
    private static UserService staticUserService;
    private static RedisUtil staticRedisUtil;
    private static ObjectMapper staticObjectMapper;
    
    @Resource
    private UserService userService;
    
    @Resource
    private RedisUtil redisUtil;
    
    @Resource
    private ObjectMapper objectMapper;
    
    public static final Logger LOGGER = LoggerFactory.getLogger(JwtTokenUtils.class);
    //Redis 里存 token 的 key 前缀：user:token:token，区别不用业务
    private static final String USER_TOKEN_KEY_PREFIX = "user:token:";
    //Redis 里存用户信息的 key 前缀：user:id:1001
    private static final String USER_ID_KEY_PREFIX = "user:id:";
    //token 过期时间：7200 秒 = 2 小时。
    private static final long TOKEN_EXPIRE = 7200; // 2小时
    
    @PostConstruct
    public void setServices() {
        staticUserService = userService;
        //注入 Redis 工具，用来存 token、存用户信息。
        staticRedisUtil = redisUtil;
        //注入 JSON 转换工具，把对象转 JSON、JSON 转对象。
        staticObjectMapper = objectMapper;
    }
    //传入用户 ID + 密钥，生成 token。
    public static String genToken(String userId, String sign) {
        String token = JWT.create()
                .withAudience(userId)// // 把 userId 放进受众字段
                .withExpiresAt(DateUtil.offsetHour(new Date(), 2))
                .sign(Algorithm.HMAC256(sign));//用密钥签名，生成toke
        
        // 将token和用户ID的映射关系存入Redis，方便后续查询和管理
        staticRedisUtil.set(USER_TOKEN_KEY_PREFIX + token, userId, TOKEN_EXPIRE);
        
        return token;
    }
    
    public static User getCurrentUser() {
        String token = null;
        try {
            // // 获取当前请求 request
            HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes()).getRequest();
            token = request.getHeader("token");
            if (StringUtils.isBlank(token)) {
                //就从参数 ?token= 里拿
                token = request.getParameter("token");
            }
            if (StringUtils.isBlank(token)) {
                LOGGER.error("获取当前登录的token失败，token{}", token);
                return null;
            }

            // 首先尝试从Redis中获取token对应的用户ID
            String userId = (String) staticRedisUtil.get(USER_TOKEN_KEY_PREFIX + token);
            
            // 如果Redis中没有，则从JWT中解析
            if (StringUtils.isBlank(userId)) {
                userId = JWT.decode(token).getAudience().get(0);
                if (StringUtils.isBlank(userId)) {
                    LOGGER.error("从token中解析用户ID失败，token: {}", token);
                    return null;
                }
                // 将解析到的用户ID存入Redis
                staticRedisUtil.set(USER_TOKEN_KEY_PREFIX + token, userId, TOKEN_EXPIRE);
            }
            
            // 尝试从Redis中获取用户信息
            String userKey = USER_ID_KEY_PREFIX + userId;
            Object userObj = staticRedisUtil.get(userKey);
            User user = null;
            
            if (userObj != null) {
                try {
                    // 处理不同类型的缓存数据
                    if (userObj instanceof User) {
                        // 直接是User对象
                        user = (User) userObj;
                    } else if (userObj instanceof Map) {
                        // 如果是Map，使用ObjectMapper进行转换
                        String jsonStr = staticObjectMapper.writeValueAsString(userObj);
                        user = staticObjectMapper.readValue(jsonStr, User.class);
                    } else {
                        // 其他类型，尝试通过JSON序列化和反序列化进行转换
                        String jsonStr = staticObjectMapper.writeValueAsString(userObj);
                        user = staticObjectMapper.readValue(jsonStr, User.class);
                    }
                } catch (Exception e) {
                    LOGGER.error("Redis缓存中的用户数据转换失败，将从数据库重新获取", e);
                    user = null; // 转换失败，重新从数据库获取
                }
            }
            
            // 如果Redis中没有用户信息或转换失败，则从数据库查询
            if (user == null) {
                user = staticUserService.getUserById(Long.valueOf(userId));
                if (user != null) {
                    // 将用户信息存入Redis
                    staticRedisUtil.set(userKey, user, TOKEN_EXPIRE);
                }
            }
            
            return user;
        } catch (Exception e) {
            LOGGER.error("获取当前用户信息失败，token: {}", token, e);
            return null;
        }
    }
    
    /**
     * 更新Redis中的用户信息
     * 
     * @param user 用户信息
     */
    public static void updateUserCache(User user) {
        if (user != null && user.getId() != null) {
            String userKey = USER_ID_KEY_PREFIX + user.getId();
            staticRedisUtil.set(userKey, user, TOKEN_EXPIRE);
        }
    }
    
    /**
     * 清除用户的缓存信息
     * 
     * @param token 用户token
     */
    public static void clearUserCache(String token) {
        if (StringUtils.isNotBlank(token)) {
            String userId = (String) staticRedisUtil.get(USER_TOKEN_KEY_PREFIX + token);
            if (StringUtils.isNotBlank(userId)) {
                // 删除用户信息缓存
                staticRedisUtil.del(USER_ID_KEY_PREFIX + userId);
            }
            // 删除token缓存
            staticRedisUtil.del(USER_TOKEN_KEY_PREFIX + token);
        }
    }
}
