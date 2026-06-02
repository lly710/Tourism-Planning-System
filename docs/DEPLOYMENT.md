# Deployment Guide

本文档说明如何从零部署 `Tourism Planning System`。

## 1. 环境准备

请先安装以下软件：

- JDK 17+
- Maven 3.9+
- Node.js 18+
- MySQL 8+
- Redis 6+

建议确认命令可用：

```bash
java -version
mvn -version
node -v
npm -v
mysql --version
redis-server --version
```

## 2. 克隆项目

```bash
git clone https://github.com/lly710/Tourism-Planning-System.git
cd Tourism-Planning-System
```

## 3. 初始化数据库

创建数据库：

```sql
CREATE DATABASE tourism_system DEFAULT CHARACTER SET utf8mb4;
```

执行导入：

```bash
mysql -u root -p tourism_system < db/tourism_system.sql
```

详细说明：

- `docs/DB_IMPORT.md`

## 4. 配置后端

后端配置文件：

- `springboot/src/main/resources/application.properties`
- `springboot/src/main/resources/application.example.properties`

建议至少配置：

- `DB_URL`
- `DB_USERNAME`
- `DB_PASSWORD`
- `REDIS_HOST`
- `REDIS_PORT`
- `AMAP_KEY`

如需邮件、上传、支付功能，还需要：

- `MAIL_USERNAME`
- `MAIL_PASSWORD`
- `FROM_EMAIL`
- `ALIYUN_OSS_ACCESS_KEY_ID`
- `ALIYUN_OSS_ACCESS_KEY_SECRET`
- `ALIPAY_APP_ID`
- `ALIPAY_PRIVATE_KEY`
- `ALIPAY_PUBLIC_KEY`

## 5. 启动 Redis

请确保 Redis 已启动，默认配置：

- Host: `localhost`
- Port: `6379`

## 6. 启动后端

```bash
cd springboot
mvn spring-boot:run
```

默认端口：

- `1236`

## 7. 配置前端

前端环境变量示例文件：

- `vue3/.env.example`

推荐至少配置：

```env
VUE_APP_BASE_API=/api
VUE_APP_AMAP_KEY=your-amap-key
VUE_APP_AMAP_SECURITY_CODE=your-amap-security-code
```

如果前后端分开部署，可将 `VUE_APP_BASE_API` 改成完整地址，例如：

```env
VUE_APP_BASE_API=http://localhost:1236
```

## 8. 启动前端

```bash
cd vue3
npm install
npm run serve
```

通常本地访问地址类似：

- `http://localhost:8080`

## 9. 访问项目

前端启动后可访问首页、攻略、住宿、门票与路线规划功能。

后端启动后可按本地配置访问接口文档（Knife4j）。

## 10. 常见问题

### 10.1 前端启动后接口请求失败

请检查：

- 后端是否已启动
- `VUE_APP_BASE_API` 是否正确
- 浏览器控制台是否有跨域或 404 报错

### 10.2 路线规划页面无法加载地图

请检查：

- `VUE_APP_AMAP_KEY` 是否正确
- `VUE_APP_AMAP_SECURITY_CODE` 是否正确
- 高德地图 Key 是否已启用 Web JS API

### 10.3 后端启动失败

请检查：

- MySQL 是否启动
- Redis 是否启动
- 数据库是否已导入
- 数据库账号密码是否正确

### 10.4 上传功能不可用

请检查：

- OSS 配置是否正确
- 桶名、地域、访问域名是否匹配
