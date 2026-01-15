import '../config/api_config.dart';
import '../models/user.dart';
import 'api_service.dart';

// 请求和响应模型
class RegisterRequest {
  final String username;
  final String email;
  final String password;

  RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'email': email,
        'password': password,
      };
}

class LoginRequest {
  final String account;
  final String password;

  LoginRequest({
    required this.account,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'account': account,
        'password': password,
      };
}

class PhoneSendCodeRequest {
  final String phone;

  PhoneSendCodeRequest({required this.phone});

  Map<String, dynamic> toJson() => {'phone': phone};
}

class PhoneLoginRequest {
  final String phone;
  final String code;

  PhoneLoginRequest({
    required this.phone,
    required this.code,
  });

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'code': code,
      };
}

class AuthResponse {
  final String accessToken;
  final String tokenType;

  AuthResponse({
    required this.accessToken,
    required this.tokenType,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
    );
  }
}

class SendCodeResponse {
  final String message;
  final String? code; // 仅开发模式返回

  SendCodeResponse({
    required this.message,
    this.code,
  });

  factory SendCodeResponse.fromJson(Map<String, dynamic> json) {
    return SendCodeResponse(
      message: json['message'] as String,
      code: json['code'] as String?,
    );
  }
}

class AuthService {
  final ApiService _apiService = ApiService();

  // 用户注册
  Future<User> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final request = RegisterRequest(
      username: username,
      email: email,
      password: password,
    );

    final response = await _apiService.post(
      ApiConfig.register,
      body: request.toJson(),
      needsAuth: false,
    );

    return User.fromJson(response);
  }

  // 用户登录
  Future<AuthResponse> login({
    required String account,
    required String password,
  }) async {
    final request = LoginRequest(
      account: account,
      password: password,
    );

    final response = await _apiService.post(
      ApiConfig.login,
      body: request.toJson(),
      needsAuth: false,
    );

    final authResponse = AuthResponse.fromJson(response);

    // 保存Token
    await _apiService.saveToken(authResponse.accessToken);

    return authResponse;
  }

  // 获取当前用户信息
  Future<User> getCurrentUser() async {
    final response = await _apiService.get(
      ApiConfig.me,
      needsAuth: true,
    );

    return User.fromJson(response);
  }

  // 登出
  Future<void> logout() async {
    await _apiService.removeToken();
  }

  // 检查是否已登录
  Future<bool> isLoggedIn() async {
    final token = await _apiService.getToken();
    return token != null;
  }

  // 获取Token
  Future<String?> getToken() async {
    return await _apiService.getToken();
  }

  // 发送手机验证码
  Future<SendCodeResponse> sendPhoneCode({required String phone}) async {
    final request = PhoneSendCodeRequest(phone: phone);

    final response = await _apiService.post(
      ApiConfig.phoneSendCode,
      body: request.toJson(),
      needsAuth: false,
    );

    return SendCodeResponse.fromJson(response);
  }

  // 手机号验证码登录
  Future<AuthResponse> phoneLogin({
    required String phone,
    required String code,
  }) async {
    final request = PhoneLoginRequest(
      phone: phone,
      code: code,
    );

    final response = await _apiService.post(
      ApiConfig.phoneLogin,
      body: request.toJson(),
      needsAuth: false,
    );

    final authResponse = AuthResponse.fromJson(response);

    // 保存Token
    await _apiService.saveToken(authResponse.accessToken);

    return authResponse;
  }

  // 请求密码重置（发送验证码）
  Future<SendCodeResponse> requestPasswordReset({required String phone}) async {
    final request = PhoneSendCodeRequest(phone: phone);

    final response = await _apiService.post(
      ApiConfig.passwordResetRequest,
      body: request.toJson(),
      needsAuth: false,
    );

    return SendCodeResponse.fromJson(response);
  }

  // 确认密码重置
  Future<void> confirmPasswordReset({
    required String phone,
    required String code,
    required String newPassword,
  }) async {
    final request = {
      'phone': phone,
      'code': code,
      'new_password': newPassword,
    };

    await _apiService.post(
      ApiConfig.passwordResetConfirm,
      body: request,
      needsAuth: false,
    );
  }
}
