import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<Map<String, dynamic>>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _markAllAsRead();
  }

  void _loadNotifications() {
    _notificationsFuture = NotificationService.instance.getNotifications();
  }

  Future<void> _markAsRead(int id) async {
    await NotificationService.instance.markAsRead(id);

    if (!mounted) return;

    setState(_loadNotifications);
  }

  Future<void> _markAllAsRead() async {
    await NotificationService.instance.markAllAsRead();
  }

  String _formatTime(String date) {
    final notificationDate = DateTime.parse(date).toLocal();
    final now = DateTime.now();

    if (DateUtils.isSameDay(notificationDate, now)) {
      return 'Today, ${_time(notificationDate)}';
    }

    if (DateUtils.isSameDay(
      notificationDate,
      now.subtract(const Duration(days: 1)),
    )) {
      return 'Yesterday, ${_time(notificationDate)}';
    }

    return '${notificationDate.day.toString().padLeft(2, '0')}/'
        '${notificationDate.month.toString().padLeft(2, '0')}/'
        '${notificationDate.year}  ${_time(notificationDate)}';
  }

  String _time(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  String _sectionFor(String date) {
    final notificationDate = DateTime.parse(date).toLocal();
    final now = DateTime.now();

    if (DateUtils.isSameDay(notificationDate, now)) {
      return 'Today';
    }

    if (DateUtils.isSameDay(
      notificationDate,
      now.subtract(const Duration(days: 1)),
    )) {
      return 'Yesterday';
    }

    return 'Earlier';
  }

  Widget _sectionTitle(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _notificationCard(Map<String, dynamic> notification) {
    final id = notification['id'] as int;
    final title = notification['title'] as String;
    final body = notification['body'] as String;
    final date = notification['created_at'] as String;
    final isRead = notification['is_read'] == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead
              ? AppColors.border
              : AppColors.secondary.withValues(alpha: 0.45),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isRead ? null : () => _markAsRead(id),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.secondary,
                  size: 23,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      body,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      _formatTime(date),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 45,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'All caught up!',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your account updates and transaction '
              'notifications will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            );
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Unable to load notifications.'));
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return _emptyState();
          }

          final today = notifications
              .where((n) => _sectionFor(n['created_at']) == 'Today')
              .toList();

          final yesterday = notifications
              .where((n) => _sectionFor(n['created_at']) == 'Yesterday')
              .toList();

          final earlier = notifications
              .where((n) => _sectionFor(n['created_at']) == 'Earlier')
              .toList();

          return RefreshIndicator(
            color: AppColors.secondary,
            onRefresh: () async {
              setState(_loadNotifications);
              await _notificationsFuture;
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 5, 18, 24),
              children: [
                if (today.isNotEmpty) ...[
                  _sectionTitle('Today', today.length),
                  ...today.map(_notificationCard),
                ],
                if (yesterday.isNotEmpty) ...[
                  _sectionTitle('Yesterday', yesterday.length),
                  ...yesterday.map(_notificationCard),
                ],
                if (earlier.isNotEmpty) ...[
                  _sectionTitle('Earlier', earlier.length),
                  ...earlier.map(_notificationCard),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
