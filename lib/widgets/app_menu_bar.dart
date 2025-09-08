import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppMenuBar extends StatelessWidget {
  const AppMenuBar({super.key});

  @override
  Widget build(BuildContext context) {
    return MenuBar(
      children: [
        SubmenuButton(
          child: const Text('Dashboard'),
          menuChildren: [
            MenuItemButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                context.go('/');
              },
              child: const Text('Open'),
            ),
          ],
        ),
        SubmenuButton(
          child: const Text('Strain'),
          menuChildren: [
            MenuItemButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                context.go('/strains');
              },
              child: const Text('Open'),
            ),
          ],
        ),
        SubmenuButton(
          child: const Text('Cage'),
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
        ),
        SubmenuButton(
          child: const Text('Litter'),
          menuChildren: [
            MenuItemButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                context.go('/litters');
              },
              child: const Text('Open'),
            ),
          ],
        ),
        SubmenuButton(
          child: const Text('Animal'),
          menuChildren: [
            MenuItemButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                context.go('/animals');
              },
              child: const Text('Open'),
            ),
          ],
        ),
      ],
    );
  }
}
