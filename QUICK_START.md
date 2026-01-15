# 启动和测试指南

本指南将帮助您一步步启动和测试"情绪遗产"应用。

## 第一步：准备数据库

### 1.1 安装MySQL（如果尚未安装）

下载并安装 MySQL 8.0：https://dev.mysql.com/downloads/mysql/

### 1.2 创建数据库

打开命令行，执行：

```bash
# 登录MySQL
mysql -u root -p
# 输入您的MySQL密码

# 创建数据库
CREATE DATABASE emotion_legacy_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# 查看数据库
SHOW DATABASES;

# 退出
exit;
```

### 1.3 配置数据库连接

编辑 `backend\.env` 文件，修改数据库连接：

```env
DATABASE_URL=mysql+pymysql://root:YOUR_PASSWORD@localhost:3306/emotion_legacy_db
```

将 `YOUR_PASSWORD` 替换为您的MySQL密码。

## 第二步：启动后端服务

### 2.1 安装Python依赖

```bash
cd backend
pip install -r requirements.txt
```

### 2.2 启动后端

**方法1：使用启动脚本（推荐）**
```bash
start.bat
```

**方法2：手动启动**
```bash
python -m uvicorn app.main:app --reload
```

### 2.3 验证后端启动成功

浏览器访问：
- **API文档**: http://localhost:8000/docs
- **健康检查**: http://localhost:8000/health

如果看到Swagger UI文档页面，说明后端启动成功！

## 第三步：测试后端API

### 3.1 使用Swagger UI测试

访问 http://localhost:8000/docs，您会看到所有API端点。

#### 测试注册接口

1. 找到 `POST /api/v1/auth/register`
2. 点击 "Try it out"
3. 输入测试数据：
```json
{
  "username": "testuser",
  "email": "test@example.com",
  "password": "123456"
}
```
4. 点击 "Execute"
5. 查看响应（应该返回201和用户信息）

#### 测试登录接口

1. 找到 `POST /api/v1/auth/login`
2. 点击 "Try it out"
3. 输入：
```json
{
  "email": "test@example.com",
  "password": "123456"
}
```
4. 点击 "Execute"
5. 复制返回的 `access_token`

#### 测试需要认证的接口

1. 点击页面右上角的 "Authorize" 按钮
2. 在弹窗中输入：`Bearer YOUR_ACCESS_TOKEN`
   （将YOUR_ACCESS_TOKEN替换为刚才复制的token）
3. 点击 "Authorize"
4. 现在可以测试其他需要认证的接口了

#### 测试创建日记

1. 找到 `POST /api/v1/diaries`
2. 点击 "Try it out"
3. 输入：
```json
{
  "trigger_event": "今天工作时被批评了",
  "immediate_emotion": "愤怒和委屈",
  "emotion_intensity": 7,
  "physical_reaction": "心跳加速，胸口发紧",
  "auto_thought": "我总是做不好",
  "childhood_memory": "想起小时候被父母责骂的场景",
  "pattern_recognition": "我发现每次被批评都会有这种强烈的情绪反应",
  "tag_ids": []
}
```
4. 点击 "Execute"
5. 应该返回201和创建的日记

#### 测试获取日记列表

1. 找到 `GET /api/v1/diaries`
2. 点击 "Try it out"
3. 点击 "Execute"
4. 应该看到刚才创建的日记

### 3.2 检查数据库

```bash
mysql -u root -p
USE emotion_legacy_db;

# 查看所有表
SHOW TABLES;

# 查看用户表
SELECT * FROM users;

# 查看日记表
SELECT * FROM emotion_diaries;

exit;
```

## 第四步：启动Flutter前端

### 4.1 检查Flutter环境

```bash
flutter doctor
```

确保没有严重错误。

### 4.2 安装依赖

```bash
cd flutter_app
flutter pub get
```

### 4.3 配置API地址（如果需要）

编辑 `lib/config/api_config.dart`：

```dart
static const String devBaseUrl = 'http://localhost:8000/api/v1';
```

**注意**：
- 如果使用Android模拟器，改为：`http://10.0.2.2:8000/api/v1`
- 如果使用iOS模拟器/真机，确保使用同一WiFi，改为：`http://YOUR_IP:8000/api/v1`

### 4.4 运行Flutter应用

