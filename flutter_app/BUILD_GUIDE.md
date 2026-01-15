# Flutter应用编译安装指南

## 📱 Android手机安装

### 方法一：开发调试安装（推荐新手）

#### 1. 准备工作

**手机设置：**
1. 打开手机的"开发者选项"
   - 进入"设置" → "关于手机"
   - 连续点击"版本号"7次，开启开发者模式
2. 在"开发者选项"中启用：
   - ✅ USB调试
   - ✅ 安装未知来源应用（某些手机需要）

**电脑准备：**
1. 确保已安装Flutter SDK
2. 使用USB数据线连接手机和电脑

#### 2. 检查设备连接

```bash
cd c:\Users\cxl\Desktop\selfimprove\flutter_app

# 查看已连接的设备
flutter devices
```

你应该看到类似输出：
```
Android SDK built for x86 (mobile) • emulator-5554 • android-x86 • ...
HONOR XXX (mobile)                 • XXXXXXXXX     • android-arm64 • Android 12 (API 31)
```

#### 3. 安装依赖

```bash
# 获取所有依赖包
flutter pub get
```

#### 4. 直接运行到手机

```bash
# 运行Debug版本（开发测试用）
flutter run

# 如果有多个设备，指定设备ID
flutter run -d 设备ID
```

应用会自动安装并启动在你的手机上。

#### 5. 热重载开发

运行后，在终端输入：
- `r` - 热重载（快速刷新界面）
- `R` - 热重启（完全重启应用）
- `q` - 退出

---

### 方法二：生成APK安装包（推荐分享）

#### 1. 构建Release APK

```bash
cd c:\Users\cxl\Desktop\selfimprove\flutter_app

# 构建通用APK（兼容所有架构，体积较大）
flutter build apk

# 构建分架构APK（体积更小，推荐）
flutter build apk --split-per-abi
```

#### 2. 找到APK文件

构建完成后，APK文件位于：
```
c:\Users\cxl\Desktop\selfimprove\flutter_app\build\app\outputs\flutter-apk\
```

**文件说明：**
- `app-release.apk` - 通用APK（约30-50MB）
- `app-armeabi-v7a-release.apk` - 32位ARM（老设备）
- `app-arm64-v8a-release.apk` - 64位ARM（大多数现代手机）
- `app-x86_64-release.apk` - x86架构（模拟器或特殊设备）

**选择安装文件：**
- 大多数现代手机（2018年后）：使用 `app-arm64-v8a-release.apk`
- 不确定的话：使用 `app-release.apk`

#### 3. 安装到手机

**方式A：通过USB安装**
```bash
# 使用adb安装
adb install build\app\outputs\flutter-apk\app-release.apk
```

**方式B：直接传输安装**
1. 将APK文件复制到手机
2. 在手机上打开文件管理器
3. 点击APK文件安装

---

### 方法三：生成App Bundle（上传应用商店）

如果要发布到Google Play：

```bash
# 构建App Bundle
flutter build appbundle

# 文件位置：
# build\app\outputs\bundle\release\app-release.aab
```

---

## 🍎 iOS手机安装

### 前提条件
- Mac电脑
- Xcode已安装
- Apple开发者账号（免费或付费）

### 步骤

```bash
cd c:\Users\cxl\Desktop\selfimprove\flutter_app

# iOS只能在Mac上构建
flutter build ios

# 或直接运行到连接的iPhone
flutter run -d iphone
```

---

## ⚡ 快速命令参考

```bash
# 检查Flutter环境
flutter doctor

# 查看已连接设备
flutter devices

# 清理构建缓存
flutter clean

# 重新获取依赖
flutter pub get

# 运行Debug版本（开发用）
flutter run

# 构建Release APK
flutter build apk --release

# 构建分架构APK（推荐）
flutter build apk --split-per-abi

# 安装APK到手机
adb install 文件路径.apk

# 卸载应用
adb uninstall com.example.emotion_legacy
```

---

## 🔧 常见问题

### 1. 找不到设备

**问题：** `flutter devices` 没有显示手机

