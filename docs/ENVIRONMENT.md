# Environment Variables

本文档说明项目部署时建议配置的环境变量。

## Backend

后端配置文件支持通过环境变量注入。

### 基础运行

| 变量名 | 说明 | 示例 |
| --- | --- | --- |
| `SERVER_PORT` | 后端端口 | `1236` |
| `SPRING_SECURITY_USER_NAME` | Spring Security 用户名 | `admin` |
| `SPRING_SECURITY_USER_PASSWORD` | Spring Security 密码 | `change-me` |
| `USER_DEFAULT_PASSWORD` | 默认用户密码 | `123456` |

### 数据库

| 变量名 | 说明 | 示例 |
| --- | --- | --- |
| `DB_URL` | MySQL 连接地址 | `jdbc:mysql://localhost:3306/tourism_system?...` |
| `DB_USERNAME` | 数据库用户名 | `root` |
| `DB_PASSWORD` | 数据库密码 | `your-password` |

### Redis

| 变量名 | 说明 | 示例 |
| --- | --- | --- |
| `REDIS_HOST` | Redis 主机 | `localhost` |
| `REDIS_PORT` | Redis 端口 | `6379` |
| `REDIS_DATABASE` | Redis 库编号 | `0` |
| `REDIS_TIMEOUT` | Redis 超时毫秒数 | `10000` |

### 邮件

| 变量名 | 说明 | 示例 |
| --- | --- | --- |
| `MAIL_HOST` | SMTP 服务器 | `smtp.qq.com` |
| `MAIL_USERNAME` | 邮箱账号 | `your-email@example.com` |
| `MAIL_PASSWORD` | SMTP 授权码 | `your-smtp-password` |
| `MAIL_PORT` | SMTP 端口 | `465` |
| `FROM_EMAIL` | 发件人邮箱 | `your-email@example.com` |

### 支付

| 变量名 | 说明 | 示例 |
| --- | --- | --- |
| `ALIPAY_GATEWAY` | 支付网关地址 | `https://openapi-sandbox.dl.alipaydev.com/gateway.do` |
| `ALIPAY_APP_ID` | 支付应用 ID | `your-app-id` |
| `ALIPAY_PRIVATE_KEY` | 商户私钥 | `your-private-key` |
| `ALIPAY_PUBLIC_KEY` | 平台公钥 | `your-public-key` |
| `ALIPAY_RETURN_URL` | 支付回跳地址 | `http://localhost:8080/payment/result` |
| `ALIPAY_NOTIFY_URL` | 支付通知地址 | `http://localhost:8080/alipay/notify` |
| `ALIPAY_CHARSET` | 字符集 | `UTF-8` |
| `ALIPAY_FORMAT` | 数据格式 | `json` |
| `ALIPAY_SIGN_TYPE` | 签名算法 | `RSA2` |
| `ALIPAY_FIXED_PAY_AMOUNT` | 模拟支付金额 | `0.01` |

### 地图

| 变量名 | 说明 | 示例 |
| --- | --- | --- |
| `AMAP_KEY` | 高德 Web 服务 Key | `your-amap-key` |

### OSS

| 变量名 | 说明 | 示例 |
| --- | --- | --- |
| `ALIYUN_OSS_ENDPOINT` | OSS Endpoint | `https://oss-cn-beijing.aliyuncs.com` |
| `ALIYUN_OSS_BUCKET` | 桶名 | `your-bucket-name` |
| `ALIYUN_OSS_REGION` | 地域 | `cn-beijing` |
| `ALIYUN_OSS_ACCESS_KEY_ID` | Access Key ID | `your-access-key-id` |
| `ALIYUN_OSS_ACCESS_KEY_SECRET` | Access Key Secret | `your-access-key-secret` |
| `ALIYUN_OSS_URL_DOMAIN` | 访问域名 | `https://your-bucket.oss-cn-beijing.aliyuncs.com` |
| `ALIYUN_OSS_FILE_PREFIX` | 文件前缀 | `files/` |

## Frontend

前端建议配置以下环境变量。

| 变量名 | 说明 | 示例 |
| --- | --- | --- |
| `VUE_APP_TITLE` | 前端标题 | `Tourism Route Planning System` |
| `VUE_APP_BASE_API` | 前端请求 API 前缀 | `/api` 或 `http://localhost:1236` |
| `VUE_APP_AMAP_KEY` | 高德 Web JS API Key | `your-amap-key` |
| `VUE_APP_AMAP_SECURITY_CODE` | 高德安全密钥 | `your-amap-security-code` |

## 建议

- 开发环境优先使用本地 `.env` 或系统环境变量
- 公开仓库中不要提交真实密码、授权码、密钥
- 如果部署到服务器，建议使用服务器环境变量统一管理密钥
