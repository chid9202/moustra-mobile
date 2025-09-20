import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/helpers/util_helper.dart';
import 'package:moustra/services/auth_service.dart';
import 'package:moustra/services/dtos/profile_dto.dart';
import 'package:moustra/stores/profile_store.dart';

class AppMenu extends StatelessWidget {
  const AppMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            padding: const EdgeInsets.all(16.0),
            duration: const Duration(milliseconds: 250),
            curve: Curves.fastOutSlowIn,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(16.0),
              ),
            ),
            child: ValueListenableBuilder<ProfileResponseDto?>(
              valueListenable: profileState,
              builder: (context, profile, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/icons/app_icon.png',
                          height: 64,
                          width: 64,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            UtilHelper.getDisplayLabName(
                              profile?.labName ?? 'Moustra',
                            ),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (profile != null)
                      Text(
                        '${profile.firstName} ${profile.lastName}',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 18,
                        ),
                      ),
                    if (profile?.position != null)
                      Text(
                        profile!.position!,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
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
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Mating'),
            onTap: () {
              Navigator.of(context).pop();
              context.go('/matings');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.of(context).pop();
              try {
                await authService.logout();
                if (context.mounted) {
                  context.go('/login');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error logging out: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
