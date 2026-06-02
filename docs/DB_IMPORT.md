# Database Import Guide

本文档说明如何为 `Tourism Planning System` 导入数据库。

## 1. 创建数据库

先在 MySQL 中创建数据库：

```sql
CREATE DATABASE tourism_system DEFAULT CHARACTER SET utf8mb4;
```

## 2. 准备 SQL 文件

当前仓库已包含初始化脚本：

- `db/tourism_system.sql`

## 3. 使用命令行导入

在 Windows / macOS / Linux 中都可以使用如下命令：

```bash
mysql -u root -p tourism_system < db/tourism_system.sql
```

## 4. 使用 Navicat 导入

如果你使用 Navicat：

- 连接本地 MySQL
- 新建数据库 `tourism_system`
- 右键数据库
- 选择“运行 SQL 文件”
- 选择 `db/tourism_system.sql` 并执行

## 5. 检查后端配置

导入完成后，请确认后端数据库配置正确：

- `springboot/src/main/resources/application.properties`
- `springboot/src/main/resources/application.example.properties`

重点检查：

- `spring.datasource.url`
- `spring.datasource.username`
- `spring.datasource.password`

## 6. 启动验证

完成数据库导入后，启动后端：

```bash
cd springboot
mvn spring-boot:run
```

如果后端能正常连接数据库且不报表不存在错误，说明导入成功。

## 7. 建议

初始化脚本中包含表结构和演示数据，适合本地开发、演示和论文项目复现。
