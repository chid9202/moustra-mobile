import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/services/clients/notification_api.dart';

class MoustraAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MoustraAppBar({super.key});

  @override
  State<MoustraAppBar> createState() => _MoustraAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MoustraAppBarState extends State<MoustraAppBar> {
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
    return AppBar(
      centerTitle: true,
      leading: Builder(
        builder: (context) => Semantics(
          label: 'Open menu',
          button: true,
          child: IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Open menu',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Badge(
              isLabelVisible: _unreadCount > 0,
              offset: const Offset(6, -6),
              label: Text(_badgeLabel, style: const TextStyle(fontSize: 10)),
              child: const Icon(Icons.more_vert),
            ),
          ),
          tooltip: 'More',
          onSelected: (value) {
            context.go(value);
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: '/notification',
              child: Row(
                children: [
                  Badge(
                    isLabelVisible: _unreadCount > 0,
                    label: Text(
                      _badgeLabel,
                      style: const TextStyle(fontSize: 10),
                    ),
                    child: const Icon(Icons.notifications_outlined),
                  ),
                  const SizedBox(width: 12),
                  const Text('Notifications'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: '/task',
              child: Row(
                children: [
                  Icon(Icons.task_alt),
                  SizedBox(width: 12),
                  Text('Tasks'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: '/calendar',
              child: Row(
                children: [
                  Icon(Icons.calendar_month),
                  SizedBox(width: 12),
                  Text('Calendar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: '/ai',
              child: Row(
                children: [
                  Icon(Icons.smart_toy),
                  SizedBox(width: 12),
                  Text('Cheese AI'),
                ],
              ),
            ),
          ],
        ),
      ],
      flexibleSpace: Container(
        alignment: Alignment.bottomCenter,
        child: Semantics(
          label: 'Home',
          button: true,
          child: GestureDetector(
            onTap: () => context.go('/cage/grid'),
            child: Image.asset(
              'assets/icons/app_icon.png',
              height: 64,
              width: 64,
              semanticLabel: 'Moustra home',
            ),
          ),
        ),
      ),
    );
  }
}
