# Tourism Planning System

一个基于动态规划算法的旅游路线规划系统，采用前后端分离架构实现：

- `springboot/`：Spring Boot 后端
- `vue3/`：Vue 3 前端


## Features

- 用户注册、登录、权限控制
- 景点、分类、轮播图、评论管理
- 旅游攻略展示与收藏
- 门票预订、住宿预订、订单管理
- 支付流程模拟
- 基于动态规划的旅游路线优化
- Redis 缓存与部分并发控制

## Tech Stack

**Backend**
- Java 17
- Spring Boot 3
- Spring Security
- MyBatis-Plus
- MySQL
- Redis
- Knife4j

**Frontend**
- Vue 3
- Vue Router
- Element Plus
- Pinia / Vuex
- Axios

## Project Structure

```text
Tourism-Planning-System
├─ springboot
└─ vue3
```

## Quick Start

### 1. Start Backend

```bash
cd springboot
mvn spring-boot:run
```

默认端口：

- Backend: `1236`

后端配置文件：

- `springboot/src/main/resources/application.properties`
- `springboot/src/main/resources/application.example.properties`

### 2. Start Frontend

```bash
cd vue3
npm install
npm run serve
```

前端示例环境变量：

- `vue3/.env.example`

## Environment

公开仓库已移除敏感配置，以下内容请自行本地配置：

- 数据库连接信息
- Redis 连接信息
- 邮箱 SMTP 授权信息
- 支付平台配置
- 高德地图 Key
- 阿里云 OSS 配置

建议参考：

- `springboot/src/main/resources/application.example.properties`
- `vue3/.env.example`

## Route Planning

项目核心亮点是旅游路线规划模块。后端通过动态规划算法计算多景点访问顺序，用于生成更优路线方案。

相关实现入口：

- `springboot/src/main/java/org/example/springboot/controller/RoutePlanningController.java:29`

## API Docs

项目集成了 Knife4j。启动后端后，可按本地配置访问接口文档。

## Notes

- 当前仓库仅保留前端、后端和必要说明文件
- 运行前请先完成本地数据库和中间件配置


## License

当前仓库暂未添加开源许可证。
