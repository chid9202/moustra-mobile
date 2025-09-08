import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppMenu extends StatelessWidget {
  const AppMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(child: Text('Menu')),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.of(context).pop();
              context.go('/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.science),
            title: const Text('Strain'),
            onTap: () {
              Navigator.of(context).pop();
              context.go('/strains');
            },
          ),
          ExpansionTile(
            leading: const Icon(Icons.home_work_outlined),
            title: const Text('Cage'),
            children: [
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('List View'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.go('/cages/list');
                },
              ),
              ListTile(
                leading: const Icon(Icons.grid_view),
                title: const Text('Grid View'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.go('/cages/grid');
                },
              ),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.baby_changing_station),
            title: const Text('Litter'),
            onTap: () {
              Navigator.of(context).pop();
              context.go('/litters');
            },
          ),
          ListTile(
            leading: const Icon(Icons.pets),
            title: const Text('Animal'),
            onTap: () {
              Navigator.of(context).pop();
              context.go('/animals');
            },
          ),
        ],
      ),
    );
  }
}
