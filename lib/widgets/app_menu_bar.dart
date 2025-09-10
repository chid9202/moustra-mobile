import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppMenuBar extends StatelessWidget {
  const AppMenuBar({super.key});

  @override
  Widget build(BuildContext context) {
    return MenuBar(
      children: [
        SubmenuButton(
          menuChildren: [
            MenuItemButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                context.go('/');
              },
              child: const Text('Open'),
            ),
          ],
          child: const Text('Dashboard'),
        ),
        SubmenuButton(
          menuChildren: [
            MenuItemButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                context.go('/strains');
              },
              child: const Text('Open'),
            ),
          ],
          child: const Text('Strain'),
        ),
        SubmenuButton(
          menuChildren: [
            MenuItemButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                context.go('/cages/list');
              },
              child: const Text('List View'),
            ),
            MenuItemButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                context.go('/cages/grid');
              },
              child: const Text('Grid View'),
            ),
          ],
          child: const Text('Cage'),
        ),
        SubmenuButton(
          menuChildren: [
            MenuItemButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                context.go('/litters');
              },
              child: const Text('Open'),
            ),
          ],
          child: const Text('Litter'),
        ),
        SubmenuButton(
          menuChildren: [
            MenuItemButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                context.go('/animals');
              },
              child: const Text('Open'),
            ),
          ],
          child: const Text('Animal'),
        ),
      ],
    );
  }
}
