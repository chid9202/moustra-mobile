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
    if (routePath == '/cages/list') {
      return currentPath == '/cages/list';
    }
    if (routePath == '/cages/grid') {
      return currentPath == '/cages/grid';
    }
    // For other routes, check if current path starts with the route path
    if (routePath == '/strains') {
      return currentPath.startsWith('/strains');
    }
    if (routePath == '/animals') {
      return currentPath.startsWith('/animals');
    }
    if (routePath == '/matings') {
      return currentPath.startsWith('/matings');
    }
    if (routePath == '/litters') {
      return currentPath.startsWith('/litters');
    }
    if (routePath == '/users') {
      return currentPath.startsWith('/users');
    }
    return false;
  }

  bool _isCageActive(String currentPath) {
    return currentPath.startsWith('/cages');
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
          ExpansionTile(
            initiallyExpanded: _isCageActive(currentPath),
            leading: Icon(
              Icons.home_work_outlined,
              color: _isCageActive(currentPath)
                  ? Theme.of(context).primaryColor
                  : null,
            ),
            title: Text('Cage'),
            children: [
              ListTile(
                contentPadding: const EdgeInsets.only(left: 24.0),
                leading: Icon(
                  Icons.list,
                  color: _isActive('/cages/list', currentPath)
                      ? Theme.of(context).primaryColor
                      : null,
                ),
                selected: _isActive('/cages/list', currentPath),
                title: const Text('List View'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.go('/cages/list');
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.only(left: 24.0),
                leading: Icon(
                  Icons.grid_view,
                  color: _isActive('/cages/grid', currentPath)
                      ? Theme.of(context).primaryColor
                      : null,
                ),
                selected: _isActive('/cages/grid', currentPath),
                title: const Text('Grid View'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.go('/cages/grid');
                },
              ),
            ],
          ),
          ListTile(
            leading: Icon(
              Icons.science,
              color: _isActive('/strains', currentPath)
                  ? Theme.of(context).primaryColor
                  : null,
            ),
            selected: _isActive('/strains', currentPath),
            title: const Text('Strain'),
            onTap: () {
              Navigator.of(context).pop();
              context.go('/strains');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.pets,
              color: _isActive('/animals', currentPath)
                  ? Theme.of(context).primaryColor
                  : null,
            ),
            selected: _isActive('/animals', currentPath),
            title: const Text('Animal'),
            onTap: () {
              Navigator.of(context).pop();
              context.go('/animals');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.favorite,
              color: _isActive('/matings', currentPath)
                  ? Theme.of(context).primaryColor
                  : null,
            ),
            selected: _isActive('/matings', currentPath),
            title: const Text('Mating'),
            onTap: () {
              Navigator.of(context).pop();
              context.go('/matings');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.loyalty,
              color: _isActive('/litters', currentPath)
                  ? Theme.of(context).primaryColor
                  : null,
            ),
            selected: _isActive('/litters', currentPath),
            title: const Text('Litter'),
            onTap: () {
              Navigator.of(context).pop();
              context.go('/litters');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.people,
              color: _isActive('/users', currentPath)
                  ? Theme.of(context).primaryColor
                  : null,
            ),
            selected: _isActive('/users', currentPath),
            title: const Text('Users'),
            onTap: () {
              Navigator.of(context).pop();
              context.go('/users');
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
