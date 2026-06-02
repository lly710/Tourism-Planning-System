# Tourism Route Planning System

基于动态规划算法的旅游路线规划系统，采用前后端分离架构实现，包含 `Spring Boot` 后端与 `Vue 3` 前端。

> 适用于课程设计、毕业设计或旅游类信息系统开发参考。

## Overview

该项目围绕旅游场景提供完整业务流程，覆盖：

- 景点浏览与分类展示
- 旅游攻略展示与路线关联
- 门票预订与订单管理
- 周边住宿与房型预订
- 用户注册、登录与权限控制
- 评论、收藏、后台管理
- 基于动态规划的旅游路线优化

## Architecture

```text
C:\Users\lly\Desktop\1
├─ springboot/                  # Spring Boot 后端
├─ vue3/                        # Vue 3 前端
├─ operate_log.sql              # 数据库相关 SQL
├─ er_diagram.md                # ER 图说明
├─ er_diagram_thesis.png        # ER 图资源
└─ README.md
```

## Tech Stack

**Backend**
- Java 17
- Spring Boot 3
- Spring Security
- MyBatis-Plus
- MySQL
- Redis
- Knife4j / OpenAPI

**Frontend**
- Vue 3
- Vue Router
- Element Plus
- Pinia / Vuex
- Axios

## Core Features

- 用户登录、注册、个人信息维护
- 景点、分类、轮播图、评论等旅游内容管理
- 旅游攻略与路线展示
- 门票下单、住宿预订、订单支付流程
- 后台管理端数据维护
- 基于动态规划的最优旅游路线规划
- Redis 缓存与部分并发控制

## Route Planning

项目核心亮点之一是路线规划模块。后端提供基于动态规划的路线优化能力，用于在多个景点之间生成更优访问顺序，适用于：

- 多景点旅游行程规划
- 时间优先或路径优先的路线比较
- 攻略内容与规划路线联动展示

相关实现可从 `C:\Users\lly\Desktop\1\springboot\src\main\java\org\example\springboot\controller\RoutePlanningController.java:29` 开始查看。

## Getting Started

### Prerequisites

- JDK 17+
- Maven 3.9+
- Node.js 18+
- MySQL 8+
- Redis 6+

### 1. Backend

进入后端目录：

```bash
cd springboot
```

启动前请先配置数据库、Redis、邮件、地图与对象存储等参数。

后端安全示例配置见：

- `C:\Users\lly\Desktop\1\springboot\src\main\resources\application.example.properties:1`
- `C:\Users\lly\Desktop\1\springboot\src\main\resources\application.properties:1`

启动命令：

```bash
mvn spring-boot:run
```

默认端口：

- Backend: `1236`

### 2. Frontend

进入前端目录：

```bash
cd vue3
```

安装依赖：

```bash
npm install
```

开发模式：

```bash
npm run serve
```

生产构建：

```bash
npm run build
```

## Environment Configuration

### Backend

为避免公开仓库泄露敏感配置，已将后端配置改为环境变量或占位符形式。建议通过系统环境变量或本地私有配置管理以下信息：

- 数据库账号密码
- 邮箱 SMTP 授权码
- 支付平台密钥
- 高德地图 Key
- 阿里云 OSS 密钥

### Frontend

前端示例环境变量建议参考：

- `C:\Users\lly\Desktop\1\vue3\.env.example:1`

如果本地需要覆盖，可自行创建：

- `vue3/.env.local`
- `vue3/.env.development.local`
- `vue3/.env.production.local`

## API / Docs

项目已集成 Knife4j，后端启动后可按配置访问接口文档。

主要配置位于：

- `C:\Users\lly\Desktop\1\springboot\src\main\resources\application.properties:42`

## Database

项目中包含数据库相关脚本：

- `C:\Users\lly\Desktop\1\operate_log.sql:1`

如果你准备公开仓库，建议仅保留必要建表和演示数据，避免上传包含真实业务数据的 SQL 文件。

## Open Source Notes

该仓库公开前，建议额外确认以下内容：

- 是否仍有真实账号、密钥、授权码残留
- 是否保留了无关的大文件、扫描件、压缩包
- 是否需要移除本地生成目录与 IDE 文件
- 是否需要补充项目截图、演示视频或论文说明

## Recommended Cleanup Before Push

- 删除前端嵌套仓库目录 `C:\Users\lly\Desktop\1\vue3\.git`
- 确保 `.gitignore` 已生效：`C:\Users\lly\Desktop\1\.gitignore:1`
- 检查后端配置占位符：`C:\Users\lly\Desktop\1\springboot\src\main\resources\application.properties:1`

## License

当前仓库未包含许可证文件。若计划公开开源，建议添加：

- `MIT`
- `Apache-2.0`

## Acknowledgements

如果这是毕业设计项目，建议在后续补充：

- 项目背景
- 功能截图
- 部署说明
- 论文摘要
- 演示账号说明
