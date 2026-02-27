# 情绪遗产 - 心理健康自我觉察应用

一个帮助用户记录、理解和改变情绪模式的心理健康应用。通过"情绪遗产日记"和"新回应挑战"两大核心功能，帮助用户识别情绪触发器，理解童年创伤的影响，并建立更健康的情绪回应模式。

## 项目架构

```
selfimprove/
├── backend/                 # Python FastAPI 后端
│   ├── app/
│   │   ├── config/         # 配置
│   │   ├── models/         # 数据库模型
│   │   ├── schemas/        # 数据验证
│   │   ├── routes/         # API路由
│   │   ├── middleware/     # 中间件
│   │   ├── utils/          # 工具函数
│   │   └── main.py         # 入口文件
│   ├── requirements.txt
│   └── README.md
│
├── flutter_app/            # Flutter 前端应用
│   ├── lib/
│   │   ├── config/        # 配置
│   │   ├── models/        # 数据模型
│   │   ├── services/      # API服务
│   │   ├── providers/     # 状态管理
│   │   ├── screens/       # 界面
│   │   └── main.dart      # 入口文件
│   ├── pubspec.yaml
│   └── README.md
│
├── database-design.md      # 数据库设计文档
├── project-structure.md    # 项目结构文档
└── README.md              # 本文档
```

## 核心功能

### 1. 情绪遗产日记

帮助用户记录和分析情绪模式：

- **触发事件**: 记录触发情绪的具体事件
- **即时情绪**: 识别和命名当下的情绪
- **情绪强度**: 1-10级量化情绪强度
- **身体反应**: 觉察情绪引发的身体变化
- **自动化思维**: 捕捉脑海中的自动想法
- **童年记忆**: 探索与童年经历的联系
- **模式识别**: 发现重复出现的情绪模式

### 2. 新回应挑战

帮助用户建立更健康的情绪回应：

- **挑战设定**: 明确旧反应和新回应的对比
- **难度评估**: 1-5级评估挑战难度
- **进度追踪**: 记录每次尝试的结果
- **反思记录**: 总结经验和感受
- **成功率统计**: 可视化进步轨迹

## 技术栈

### 后端
- **框架**: FastAPI 0.109.0
- **数据库**: MySQL 8.0 / PostgreSQL
- **ORM**: SQLAlchemy 2.0
- **认证**: JWT (python-jose)
- **密码加密**: Bcrypt

### 前端
- **框架**: Flutter 3.x
- **状态管理**: Provider
- **网络请求**: http
- **跨平台**: iOS / Android / Web

## 快速开始

### 前置要求

- Python 3.11+
- Flutter SDK 3.0+
- MySQL 8.0 / PostgreSQL
- Node.js (可选，用于部署)

### 1. 启动后端服务
```bash
# 进入后端目录
cd backend

# 安装依赖
pip install -r requirements.txt

# 配置环境变量
cp .env.example .env
# 编辑 .env 文件，配置数据库连接等信息

# 创建数据库
mysql -u root -p
CREATE DATABASE emotion_legacy_db;
exit;

# 启动服务
uvicorn app.main:app --reload

# 访问 API 文档
# http://localhost:8000/docs
```

### 2. 启动Flutter应用

```bash
# 进入前端目录
cd flutter_app

# 安装依赖
flutter pub get

# 配置API地址（编辑 lib/config/api_config.dart）

# 运行应用
flutter run -d chrome    # Web版
flutter run -d android   # Android版
flutter run -d ios       # iOS版
```

## API文档

后端启动后，访问以下地址查看API文档：

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

### 主要API端点

#### 认证
- `POST /api/v1/auth/register` - 用户注册
- `POST /api/v1/auth/login` - 用户登录
- `GET /api/v1/auth/me` - 获取当前用户

#### 情绪日记
- `POST /api/v1/diaries` - 创建日记
- `GET /api/v1/diaries` - 获取日记列表
- `GET /api/v1/diaries/{id}` - 获取日记详情
- `PUT /api/v1/diaries/{id}` - 更新日记
- `DELETE /api/v1/diaries/{id}` - 删除日记

#### 新回应挑战
- `POST /api/v1/challenges` - 创建挑战
- `GET /api/v1/challenges` - 获取挑战列表
- `GET /api/v1/challenges/{id}` - 获取挑战详情
- `PUT /api/v1/challenges/{id}` - 更新挑战
- `DELETE /api/v1/challenges/{id}` - 删除挑战
- `POST /api/v1/challenges/{id}/attempts` - 添加尝试记录

## 数据库设计

详细的数据库设计请参考 `database-design.md`

主要数据表：
- `users` - 用户表
- `emotion_diaries` - 情绪日记表
- `emotion_tags` - 情绪标签表
- `diary_tags` - 日记标签关联表
- `response_challenges` - 挑战表
- `challenge_attempts` - 挑战尝试记录表

## 开发路线图

### Phase 1 - 核心功能 (已完成 ✅)
- [x] 用户认证系统
- [x] 情绪日记CRUD
- [x] 新回应挑战CRUD
- [x] 基础UI界面

### Phase 2 - 增强功能 (规划中)
- [ ] 日记详情页面
- [ ] 挑战详情页面
- [ ] 情绪趋势图表
- [ ] 数据筛选和搜索
- [ ] 标签管理

### Phase 3 - 高级功能 (未来)
- [ ] 内容库（心理学知识）
- [ ] 数据导出功能
- [ ] 社区功能（匿名分享）
- [ ] AI智能建议
- [ ] 通知提醒

## 部署指南

### 后端部署

使用 Docker：

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY backend/ .
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### 前端部署

Web版：
```bash
cd flutter_app
flutter build web --release
# 将 build/web/ 部署到静态服务器
```

移动版：
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## 安全注意事项

1. **生产环境务必修改 SECRET_KEY**
2. 使用 HTTPS 加密传输
3. 配置合适的 CORS 策略
4. 定期备份用户数据
5. 考虑对敏感字段进行加密存储

## 最近更新

### 2026-01-24
- **新增** `LIGHTSAIL_DEPLOY.md`：AWS Lightsail 部署指南，方便将后端服务一键部署到海外云服务器。
- **修改** `backend/Dockerfile`：移除清华大学 PyPI 镜像参数，改用官方 PyPI 源，以适配海外服务器的网络环境。

更完整的历史记录请参阅 [CHANGELOG.md](./CHANGELOG.md)。

## 许可证

MIT License

## 联系方式

如有问题或建议，欢迎提交 Issue 或 Pull Request。
