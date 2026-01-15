# 微信登录集成文档

## 概述

本项目已集成微信登录功能，支持用户通过微信账号快速登录应用。

## 实现方式

### 1. 后端实现

#### 数据库模型更新
在 `User` 模型中添加了以下字段：
- `wechat_openid`: 微信openid（唯一标识）
- `wechat_unionid`: 微信unionid（跨应用唯一标识）
- `avatar_url`: 用户头像URL
- `nickname`: 微信昵称
- `email` 和 `password_hash` 现在允许为空（微信登录用户不需要）

#### API 端点
- **POST** `/auth/wechat/login`
  - 请求体: `{"code": "微信授权码"}`
  - 返回: `{"access_token": "JWT令牌", "token_type": "bearer"}`
  - 说明: 前端获取微信授权码后，调用此接口完成登录/注册

#### 工作流程
1. 前端通过微信SDK获取授权码（code）
2. 前端将code发送到后端 `/auth/wechat/login` 接口
3. 后端验证code并从微信服务器获取用户信息
4. 如果用户不存在，自动创建新用户
5. 如果用户已存在，更新用户的微信信息
6. 返回JWT令牌给前端

## 配置说明

### 1. 微信开放平台配置

在 `backend/app/utils/wechat_helper.py` 中配置你的微信应用信息：

```python
class WeChatConfig:
    # 移动应用（App）微信登录配置
    APP_ID: str = "你的AppID"  # 在微信开放平台申请
    APP_SECRET: str = "你的AppSecret"  # 在微信开放平台申请
```

