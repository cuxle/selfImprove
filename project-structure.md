# 项目结构规划

## 整体架构

```
selfimprove/
├── flutter_app/              # Flutter 前端应用
├── backend/                  # Python Flask/FastAPI 后端
├── database-design.md        # 数据库设计文档
└── project-structure.md      # 本文档
```

## Flutter 应用结构

```
flutter_app/
├── lib/
│   ├── main.dart                    # 应用入口
│   ├── config/
│   │   ├── app_config.dart          # 应用配置
│   │   └── api_config.dart          # API配置
│   ├── models/
│   │   ├── user.dart                # 用户模型
│   │   ├── emotion_diary.dart       # 日记模型
│   │   ├── emotion_tag.dart         # 标签模型
│   │   └── response_challenge.dart  # 挑战模型
│   ├── services/
│   │   ├── api_service.dart         # API基础服务
│   │   ├── auth_service.dart        # 认证服务
│   │   ├── diary_service.dart       # 日记服务
│   │   └── challenge_service.dart   # 挑战服务
│   ├── providers/
│   │   ├── auth_provider.dart       # 认证状态管理
│   │   ├── diary_provider.dart      # 日记状态管理
│   │   └── challenge_provider.dart  # 挑战状态管理
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── diary/
│   │   │   ├── diary_list_screen.dart
│   │   │   ├── diary_detail_screen.dart
│   │   │   └── diary_create_screen.dart
│   │   ├── challenge/
│   │   │   ├── challenge_list_screen.dart
│   │   │   ├── challenge_create_screen.dart
│   │   │   └── challenge_detail_screen.dart
│   │   └── home/
│   │       └── home_screen.dart
│   ├── widgets/
│   │   ├── common/
│   │   │   ├── custom_button.dart
│   │   │   ├── custom_text_field.dart
│   │   │   └── loading_indicator.dart
│   │   ├── diary/
│   │   │   ├── diary_card.dart
│   │   │   ├── emotion_selector.dart
│   │   │   └── intensity_slider.dart
│   │   └── challenge/
│   │       └── challenge_card.dart
│   └── utils/
│       ├── constants.dart           # 常量定义
│       ├── validators.dart          # 表单验证
│       └── date_formatter.dart      # 日期格式化
├── pubspec.yaml                     # 依赖配置
└── README.md
```

## Python 后端结构

```
backend/
├── app/
│   ├── __init__.py                   # Flask应用初始化
│   ├── main.py                       # 应用入口
│   ├── config/
│   │   ├── __init__.py
│   │   ├── config.py                 # 配置文件
│   │   └── database.py               # 数据库配置
│   ├── models/
│   │   ├── __init__.py
│   │   ├── user.py                   # 用户模型
│   │   ├── emotion_diary.py          # 日记模型
│   │   ├── emotion_tag.py            # 标签模型
│   │   ├── response_challenge.py     # 挑战模型
│   │   ├── challenge_attempt.py      # 挑战尝试记录
│   │   └── content_article.py        # 内容文章模型
│   ├── schemas/
│   │   ├── __init__.py
│   │   ├── user_schema.py            # 用户数据验证
│   │   ├── diary_schema.py           # 日记数据验证
│   │   └── challenge_schema.py       # 挑战数据验证
│   ├── routes/
│   │   ├── __init__.py
│   │   ├── auth.py                   # 认证路由
│   │   ├── diary.py                  # 日记路由
│   │   ├── challenge.py              # 挑战路由
│   │   └── user.py                   # 用户路由
│   ├── services/
│   │   ├── __init__.py
│   │   ├── auth_service.py           # 认证服务
│   │   ├── diary_service.py          # 日记业务逻辑
│   │   ├── challenge_service.py      # 挑战业务逻辑
│   │   └── encryption_service.py     # 加密服务
│   ├── middleware/
│   │   ├── __init__.py
│   │   ├── auth_middleware.py        # JWT认证中间件
│   │   └── error_handler.py          # 错误处理
│   └── utils/
│       ├── __init__.py
│       ├── jwt_helper.py             # JWT工具
│       ├── validators.py             # 验证工具
│       └── decorators.py             # 装饰器
├── migrations/                       # 数据库迁移文件
├── tests/
│   ├── __init__.py
│   ├── test_auth.py
│   ├── test_diary.py
│   └── test_challenge.py
├── requirements.txt                  # Python依赖
├── .env.example                      # 环境变量示例
├── .env                              # 环境变量（不提交到git）
└── README.md
```

## 技术栈详细说明

### Flutter 前端
- **状态管理**: Provider
- **网络请求**: http / dio
- **本地存储**: shared_preferences
- **路由**: go_router
- **UI组件**: Material Design 3

### Python 后端
- **框架**: Flask 3.x 或 FastAPI
- **ORM**: SQLAlchemy
- **数据库**: MySQL 8.0 / PostgreSQL
- **认证**: Flask-JWT-Extended / JWT
- **数据验证**: Marshmallow / Pydantic
- **数据库迁移**: Alembic / Flask-Migrate
- **密码加密**: Bcrypt
- **API文档**: Flask-RESTX / Swagger

## 开发阶段

### Phase 1 - 核心功能 (MVP)
1. 用户认证（注册/登录）
2. 情绪遗产日记的创建和查看
3. 基础的标签系统

### Phase 2 - 扩展功能
1. 新回应挑战功能
2. 数据可视化
3. 高级筛选和搜索

### Phase 3 - 增强功能
1. 内容库
2. 数据导出
3. 云同步优化
