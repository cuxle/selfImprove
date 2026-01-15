import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// 初始化通知服务
  Future<void> initialize() async {
    if (_initialized) return;

    // 初始化时区
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));

    // Android 初始化设置
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 初始化设置
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  /// 处理通知点击事件
  void _onNotificationTapped(NotificationResponse response) {
    // 可以在这里处理通知点击后的导航逻辑
    print('Notification tapped: ${response.payload}');
  }

  /// 请求通知权限（iOS）
  Future<bool> requestPermissions() async {
    final permitted = await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    return permitted ?? true;
  }

  /// 调度日记提醒
  Future<void> scheduleReminderNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required String frequency,
    List<int>? daysOfWeek,
  }) async {
    await _notifications.cancel(id);

    const androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      '提醒通知',
      channelDescription: '日记和挑战提醒',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // 如果时间已过，调度到明天
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    if (frequency == 'daily') {
      // 每天重复
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } else if (frequency == 'weekly' && daysOfWeek != null && daysOfWeek.isNotEmpty) {
      // 每周特定日期重复
      for (final dayOfWeek in daysOfWeek) {
        // 计算下一个目标星期几
        var targetDate = scheduledDate;
        final currentWeekday = targetDate.weekday;
        final targetWeekday = dayOfWeek == 6 ? 7 : dayOfWeek + 1; // 转换为 DateTime 的 weekday 格式

        final daysUntilTarget = (targetWeekday - currentWeekday + 7) % 7;
        if (daysUntilTarget > 0 || (daysUntilTarget == 0 && targetDate.isBefore(now))) {
          targetDate = targetDate.add(Duration(days: daysUntilTarget == 0 ? 7 : daysUntilTarget));
        }

        await _notifications.zonedSchedule(
          id * 10 + dayOfWeek, // 为每个星期几生成唯一ID
          title,
          body,
          tz.TZDateTime.from(targetDate, tz.local),
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    }
  }

  /// 取消提醒
  Future<void> cancelReminder(int id, {String? frequency, List<int>? daysOfWeek}) async {
    if (frequency == 'weekly' && daysOfWeek != null) {
      // 取消所有关联的星期几通知
      for (final dayOfWeek in daysOfWeek) {
        await _notifications.cancel(id * 10 + dayOfWeek);
      }
    } else {
      await _notifications.cancel(id);
    }
  }

  /// 取消所有通知
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// 显示即时通知（用于测试）
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'instant_channel',
      '即时通知',
      channelDescription: '测试通知',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, notificationDetails);
  }

  /// 获取待处理的通知
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