**获取AppID和AppSecret的步骤：**
1. 访问 [微信开放平台](https://open.weixin.qq.com/)
2. 注册开发者账号
3. 创建移动应用
4. 填写应用信息（应用名称、图标、应用签名等）
5. 提交审核，审核通过后获得AppID和AppSecret

### 2. 数据库迁移

添加微信相关字段后，需要运行数据库迁移：

```bash
# 生成迁移文件
alembic revision --autogenerate -m "add wechat login fields"

# 执行迁移
alembic upgrade head
```

或者直接修改数据库表结构：

```sql
ALTER TABLE users 
    MODIFY COLUMN email VARCHAR(100) NULL,
    MODIFY COLUMN password_hash VARCHAR(255) NULL,
    ADD COLUMN wechat_openid VARCHAR(100) UNIQUE NULL,
    ADD COLUMN wechat_unionid VARCHAR(100) UNIQUE NULL,
    ADD COLUMN avatar_url VARCHAR(500) NULL,
    ADD COLUMN nickname VARCHAR(100) NULL,
    ADD INDEX idx_wechat_openid (wechat_openid),
    ADD INDEX idx_wechat_unionid (wechat_unionid);
```

### 3. 安装依赖

```bash
cd backend
pip install -r requirements.txt
```

新增依赖：`httpx==0.26.0`（用于调用微信API）

## 前端集成（Flutter）

### 1. 安装微信SDK

在 `pubspec.yaml` 中添加：

```yaml
dependencies:
  fluwx: ^4.4.0  # Flutter微信SDK
```

### 2. 配置微信SDK

在 `lib/main.dart` 中初始化微信SDK：

```dart
import 'package:fluwx/fluwx.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化微信SDK
  await registerWxApi(
    appId: "你的AppID",  // 与后端配置的相同
    doOnAndroid: true,
    doOnIOS: true,
    universalLink: "你的iOS Universal Link",  // 仅iOS需要
  );
  
  runApp(MyApp());
}
```

### 3. 实现微信登录

创建微信登录服务：

```dart
// lib/services/wechat_service.dart
import 'package:fluwx/fluwx.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeChatService {
  // 发起微信登录
  Future<String?> wechatLogin() async {
    // 1. 发起微信授权
    final result = await sendWeChatAuth(
      scope: "snsapi_userinfo",
      state: "wechat_login"
    );
    
    if (!result) {
      return null;
    }
    
    // 2. 监听微信回调
    final response = await weChatResponseEventHandler.first;
    
    if (response is WeChatAuthResponse && response.code != null) {
      // 3. 将code发送到后端
      return await _loginWithCode(response.code!);
    }
    
    return null;
  }
  
  // 调用后端接口完成登录
  Future<String?> _loginWithCode(String code) async {
    final url = Uri.parse('http://your-api.com/auth/wechat/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'code': code}),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access_token'];
    }
    
    return null;
  }
}
```

### 4. 在登录页面使用

```dart
// lib/screens/auth/login_screen.dart
ElevatedButton.icon(
  icon: Icon(Icons.wechat),
  label: Text('微信登录'),
  onPressed: () async {
    final wechatService = WeChatService();
    final token = await wechatService.wechatLogin();
    
    if (token != null) {
      // 保存token并跳转到主页
      await storage.write(key: 'token', value: token);
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // 显示错误提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('微信登录失败')),
      );
    }
  },
)
```

## Android 配置

### 1. 修改 `AndroidManifest.xml`

```xml
<manifest>
    <application>
        <!-- 微信登录回调 -->
        <activity
            android:name=".wxapi.WXEntryActivity"
            android:label="@string/app_name"
            android:theme="@android:style/Theme.Translucent.NoTitleBar"
            android:exported="true"
            android:taskAffinity="你的包名"
            android:launchMode="singleTask">
        </activity>
    </application>
</manifest>
```

### 2. 应用签名

微信登录需要正确的应用签名，需要：
1. 生成签名文件
2. 在微信开放平台填写应用签名
3. 在 `build.gradle` 中配置签名

## iOS 配置

### 1. 配置 URL Scheme

在 `Info.plist` 中添加：

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>你的AppID</string>
        </array>
    </dict>
</array>
```

### 2. 配置 Universal Link

需要在你的服务器上部署 Universal Link 配置文件。

## 测试

### 1. 测试后端API

```bash
# 使用微信开发者工具获取测试code，然后：
curl -X POST http://localhost:8000/auth/wechat/login \
  -H "Content-Type: application/json" \
  -d '{"code": "测试授权码"}'
```

### 2. 测试前端

1. 在真机上运行应用（微信登录不支持模拟器）
2. 确保已安装微信客户端
3. 点击"微信登录"按钮
4. 授权后应自动返回应用并完成登录

## 注意事项

1. **开发环境**: 微信登录必须在真机上测试，不支持模拟器
2. **应用签名**: Android应用签名必须与微信开放平台配置的一致
3. **AppID**: 前端和后端的AppID必须一致
4. **审核**: 微信开放平台应用需要审核通过才能正式使用
5. **安全**: 不要将AppSecret提交到代码仓库，使用环境变量管理

## 账号绑定

如果需要支持微信账号与邮箱账号绑定，可以添加以下接口：

```python
@router.post("/bind/wechat")
async def bind_wechat(
    wechat_data: WeChatLogin,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """绑定微信账号"""
    wechat_info = await wechat_service.verify_and_get_user_info(wechat_data.code)
    
    # 检查该微信是否已被其他账号绑定
    existing = db.query(User).filter(
        User.wechat_openid == wechat_info["openid"]
    ).first()
    
    if existing and existing.id != current_user.id:
        raise HTTPException(
            status_code=400,
            detail="该微信已被其他账号绑定"
        )
    
    # 绑定微信
    current_user.wechat_openid = wechat_info["openid"]
    current_user.wechat_unionid = wechat_info.get("unionid")
    current_user.nickname = wechat_info["nickname"]
    current_user.avatar_url = wechat_info["avatar_url"]
    db.commit()
    
    return {"message": "绑定成功"}
```

## 常见问题

### 1. 获取不到用户信息
- 检查AppID和AppSecret是否正确
- 确认应用已通过微信审核
- 检查网络连接

### 2. Android无法唤起微信
- 检查应用签名是否正确
- 确认已安装微信客户端
- 检查AndroidManifest.xml配置

### 3. iOS无法返回应用
- 检查URL Scheme配置
- 确认Universal Link配置正确
- 检查Info.plist设置

## 相关链接

- [微信开放平台](https://open.weixin.qq.com/)
- [微信登录开发指南](https://developers.weixin.qq.com/doc/oplatform/Mobile_App/WeChat_Login/Development_Guide.html)
- [fluwx Flutter插件](https://pub.dev/packages/fluwx)
