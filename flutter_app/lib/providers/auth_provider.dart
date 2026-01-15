import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  String? _error;
  String? _token;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  String? get token => _token;

  // 初始化 - 检查是否已登录
  Future<void> init() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        _token = await _authService.getToken();
        await getCurrentUser();
      }
    } catch (e) {
      _error = e.toString();
    }
  }

  // 用户注册
  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.register(
        username: username,
        email: email,
        password: password,
      );

      // 注册成功后自动登录
      await login(email: email, password: password);

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '注册失败: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 用户登录
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final authResponse = await _authService.login(account: email, password: password);
      _token = authResponse.accessToken;
      await getCurrentUser();

      _isLoading = false;
      notifyListeners();
      return true;
    } on UnauthorizedException catch (e) {
      _error = '用户名/邮箱或密码错误';
      _isLoading = false;
      notifyListeners();
      return false;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '登录失败: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 发送手机验证码
  Future<String?> sendPhoneCode({required String phone}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.sendPhoneCode(phone: phone);
      _isLoading = false;
      notifyListeners();
      
      // 开发模式返回验证码，方便测试
      return response.code;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _error = '发送验证码失败: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // 手机号验证码登录
  Future<bool> phoneLogin({
    required String phone,
    required String code,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final authResponse = await _authService.phoneLogin(phone: phone, code: code);
      _token = authResponse.accessToken;
      await getCurrentUser();

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '登录失败: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 获取当前用户信息
  Future<void> getCurrentUser() async {
    try {
      _user = await _authService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      _error = '获取用户信息失败';
      notifyListeners();
    }
  }

  // 登出
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _token = null;
    _error = null;
    notifyListeners();
  }

  // 请求密码重置（发送验证码）
  Future<String?> requestPasswordReset({required String phone}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.requestPasswordReset(phone: phone);
      _isLoading = false;
      notifyListeners();
      
      // 开发模式返回验证码
      return response.code;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _error = '发送验证码失败: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // 确认密码重置
  Future<bool> confirmPasswordReset({
    required String phone,
    required String code,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.confirmPasswordReset(
        phone: phone,
        code: code,
        newPassword: newPassword,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '密码重置失败: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
