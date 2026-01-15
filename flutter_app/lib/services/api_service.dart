import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  static const String _tokenKey = 'auth_token';

  // 获取认证Token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // 保存认证Token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // 删除认证Token
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // 获取请求头
  Future<Map<String, String>> _getHeaders({bool needsAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (needsAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // GET请求
  Future<Map<String, dynamic>> get(
    String endpoint, {
    bool needsAuth = true,
    Map<String, String>? queryParameters,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint')
          .replace(queryParameters: queryParameters);

      final response = await http.get(
        uri,
        headers: await _getHeaders(needsAuth: needsAuth),
      );

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('网络请求失败: $e');
    }
  }

  // POST请求
  Future<Map<String, dynamic>> post(
    String endpoint, {
    required Map<String, dynamic> body,
    bool needsAuth = true,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: await _getHeaders(needsAuth: needsAuth),
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('网络请求失败: $e');
    }
  }

  // PUT请求
  Future<Map<String, dynamic>> put(
    String endpoint, {
    required Map<String, dynamic> body,
    bool needsAuth = true,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: await _getHeaders(needsAuth: needsAuth),
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('网络请求失败: $e');
    }
  }

  // DELETE请求
  Future<void> delete(
    String endpoint, {
    bool needsAuth = true,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: await _getHeaders(needsAuth: needsAuth),
      );

      if (response.statusCode != 204) {
        _handleResponse(response);
      }
    } catch (e) {
      throw ApiException('网络请求失败: $e');
    }
  }

  // 处理响应
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    }

    // 错误处理
    String errorMessage = '请求失败';
    try {
      final errorData = jsonDecode(utf8.decode(response.bodyBytes));
      errorMessage = errorData['detail'] ?? errorMessage;
    } catch (e) {
      errorMessage = '服务器错误';
    }

    switch (statusCode) {
      case 400:
        throw ApiException('请求参数错误: $errorMessage');
      case 401:
        throw UnauthorizedException('未授权: $errorMessage');
      case 403:
        throw ApiException('禁止访问: $errorMessage');
      case 404:
        throw ApiException('资源不存在: $errorMessage');
      case 422:
        throw ApiException('数据验证失败: $errorMessage');
      case 500:
        throw ApiException('服务器内部错误');
      default:
        throw ApiException('未知错误: $errorMessage');
    }
  }
}

// 自定义异常
class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException(this.message);

  @override
  String toString() => message;
}
