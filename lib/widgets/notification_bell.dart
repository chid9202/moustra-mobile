import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/services/clients/notification_api.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  int _unreadCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchUnreadCount();
    _timer = Timer.periodic(const Duration(seconds: 60), (_) {
      _fetchUnreadCount();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final count = await notificationService.getUnreadCount();
      if (mounted) {
        setState(() => _unreadCount = count);
      }
    } catch (_) {
      // Silently fail — badge just won't update
    }
  }

  String get _badgeLabel => _unreadCount > 99 ? '99+' : '$_unreadCount';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Notifications',
      button: true,
      child: IconButton(
      icon: Badge(
        isLabelVisible: _unreadCount > 0,
        label: Text(
          _badgeLabel,
          style: const TextStyle(fontSize: 10),
        ),
        child: const Icon(Icons.notifications_outlined),
      ),
      onPressed: () => context.go('/notification'),
    ),
    );
  }
}
