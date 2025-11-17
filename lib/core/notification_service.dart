import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: android));
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> requestExactAlarmPermission() async {
    if (Platform.isAndroid && (await Permission.scheduleExactAlarm.isDenied)) {
      // Request the exact alarm permission
      final status = await Permission.scheduleExactAlarm.request();
      if (status.isGranted) {
        print('Exact alarm permission granted');
      } else {
        print('Exact alarm permission denied');
      }
    }
  }

  Future<void> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      if (status.isGranted) {
        print('Notification permission granted');
      } else {
        print('Notification permission denied');
      }
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const android = AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      importance: Importance.max,
      priority: Priority.high,
    );
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(android: android),
    );
  }

  /// Schedule a notification at a specific DateTime
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final android = AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    final ios = DarwinNotificationDetails();

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(android: android, iOS: ios),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }

  Future<void> openExactAlarmSettings() async {
    const intent = AndroidIntent(
      action: "android.settings.REQUEST_SCHEDULE_EXACT_ALARM",
    );
    await intent.launch();
  }
}
