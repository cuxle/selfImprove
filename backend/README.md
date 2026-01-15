# 情绪遗产 - 后端API

基于 FastAPI 构建的心理健康自我觉察应用后端服务。

## 技术栈

- **框架**: FastAPI 0.109.0
- **数据库**: MySQL 8.0 / PostgreSQL
- **ORM**: SQLAlchemy 2.0
- **认证**: JWT (python-jose)
- **密码加密**: Bcrypt (passlib)

## 目录结构

```
backend/
├── app/
│   ├── config/          # 配置文件
│   ├── models/          # 数据库模型
│   ├── schemas/         # Pydantic schemas
│   ├── routes/          # API路由
│   ├── middleware/      # 中间件
│   ├── utils/           # 工具函数
│   └── main.py          # 应用入口
├── requirements.txt     # Python依赖
├── .env.example         # 环境变量示例
└── README.md
```

## 快速开始

### 1. 安装依赖

```bash
cd backend
pip install -r requirements.txt
```

### 2. 配置环境变量

复制 `.env.example` 为 `.env` 并修改配置：

```bash
cp .env.example .env
```

编辑 `.env` 文件：

```env
# 数据库配置（MySQL）
DATABASE_URL=mysql+pymysql://root:your_password@localhost:3306/emotion_legacy_db

# JWT配置
SECRET_KEY=your-super-secret-key-change-this
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# 应用配置
APP_NAME=Emotion Legacy API
DEBUG=True
API_VERSION=v1

# CORS配置
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
```

### 3. 创建数据库

```bash
# MySQL
mysql -u root -p
CREATE DATABASE emotion_legacy_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
exit;
```

### 4. 运行应用

```bash
# 开发模式（自动重载）
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# 或者直接运行
python -m app.main
```

应用将在 `http://localhost:8000` 启动

### 5. 访问API文档

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## API端点

### 认证 `/api/v1/auth`

- `POST /register` - 用户注册
- `POST /login` - 用户登录
- `GET /me` - 获取当前用户信息

### 情绪日记 `/api/v1/diaries`

- `POST /` - 创建日记
- `GET /` - 获取日记列表（支持筛选、分页）
- `GET /{id}` - 获取日记详情
- `PUT /{id}` - 更新日记
- `DELETE /{id}` - 删除日记

### 新回应挑战 `/api/v1/challenges`

- `POST /` - 创建挑战
- `GET /` - 获取挑战列表（支持筛选、分页）
- `GET /{id}` - 获取挑战详情
- `PUT /{id}` - 更新挑战
- `DELETE /{id}` - 删除挑战
- `POST /{id}/attempts` - 添加挑战尝试记录

## 数据库迁移

使用 Alembic 进行数据库迁移：

```bash
# 初始化迁移（首次）
alembic init migrations

# 生成迁移文件
alembic revision --autogenerate -m "描述"

# 执行迁移
alembic upgrade head

# 回滚迁移
alembic downgrade -1
```

## 开发指南

### 添加新的API端点

1. 在 `app/schemas/` 创建 Pydantic schema
2. 在 `app/routes/` 创建路由文件
3. 在 `app/main.py` 注册路由

### 添加新的数据库模型

1. 在 `app/models/` 创建模型文件
2. 在 `app/models/__init__.py` 导出模型
3. 运行数据库迁移

## 测试

```bash
# 安装测试依赖
pip install pytest pytest-asyncio httpx

# 运行测试
pytest
```

## 生产部署

### 使用 Gunicorn + Uvicorn

```bash
pip install gunicorn

gunicorn app.main:app \
  --workers 4 \
  --worker-class uvicorn.workers.UvicornWorker \
  --bind 0.0.0.0:8000
```

### 使用 Docker

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## 安全注意事项

1. **生产环境**务必修改 `SECRET_KEY`
2. 使用 HTTPS
3. 配置合适的 CORS 策略
4. 定期更新依赖包
5. 启用数据库连接池
6. 考虑对敏感数据进行加密存储

## 许可证

MIT License
