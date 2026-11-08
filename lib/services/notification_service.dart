import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database_service.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: DarwinInitializationSettings(),
    );

    await _notifications.initialize(settings: initializationSettings);

    _isInitialized = true;
  }

  Future<bool> requestPermission() async {
    await initialize();

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    final granted = await androidPlugin?.requestNotificationsPermission();

    return granted ?? true;
  }

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final enabled = prefs.getBool('notificationsEnabled') ?? true;

    if (!enabled) return;

    await initialize();

    // Save the notification in the local database.
    // Save the notification locally without blocking Android notification.
    try {
      final db = await DatabaseService.instance.database;

      await db.insert('notifications', {
        'title': title,
        'body': body,
        'created_at': DateTime.now().toIso8601String(),
        'is_read': 0,
      });

      await refreshUnreadCount();
    } catch (e) {
      debugPrint('Unable to save notification: $e');
    }

    const androidDetails = AndroidNotificationDetails(
      'novabank_transactions',
      'NovaBank Transactions',
      channelDescription: 'Notifications about NovaBank account activity',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
      notificationDetails: notificationDetails,
    );
  }

  // Get all saved notifications, newest first.
  Future<List<Map<String, dynamic>>> getNotifications() async {
    final db = await DatabaseService.instance.database;

    return db.query('notifications', orderBy: 'created_at DESC');
  }

  // Mark a notification as read.
  Future<void> markAsRead(int notificationId) async {
    final db = await DatabaseService.instance.database;

    await db.update(
      'notifications',
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [notificationId],
    );
    await refreshUnreadCount();
  }

  // Mark all notifications as read.
  Future<void> markAllAsRead() async {
    final db = await DatabaseService.instance.database;

    await db.update(
      'notifications',
      {'is_read': 1},
      where: 'is_read = ?',
      whereArgs: [0],
    );

    await refreshUnreadCount();
  }

  Future<void> refreshUnreadCount() async {
    final db = await DatabaseService.instance.database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM notifications WHERE is_read = 0',
    );

    unreadCount.value = result.first['count'] as int;
  }
}
