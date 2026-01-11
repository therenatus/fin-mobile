import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// Local notification service for scheduling order reminders
class LocalNotificationService {
  static final LocalNotificationService instance = LocalNotificationService._();
  LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  Function(String orderId)? onNotificationTap;

  /// Initialize the local notification plugin
  Future<void> init() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Request permissions on iOS
    if (Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }

    // Request permissions on Android 13+
    if (Platform.isAndroid) {
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    }

    _isInitialized = true;
    debugPrint('LocalNotificationService: Initialized');
  }

  /// Schedule a reminder notification for an order (1 day before due date)
  Future<void> scheduleOrderReminder({
    required String orderId,
    required String orderName,
    required DateTime dueDate,
  }) async {
    // Calculate reminder time (1 day before due date at 10:00 AM)
    final reminderDate = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day - 1,
      10,
      0,
    );

    // Don't schedule if the reminder date is in the past
    if (reminderDate.isBefore(DateTime.now())) {
      debugPrint('LocalNotificationService: Reminder date is in the past, skipping');
      return;
    }

    // Create unique notification ID from order ID
    final notificationId = orderId.hashCode.abs();

    const androidDetails = AndroidNotificationDetails(
      'order_reminders',
      'Напоминания о заказах',
      channelDescription: 'Напоминания о сроках выполнения заказов',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      notificationId,
      'Напоминание о заказе',
      'Заказ "$orderName" должен быть выполнен завтра',
      tz.TZDateTime.from(reminderDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: orderId,
    );

    debugPrint('LocalNotificationService: Scheduled reminder for order $orderId at $reminderDate');
  }

  /// Cancel a scheduled reminder for an order
  Future<void> cancelReminder(String orderId) async {
    final notificationId = orderId.hashCode.abs();
    await _plugin.cancel(notificationId);
    debugPrint('LocalNotificationService: Cancelled reminder for order $orderId');
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    debugPrint('LocalNotificationService: Cancelled all reminders');
  }

  /// Show an immediate notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'general',
      'Общие уведомления',
      channelDescription: 'Общие уведомления приложения',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payload,
    );
  }

  // Notification response callback
  void _onNotificationResponse(NotificationResponse response) {
    debugPrint('LocalNotificationService: Notification response received');
    final payload = response.payload;
    if (payload != null && onNotificationTap != null) {
      onNotificationTap!(payload);
    }
  }
}
