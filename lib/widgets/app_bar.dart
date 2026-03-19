import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/widgets/notification_bell.dart';

class MoustraAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MoustraAppBar({super.key});

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
        const NotificationBell(),
        Semantics(
          label: 'Tasks',
          button: true,
          child: IconButton(
            icon: const Icon(Icons.task_alt),
            tooltip: 'Tasks',
            onPressed: () => context.go('/task'),
          ),
        ),
        Semantics(
          label: 'Calendar',
          button: true,
          child: IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Calendar',
            onPressed: () => context.go('/calendar'),
          ),
        ),
        Semantics(
          label: 'Cheese AI',
          button: true,
          child: IconButton(
            icon: const Icon(Icons.smart_toy),
            tooltip: 'Cheese AI',
            onPressed: () => context.go('/ai'),
          ),
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
