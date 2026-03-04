import 'package:flutter/material.dart';
import 'package:moustra/services/clients/notification_api.dart';
import 'package:moustra/services/dtos/notification_dto.dart';
import 'package:moustra/widgets/notification_detail_sheet.dart';
import 'package:moustra/widgets/notification_item.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  List<NotificationDto> _notifications = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _loadNotifications();
    }
  }

  Future<void> _loadNotifications() async {
    try {
      final response = await notificationService.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = response.notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await notificationService.markAllAsRead();
      _loadNotifications();
    } catch (_) {}
  }

  Future<void> _onTapNotification(NotificationDto notification) async {
    try {
      if (!notification.isRead) {
        await notificationService.markAsRead(notification.notificationUuid);
      }
    } catch (_) {}

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NotificationDetailSheet(notification: notification),
    );

    _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Notifications',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: _markAllAsRead,
                child: const Text('Mark all read'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _notifications.isEmpty
                  ? const Center(child: Text('No notifications'))
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      child: ListView.separated(
                        itemCount: _notifications.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          return NotificationItem(
                            notification: notification,
                            onTap: () => _onTapNotification(notification),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}
