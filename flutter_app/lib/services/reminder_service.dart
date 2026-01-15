import '../config/api_config.dart';
import 'api_service.dart';

class ReminderService {
  final ApiService _apiService = ApiService();

  /// 获取提醒列表
  Future<List<Reminder>> getReminders({String? reminderType}) async {
    final queryParams = <String, String>{};
    if (reminderType != null) {
      queryParams['reminder_type'] = reminderType;
    }

    final response = await _apiService.get(
      ApiConfig.reminders,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final items = response['items'] as List<dynamic>;
    return items.map((item) => Reminder.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// 创建提醒
  Future<Reminder> createReminder(ReminderCreateRequest request) async {
    final response = await _apiService.post(
      ApiConfig.reminders,
      body: request.toJson(),
    );
    return Reminder.fromJson(response);
  }

  /// 更新提醒
  Future<Reminder> updateReminder(int id, Map<String, dynamic> updates) async {
    final response = await _apiService.put(
      ApiConfig.reminderById(id),
      body: updates,
    );
    return Reminder.fromJson(response);
  }

  /// 删除提醒
  Future<void> deleteReminder(int id) async {
    await _apiService.delete(ApiConfig.reminderById(id));
  }
}

/// 提醒模型
class Reminder {
  final int id;
  final int userId;
  final String reminderType;
  final bool isEnabled;
  final String reminderTime;
  final String frequency;
  final List<int>? daysOfWeek;
  final String? message;
  final String createdAt;
  final String updatedAt;

  Reminder({
    required this.id,
    required this.userId,
    required this.reminderType,
    required this.isEnabled,
    required this.reminderTime,
    required this.frequency,
    this.daysOfWeek,
    this.message,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    // 处理 days_of_week，可能是字符串或列表
    List<int>? parseDaysOfWeek(dynamic value) {
      if (value == null) return null;
      if (value is List) {
        return value.map((e) => e as int).toList();
      }
      if (value is String) {
        // 尝试解析JSON字符串
        try {
          final parsed = value.replaceAll('[', '').replaceAll(']', '').split(',');
          return parsed.where((e) => e.trim().isNotEmpty).map((e) => int.parse(e.trim())).toList();
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    return Reminder(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      reminderType: json['reminder_type'] as String,
      isEnabled: json['is_enabled'] as bool,
      reminderTime: json['reminder_time'] as String,
      frequency: json['frequency'] as String,
      daysOfWeek: parseDaysOfWeek(json['days_of_week']),
      message: json['message'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }
}

/// 创建提醒请求
class ReminderCreateRequest {
  final String reminderType;
  final bool isEnabled;
  final String reminderTime;
  final String frequency;
  final List<int>? daysOfWeek;
  final String? message;

  ReminderCreateRequest({
    required this.reminderType,
    this.isEnabled = true,
    required this.reminderTime,
    this.frequency = 'daily',
    this.daysOfWeek,
    this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'reminder_type': reminderType,
      'is_enabled': isEnabled,
      'reminder_time': reminderTime,
      'frequency': frequency,
      if (daysOfWeek != null) 'days_of_week': daysOfWeek,
      if (message != null) 'message': message,
    };
  }
}