**解决方案：**
- 检查USB数据线是否正常（建议使用原装线）
- 确认手机已开启USB调试
- 在手机上允许USB调试授权弹窗
- 重新插拔USB数据线
- 尝试更换USB接口
- 检查驱动：`adb devices`

### 2. 构建失败

**错误：** Gradle build failed

**解决方案：**
```bash
# 清理项目
flutter clean

# 删除构建缓存
rd /s /q build

# 重新获取依赖
flutter pub get

# 重新构建
flutter build apk
```

### 3. 应用无法安装

**问题：** 手机提示"无法安装"

**解决方案：**
- 检查手机存储空间是否充足
- 确保已启用"安装未知来源应用"
- 如果已安装旧版本，先卸载再安装
- 检查APK文件是否完整（重新构建）

### 4. 应用闪退

**问题：** 打开应用后立即闪退

**解决方案：**
- 检查后端API地址配置是否正确
- 查看日志：`flutter logs` 或 `adb logcat`
- 确保手机架构与APK匹配
- 使用Debug版本查看详细错误

### 5. 网络请求失败

**问题：** 应用无法连接后端

**解决方案：**
- 确保手机和电脑在同一网络
- 检查 `lib/config/api_config.dart` 中的API地址
- Android需要在 `AndroidManifest.xml` 中添加网络权限
- 如果使用HTTPS，确保证书有效

---

## 📋 配置检查清单

在构建前确认：

### API配置
```dart
// lib/config/api_config.dart
class ApiConfig {
  // 开发环境：使用电脑IP
  static const String baseUrl = 'http://192.168.x.x:8000';
  
  // 生产环境：使用服务器地址
  // static const String baseUrl = 'https://api.yourdomain.com';
}
```

### Android权限
检查 `android/app/src/main/AndroidManifest.xml`：
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

### 应用签名（发布版本需要）
检查 `android/app/build.gradle`：
```gradle
android {
    signingConfigs {
        release {
            // 签名配置
        }
    }
}
```

---

## 🎯 推荐工作流程

### 日常开发
```bash
# 1. 连接手机
# 2. 运行应用
flutter run

# 3. 修改代码后按 'r' 热重载
# 4. 测试功能
```

### 测试版本分享
```bash
# 1. 构建APK
flutter build apk --split-per-abi

# 2. 找到APK文件
# build\app\outputs\flutter-apk\app-arm64-v8a-release.apk

# 3. 通过微信/QQ/蓝牙分享给其他人
```

### 正式发布
```bash
# 1. 配置签名
# 2. 更新版本号（pubspec.yaml）
# 3. 构建App Bundle
flutter build appbundle

# 4. 上传到Google Play Console
```

---

## 📱 第一次安装详细步骤

### 完整流程（新手友好）

1. **连接手机**
   ```bash
   # 使用USB数据线连接手机
   # 手机上点击"允许USB调试"
   ```

2. **检查连接**
   ```bash
   cd c:\Users\cxl\Desktop\selfimprove\flutter_app
   flutter devices
   ```

3. **获取依赖**
   ```bash
   flutter pub get
   ```

4. **直接运行（推荐）**
   ```bash
   flutter run
   # 等待编译完成，应用会自动安装到手机
   ```

   或者

   **构建APK**
   ```bash
   flutter build apk --release
   # 等待构建完成
   ```

5. **安装APK**
   ```bash
   # 方式1：命令行安装
   adb install build\app\outputs\flutter-apk\app-release.apk
   
   # 方式2：手动安装
   # 将 build\app\outputs\flutter-apk\app-release.apk 发送到手机
   # 在手机上点击安装
   ```

6. **打开应用**
   - 在手机应用列表找到"情绪遗产"
   - 点击打开

---

## 🆘 需要帮助？

如果遇到问题：
1. 查看Flutter日志：`flutter logs`
2. 查看设备日志：`adb logcat`
3. 检查Flutter环境：`flutter doctor -v`
4. 清理并重试：`flutter clean && flutter pub get`

**常用调试命令：**
```bash
# 查看应用日志
flutter logs

# 查看详细设备信息
adb devices -l

# 重启adb服务
adb kill-server
adb start-server

# 查看手机信息
adb shell getprop ro.product.model
adb shell getprop ro.build.version.release
```
