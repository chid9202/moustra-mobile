import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MoustraAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MoustraAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      flexibleSpace: Container(
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: () => context.go('/dashboard'),
          child: Image.asset(
            'assets/icons/app_icon.png',
            height: 64,
            width: 64,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
