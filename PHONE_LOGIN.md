# 手机号验证码登录集成文档

## 概述

本项目已集成手机号验证码登录功能，支持用户通过手机号和验证码快速登录应用。

## 功能特性

- ✅ 手机号格式验证
- ✅ 验证码发送频率限制（60秒）
- ✅ 验证码有效期控制（5分钟）
- ✅ 自动注册新用户
- ✅ 支持多种短信服务商（阿里云、腾讯云）
- ✅ 开发环境模拟模式

## 数据库变更

在 `User` 模型中添加了以下字段：
- `phone`: 手机号（唯一索引）

需要执行数据库迁移：
```bash
cd backend
alembic revision --autogenerate -m "Add phone field to users"
alembic upgrade head
```

## API 端点

### 1. 发送验证码

**POST** `/auth/phone/send-code`

**请求体:**
```json
{
  "phone": "13800138000"
}
```

**响应（成功）:**
```json
{
  "message": "验证码已发送（开发模式）",
  "code": "123456"  // 仅开发模式返回
}
```

**响应（频率限制）:**
```json
{
  "detail": "发送过于频繁，请30秒后再试"
}
```

### 2. 验证码登录

**POST** `/auth/phone/login`

**请求体:**
```json
{
  "phone": "13800138000",
  "code": "123456"
}
```

**响应（成功）:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "bearer"
}
```

**响应（验证码错误）:**
```json
{
  "detail": "验证码错误或已过期"
}
```

## 工作流程

1. 用户输入手机号，点击"获取验证码"
2. 前端调用 `/auth/phone/send-code` 接口
3. 后端发送验证码短信到用户手机
4. 用户输入收到的验证码
5. 前端调用 `/auth/phone/login` 接口
6. 后端验证验证码，如果用户不存在则自动注册
7. 返回JWT令牌给前端

## 配置说明

### 开发环境（Mock模式）

默认配置，不发送真实短信，直接在控制台输出验证码。

在 `backend/app/utils/sms_helper.py` 中：
```python
class SMSConfig:
    PROVIDER: str = "mock"  # 使用模拟模式
```

### 生产环境 - 阿里云短信

1. **安装依赖**
```bash
pip install alibabacloud_dysmsapi20170525
```

2. **配置参数**
```python
class SMSConfig:
    PROVIDER: str = "aliyun"
    ALIYUN_ACCESS_KEY_ID: str = "your_access_key_id"
    ALIYUN_ACCESS_KEY_SECRET: str = "your_access_key_secret"
    ALIYUN_SIGN_NAME: str = "your_sign_name"
    ALIYUN_TEMPLATE_CODE: str = "SMS_123456789"
```

3. **获取配置信息**
   - 访问 [阿里云短信服务](https://dysms.console.aliyun.com/)
   - 创建AccessKey
   - 申请短信签名
   - 申请短信模板（变量格式：`${code}`）

### 生产环境 - 腾讯云短信

1. **安装依赖**
```bash
pip install tencentcloud-sdk-python
```

2. **配置参数**
```python
class SMSConfig:
    PROVIDER: str = "tencent"
    TENCENT_SECRET_ID: str = "your_secret_id"
    TENCENT_SECRET_KEY: str = "your_secret_key"
    TENCENT_SMS_SDK_APP_ID: str = "your_app_id"
    TENCENT_SIGN_NAME: str = "your_sign_name"
    TENCENT_TEMPLATE_ID: str = "123456"
```

3. **获取配置信息**
   - 访问 [腾讯云短信服务](https://console.cloud.tencent.com/smsv2)
   - 创建应用并获取SDK AppID
   - 创建API密钥（SecretId和SecretKey）
   - 申请短信签名
   - 申请短信模板

## 验证码配置

可在 `SMSConfig` 类中调整：

```python
class SMSConfig:
    CODE_LENGTH: int = 6  # 验证码长度
    CODE_EXPIRE_MINUTES: int = 5  # 验证码有效期（分钟）
    RATE_LIMIT_SECONDS: int = 60  # 发送间隔（秒）
```

## 前端集成示例

### Flutter 示例

```dart
// 1. 发送验证码
Future<void> sendCode(String phone) async {
  try {
    final response = await http.post(
      Uri.parse('${apiUrl}/auth/phone/send-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('验证码已发送: ${data['message']}');
      // 开发模式下可以获取验证码
      if (data.containsKey('code')) {
        print('验证码: ${data['code']}');
      }
    } else {
      final error = jsonDecode(response.body);
      print('发送失败: ${error['detail']}');
    }
  } catch (e) {
    print('请求失败: $e');
  }
}

// 2. 验证码登录
Future<void> loginWithPhone(String phone, String code) async {
  try {
    final response = await http.post(
      Uri.parse('${apiUrl}/auth/phone/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'code': code}),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['access_token'];
      // 保存token
      await storage.write(key: 'token', value: token);
      print('登录成功');
    } else {
      final error = jsonDecode(response.body);
      print('登录失败: ${error['detail']}');
    }
  } catch (e) {
    print('请求失败: $e');
  }
}
```

## 安全建议

### 生产环境必须配置：

1. **使用Redis存储验证码**
   - 当前实现使用内存存储，重启服务会丢失
   - 生产环境应使用Redis替代 `_code_storage`

2. **手机号加密存储**
   - 对手机号进行加密或脱敏处理

3. **IP限制**
   - 限制单个IP的请求频率
   - 防止恶意刷验证码

4. **验证码复杂度**
   - 可以增加验证码长度
   - 使用字母+数字组合

5. **监控和告警**
   - 监控短信发送量
   - 异常情况及时告警

## 注意事项

1. **手机号格式**：当前仅支持中国大陆手机号（1开头的11位数字）
2. **验证码一次性**：验证成功后验证码立即失效
3. **自动注册**：首次使用手机号登录会自动创建账户
4. **用户名生成**：自动生成格式为 `user_手机号后4位_序号`
5. **费用**：短信服务会产生费用，注意控制发送量

## 常见问题

### Q: 验证码收不到？
A: 
- 检查手机号是否正确
- 确认短信服务商配置正确
- 查看服务器日志是否有错误信息
- 确认短信服务账户余额充足

### Q: 验证码提示已过期？
A: 验证码有效期为5分钟，请在有效期内使用

### Q: 可以修改验证码有效期吗？
A: 可以在 `SMSConfig.CODE_EXPIRE_MINUTES` 中修改

### Q: 如何防止恶意刷验证码？
A: 
- 已实现60秒发送频率限制
- 建议添加图形验证码
- 建议添加IP限制
- 监控异常发送行为

## 未来优化方向

- [ ] 集成Redis存储验证码
- [ ] 添加图形验证码
- [ ] IP频率限制
- [ ] 支持国际手机号
- [ ] 手机号绑定功能（已有账户绑定手机号）
- [ ] 手机号找回密码
- [ ] 发送记录和统计
