import 'package:flutter/foundation.dart';
import '../services/reminder_service.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class ReminderProvider with ChangeNotifier {
  final ReminderService _reminderService = ReminderService();
  final NotificationService _notificationService = NotificationService();

  List<Reminder> _reminders = [];
  bool _isLoading = false;
  String? _error;

  List<Reminder> get reminders => _reminders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 按类型获取提醒
  List<Reminder> getRemindersByType(String type) {
    return _reminders.where((r) => r.reminderType == type).toList();
  }

  /// 加载提醒列表
  Future<void> loadReminders({String? reminderType}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reminders = await _reminderService.getReminders(reminderType: reminderType);
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '加载提醒失败: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 创建提醒
  Future<bool> createReminder(ReminderCreateRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newReminder = await _reminderService.createReminder(request);
      _reminders.insert(0, newReminder);

      // 如果提醒启用，调度通知
      if (newReminder.isEnabled) {
        await _scheduleNotification(newReminder);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '创建提醒失败: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 更新提醒
  Future<bool> updateReminder(int id, Map<String, dynamic> updates) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedReminder = await _reminderService.updateReminder(id, updates);
      final index = _reminders.indexWhere((r) => r.id == id);
      if (index != -1) {
        _reminders[index] = updatedReminder;
      }

      // 取消旧通知并重新调度
      await _notificationService.cancelReminder(
        id,
        frequency: _reminders.firstWhere((r) => r.id == id, orElse: () => updatedReminder).frequency,
        daysOfWeek: _reminders.firstWhere((r) => r.id == id, orElse: () => updatedReminder).daysOfWeek,
      );

      if (updatedReminder.isEnabled) {
        await _scheduleNotification(updatedReminder);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '更新提醒失败: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 删除提醒
  Future<bool> deleteReminder(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final reminder = _reminders.firstWhere((r) => r.id == id);

      await _reminderService.deleteReminder(id);

      // 取消关联的通知
      await _notificationService.cancelReminder(
        id,
        frequency: reminder.frequency,
        daysOfWeek: reminder.daysOfWeek,
      );

      _reminders.removeWhere((r) => r.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '删除提醒失败: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 切换提醒启用状态
  Future<bool> toggleReminder(int id, bool isEnabled) async {
    return await updateReminder(id, {'is_enabled': isEnabled});
  }

  /// 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 调度通知
  Future<void> _scheduleNotification(Reminder reminder) async {
    final timeParts = reminder.reminderTime.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    final title = reminder.reminderType == 'diary' ? '日记提醒' : '挑战提醒';
    final body = reminder.message ?? (reminder.reminderType == 'diary'
        ? '该写日记了，记录今天的情绪吧~'
        : '该进行挑战了，坚持新的回应方式！');

    await _notificationService.scheduleReminderNotification(
      id: reminder.id,
      title: title,
      body: body,
      hour: hour,
      minute: minute,
      frequency: reminder.frequency,
      daysOfWeek: reminder.daysOfWeek,
    );
  }
}
