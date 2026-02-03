import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/helpers/util_helper.dart';
import 'package:moustra/services/auth_service.dart';
import 'package:moustra/services/dtos/profile_dto.dart';
import 'package:moustra/stores/profile_store.dart';

class AppMenu extends StatefulWidget {
  const AppMenu({super.key});

  @override
  State<AppMenu> createState() => _AppMenuState();
}

class _AppMenuState extends State<AppMenu> {
  bool _isActive(String routePath, String currentPath) {
    if (routePath == '/dashboard' || routePath == '/') {
      return currentPath == '/dashboard' || currentPath == '/';
    }
    if (routePath == '/cage/list') {
      return currentPath == '/cage/list';
    }
    if (routePath == '/cage/grid') {
      return currentPath == '/cage/grid';
    }
    // For other routes, check if current path starts with the route path
    if (routePath == '/strain') {
      return currentPath.startsWith('/strain');
    }
    if (routePath == '/animal') {
      return currentPath.startsWith('/animal');
    }
    if (routePath == '/mating') {
      return currentPath.startsWith('/mating');
    }
    if (routePath == '/litter') {
      return currentPath.startsWith('/litter');
    }
    if (routePath == '/user') {
      return currentPath.startsWith('/user');
    }
    if (routePath == '/settings') {
      return currentPath.startsWith('/settings');
    }
    return false;
  }

  bool _isCageActive(String currentPath) {
    return currentPath.startsWith('/cage');
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;

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
            leading: Icon(
              Icons.dashboard,
              color: _isActive('/dashboard', currentPath)
                  ? Theme.of(context).primaryColor
                  : null,
            ),
            selected: _isActive('/dashboard', currentPath),
            title: Text('Dashboard'),
            onTap: () {
              Navigator.of(context).pop();
              context.go('/dashboard');
            },
          ),
          // Cage header - always expanded, not collapsible
          ListTile(
            leading: Icon(
              Icons.home_work_outlined,
              color: _isCageActive(currentPath)
                  ? Theme.of(context).primaryColor
                  : null,
            ),
            title: Text('Cage'),
            enabled: false, // Make it non-tappable
          ),
          ListTile(
            contentPadding: const EdgeInsets.only(left: 24.0),
            leading: Icon(
              Icons.list,
              color: _isActive('/cage/list', currentPath)
                  ? Theme.of(context).primaryColor
                  : null,
            ),
            selected: _isActive('/cage/list', currentPath),
            title: const Text('List View'),
            onTap: () {
              Navigator.of(context).pop();
              context.go('/cage/list');
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.only(left: 24.0),
            leading: Icon(
              Icons.grid_view,
              color: _isActive('/cage/grid', currentPath)
                  ? Theme.of(context).primaryColor
                  : null,
            ),
            selected: _isActive('/cage/grid', currentPath),
            title: const Text('Grid View'),
            onTap: () {
              Navigator.of(context).pop();
              context.go('/cage/grid');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.science,
              color: _isActive('/strain', currentPath)
                  ? Theme.of(context).primaryColor
                  : null,
            ),
            selected: _isActive('/strain', currentPath),
            title: const Text('Strain'),
            onTap: () {
              Navigator.of(context).pop();
              context.go('/strain');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.pets,
              color: _isActive('/animal', currentPath)
                  ? Theme.of(context).primaryColor
                  : null,
            ),
            selected: _isActive('/animal', currentPath),
            title: const Text('Animal'),
            onTap: () {
              Navigator.of(context).pop();
              context.go('/animal');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.favorite,
              color: _isActive('/mating', currentPath)
                  ? Theme.of(context).primaryColor
                  : null,
            ),
            selected: _isActive('/mating', currentPath),
            title: const Text('Mating'),
            onTap: () {
              Navigator.of(context).pop();
              context.go('/mating');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.loyalty,
              color: _isActive('/litter', currentPath)
                  ? Theme.of(context).primaryColor
                  : null,
            ),
            selected: _isActive('/litter', currentPath),
            title: const Text('Litter'),
            onTap: () {
              Navigator.of(context).pop();
              context.go('/litter');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.people,
              color: _isActive('/user', currentPath)
                  ? Theme.of(context).primaryColor
                  : null,
            ),
            selected: _isActive('/user', currentPath),
            title: const Text('Users'),
            onTap: () {
              Navigator.of(context).pop();
              context.go('/user');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.settings,
              color: _isActive('/settings', currentPath)
                  ? Theme.of(context).primaryColor
                  : null,
            ),
            selected: _isActive('/settings', currentPath),
            title: const Text('Settings'),
            onTap: () {
              Navigator.of(context).pop();
              context.go('/settings');
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