**Web版（推荐用于开发测试）：**
```bash
flutter run -d chrome
```

**Android模拟器：**
```bash
flutter run -d android
```

**查看可用设备：**
```bash
flutter devices
```

## 第五步：测试完整流程

### 5.1 测试注册和登录

1. 打开Flutter应用
2. 点击"立即注册"
3. 输入：
   - 用户名：`flutter_user`
   - 邮箱：`flutter@example.com`
   - 密码：`123456`
4. 点击"注册"
5. 应该自动登录并进入主页

### 5.2 测试创建日记

1. 在主页底部导航选择"日记"
2. 点击右下角"+"按钮
3. 填写日记信息：
   - 触发事件：`测试Flutter应用`
   - 即时情绪：`兴奋`
   - 情绪强度：拖动滑块到 `8`
4. 点击"保存日记"
5. 应该返回列表并看到新创建的日记

### 5.3 测试创建挑战

1. 底部导航选择"挑战"
2. 点击右下角"+"按钮
3. 填写挑战信息：
   - 挑战标题：`面对批评时保持冷静`
   - 旧的反应：`立刻感到愤怒和防御`
   - 新的回应：`深呼吸，理性分析批评的合理性`
   - 难度等级：选择 `4`
4. 点击"创建挑战"
5. 应该返回列表并看到新创建的挑战

### 5.4 测试登出

1. 底部导航选择"我的"
2. 点击"退出登录"
3. 确认退出
4. 应该返回登录界面

### 5.5 测试再次登录

1. 使用刚才注册的账号登录
2. 应该能看到之前创建的日记和挑战

## 常见问题排查

### 后端问题

#### 问题1：数据库连接失败
```
sqlalchemy.exc.OperationalError: (pymysql.err.OperationalError) (2003, "Can't connect to MySQL server")
```

**解决方案**：
1. 检查MySQL服务是否启动
2. 检查 `.env` 文件中的数据库配置
3. 确认数据库已创建

#### 问题2：模块未找到
```
ModuleNotFoundError: No module named 'fastapi'
```

**解决方案**：
```bash
pip install -r requirements.txt
```

#### 问题3：端口已被占用
```
ERROR:    [Errno 10048] error while attempting to bind on address ('0.0.0.0', 8000)
```

**解决方案**：
更改端口或关闭占用8000端口的程序
```bash
uvicorn app.main:app --reload --port 8001
```

### 前端问题

#### 问题1：网络请求失败
```
SocketException: Failed host lookup: 'localhost'
```

**解决方案（Android模拟器）**：
修改 `api_config.dart` 中的地址为 `http://10.0.2.2:8000/api/v1`

#### 问题2：CORS错误（Web版）
```
Access to XMLHttpRequest at 'http://localhost:8000' has been blocked by CORS policy
```

**解决方案**：
检查后端 `.env` 文件的 ALLOWED_ORIGINS 配置

#### 问题3：依赖安装失败
```
pub get failed
```

**解决方案**：
```bash
flutter clean
flutter pub get
```

## 测试检查清单

完成以下所有测试，确保应用正常运行：

### 后端测试
- [ ] 后端成功启动
- [ ] API文档可访问
- [ ] 用户注册成功
- [ ] 用户登录成功并获得token
- [ ] 创建日记成功
- [ ] 获取日记列表成功
- [ ] 创建挑战成功
- [ ] 获取挑战列表成功

### 前端测试
- [ ] Flutter应用成功启动
- [ ] 注册界面显示正常
- [ ] 用户注册成功
- [ ] 自动登录到主页
- [ ] 日记列表显示正常
- [ ] 创建日记功能正常
- [ ] 挑战列表显示正常
- [ ] 创建挑战功能正常
- [ ] 个人资料页显示用户信息
- [ ] 退出登录功能正常
- [ ] 再次登录数据保持

## 下一步

全部测试通过后，您可以：

1. **开始使用应用** - 真实地记录您的情绪和挑战
2. **添加更多功能** - 参考 README.md 中的待实现功能
3. **美化界面** - 优化UI设计和用户体验
4. **部署上线** - 将应用部署到服务器和应用商店

## 需要帮助？

如果遇到问题：
1. 检查上面的"常见问题排查"
2. 查看后端日志（终端输出）
3. 查看Flutter控制台输出
4. 使用浏览器开发者工具查看网络请求
