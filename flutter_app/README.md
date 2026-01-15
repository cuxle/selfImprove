# 情绪遗产 - Flutter App

基于 Flutter 构建的跨平台心理健康自我觉察应用。

## 功能特性

- ✅ 用户认证（注册/登录）
- ✅ 情绪遗产日记记录
- ✅ 新回应挑战管理
- ✅ 情绪强度可视化
- ✅ 跨平台支持（iOS/Android/Web）

## 技术栈

- **框架**: Flutter 3.x
- **状态管理**: Provider
- **网络请求**: http
- **本地存储**: shared_preferences
- **日期格式化**: intl

## 项目结构

```
flutter_app/
├── lib/
│   ├── config/              # 配置文件
│   │   ├── api_config.dart
│   │   └── app_config.dart
│   ├── models/              # 数据模型
│   │   ├── user.dart
│   │   ├── emotion_diary.dart
│   │   └── response_challenge.dart
│   ├── services/            # API服务层
│   │   ├── api_service.dart
│   │   ├── auth_service.dart
│   │   ├── diary_service.dart
│   │   └── challenge_service.dart
│   ├── providers/           # 状态管理
│   │   ├── auth_provider.dart
│   │   ├── diary_provider.dart
│   │   └── challenge_provider.dart
│   ├── screens/             # 界面
│   │   ├── auth/
│   │   ├── diary/
│   │   ├── challenge/
│   │   └── home/
│   └── main.dart            # 应用入口
├── pubspec.yaml             # 依赖配置
└── README.md
```

## 快速开始

### 1. 环境要求

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / Xcode (用于移动端开发)

### 2. 安装依赖

```bash
cd flutter_app
flutter pub get
```

### 3. 配置API地址

编辑 `lib/config/api_config.dart`：

```dart
class ApiConfig {
  // 修改为你的后端API地址
  static const String devBaseUrl = 'http://localhost:8000/api/v1';

  // 如果使用Android模拟器，使用以下地址
  // static const String devBaseUrl = 'http://10.0.2.2:8000/api/v1';
}
```

### 4. 运行应用

```bash
# 查看可用设备
flutter devices

# 在特定设备上运行
flutter run -d <device-id>

# 在Chrome浏览器运行（Web版）
flutter run -d chrome

# Android模拟器
flutter run -d android

# iOS模拟器
flutter run -d ios
```

## 开发指南

### 添加新的API端点

1. 在 `lib/config/api_config.dart` 添加端点常量
2. 在相应的 Service 类中实现调用方法
3. 在相应的 Provider 中添加状态管理逻辑

### 添加新的界面

1. 在 `lib/screens/` 下创建新的目录
2. 创建界面文件
3. 在路由中注册（如需要）

### 状态管理

使用 Provider 进行状态管理：

```dart
// 获取 Provider
final authProvider = Provider.of<AuthProvider>(context, listen: false);

// 监听 Provider
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    return Text(authProvider.user?.username ?? '');
  },
)
```

## API集成

应用通过以下服务与后端通信：

- `AuthService`: 用户认证（注册/登录）
- `DiaryService`: 日记CRUD操作
- `ChallengeService`: 挑战CRUD操作

所有服务都使用 `ApiService` 基类进行HTTP请求，并自动处理：
- JWT认证
- 错误处理
- Token管理

## 构建发布版本

### Android

```bash
flutter build apk --release
# 或构建App Bundle
flutter build appbundle --release
```

生成的文件位于：`build/app/outputs/`

### iOS

```bash
flutter build ios --release
```

然后在 Xcode 中打开项目进行签名和发布。

### Web

```bash
flutter build web --release
```

生成的文件位于：`build/web/`

## 调试技巧

### 网络请求调试

在 `lib/services/api_service.dart` 中添加打印语句：

```dart
Future<Map<String, dynamic>> post(...) async {
  print('Request URL: ${ApiConfig.baseUrl}$endpoint');
  print('Request Body: $body');
  // ...
}
```

### 使用DevTools

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

## 常见问题

### Q: Android模拟器无法连接localhost

A: 使用 `10.0.2.2` 替代 `localhost`：
```dart
static const String devBaseUrl = 'http://10.0.2.2:8000/api/v1';
```

### Q: iOS真机调试网络请求失败

A: 检查 `info.plist` 中的网络权限配置。

### Q: 状态未更新

A: 确保调用了 `notifyListeners()`，并且使用 `Consumer` 或 `context.watch()` 监听。

## 待实现功能

- [ ] 日记详情页面
- [ ] 挑战详情页面
- [ ] 数据可视化图表
- [ ] 情绪趋势分析
- [ ] 数据导出功能
- [ ] 深色模式

## 许可证

MIT License
