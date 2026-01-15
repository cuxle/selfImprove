# 数据库迁移指南

## 方法一：使用Docker（推荐）

如果你的应用运行在Docker容器中：

### 1. 启动Docker容器
```bash
cd backend
docker-compose up -d
```

### 2. 进入数据库容器执行SQL
```bash
# 进入MySQL容器
docker-compose exec db mysql -uroot -p

# 输入密码后执行以下命令
USE emotion_legacy_db;

-- 添加phone字段
ALTER TABLE users 
ADD COLUMN phone VARCHAR(20) NULL COMMENT '手机号' AFTER nickname;

-- 添加唯一索引
ALTER TABLE users 
ADD UNIQUE INDEX idx_phone (phone);

-- 验证
DESC users;

-- 退出
exit;
```

### 3. 或者使用SQL文件直接导入
```bash
docker-compose exec db mysql -uroot -p emotion_legacy_db < init.sql/add_phone_field.sql
```

## 方法二：使用数据库客户端

### 1. 连接数据库
使用你喜欢的数据库客户端（如Navicat、DBeaver、MySQL Workbench等）连接到数据库：

- 主机：localhost（或你的数据库服务器地址）
- 端口：3306
- 用户：root
- 密码：（查看.env文件中的MYSQL_ROOT_PASSWORD）
- 数据库：emotion_legacy_db

### 2. 执行SQL脚本
打开并执行 `backend/init.sql/add_phone_field.sql` 文件

或者直接执行以下SQL：

```sql
USE emotion_legacy_db;

ALTER TABLE users 
ADD COLUMN phone VARCHAR(20) NULL COMMENT '手机号' AFTER nickname;

ALTER TABLE users 
ADD UNIQUE INDEX idx_phone (phone);

DESC users;
```

## 方法三：使用Python脚本（需要Python环境）

### 1. 确保已安装依赖
```bash
cd backend
pip install -r requirements.txt
```

### 2. 运行迁移脚本
```bash
python migrate_add_phone.py
```

## 验证迁移是否成功

执行以下SQL查询验证：

```sql
SELECT 
    COLUMN_NAME as '字段名',
    COLUMN_TYPE as '类型',
    IS_NULLABLE as '可为空',
    COLUMN_KEY as '索引'
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'emotion_legacy_db'
AND TABLE_NAME = 'users'
AND COLUMN_NAME = 'phone';
```

应该看到类似这样的结果：
```
字段名  | 类型         | 可为空 | 索引
--------|-------------|--------|------
phone   | varchar(20) | YES    | UNI
```

## 常见问题

### Q: 提示字段已存在
A: 说明之前已经执行过迁移，无需重复执行

### Q: Docker命令无法执行
A: 确保Docker Desktop已启动，或检查docker-compose.yml配置

### Q: 连接数据库失败
A: 检查.env文件中的数据库配置是否正确

### Q: 权限不足
A: 确保使用的数据库用户有ALTER TABLE权限

## 回滚迁移（如需要）

如果需要移除phone字段：

```sql
USE emotion_legacy_db;
ALTER TABLE users DROP INDEX idx_phone;
ALTER TABLE users DROP COLUMN phone;
```

## 下一步

迁移完成后，重启应用即可使用手机号验证码登录功能！

```bash
cd backend
docker-compose restart
```

或者如果是开发环境：
```bash
cd backend/app
uvicorn main:app --reload
```
