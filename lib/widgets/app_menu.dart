import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/helpers/util_helper.dart';
import 'package:moustra/services/auth_service.dart';
import 'package:moustra/services/dtos/profile_dto.dart';
import 'package:moustra/stores/profile_store.dart';

/// Menu item definition matching web structure
class _MenuItemDef {
  final String id;
  final IconData icon;
  final String display;
  final String route;

  const _MenuItemDef({
    required this.id,
    required this.icon,
    required this.display,
    required this.route,
  });
}

/// Main menu items (matching web MENU_ITEMS order)
const List<_MenuItemDef> _menuItems = [
  _MenuItemDef(
    id: 'rack',
    icon: Icons.table_view,
    display: 'Racks',
    route: '/cage/grid',
  ),
  _MenuItemDef(
    id: 'cage',
    icon: Icons.grid_view_sharp,
    display: 'Cages',
    route: '/cage/list',
  ),
  _MenuItemDef(
    id: 'strain',
    icon: Icons.bookmark_sharp,
    display: 'Strain',
    route: '/strain',
  ),
  _MenuItemDef(
    id: 'animal',
    icon: Icons.pest_control_rodent_sharp,
    display: 'Animal',
    route: '/animal',
  ),
  _MenuItemDef(
    id: 'mating',
    icon: Icons.call_merge_sharp,
    display: 'Mating',
    route: '/mating',
  ),
  _MenuItemDef(
    id: 'litter',
    icon: Icons.create_new_folder_sharp,
    display: 'Litter',
    route: '/litter',
  ),
  _MenuItemDef(
    id: 'dashboard',
    icon: Icons.bar_chart_sharp,
    display: 'Insights',
    route: '/dashboard',
  ),
  _MenuItemDef(
    id: 'user',
    icon: Icons.groups,
    display: 'User',
    route: '/user',
  ),
];

/// Bottom utility items
const List<_MenuItemDef> _bottomItems = [
  _MenuItemDef(
    id: 'settings',
    icon: Icons.settings,
    display: 'Settings',
    route: '/settings',
  ),
];

class AppMenu extends StatelessWidget {
  const AppMenu({super.key});

  /// Check if a route is currently active
  bool _isActive(String routePath, String currentPath) {
    // Exact matches
    if (routePath == currentPath) return true;

    // Rack/Grid view
    if (routePath == '/cage/grid') {
      return currentPath == '/cage/grid';
    }

    // Cage list view - only exact match, not when on grid
    if (routePath == '/cage/list') {
      return currentPath == '/cage/list';
    }

    // For detail routes, check prefix (but exclude cage conflicts)
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
    if (routePath == '/dashboard') {
      return currentPath == '/dashboard' || currentPath == '/';
    }
    if (routePath == '/settings') {
      return currentPath.startsWith('/settings');
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;

    return Drawer(
      child: Column(
        children: [
          // Header with lab info
          _buildHeader(context),

          // Main menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Main navigation items
                ..._menuItems.map(
                  (item) => _buildMenuItem(
                    context: context,
                    item: item,
                    isActive: _isActive(item.route, currentPath),
                  ),
                ),
              ],
            ),
          ),

          // Bottom section with divider
          const Divider(height: 1),

          // Bottom utility items
          ..._bottomItems.map(
            (item) => _buildMenuItem(
              context: context,
              item: item,
              isActive: _isActive(item.route, currentPath),
            ),
          ),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => _handleLogout(context),
          ),

          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return DrawerHeader(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
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
                    height: 56,
                    width: 56,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      UtilHelper.getDisplayLabName(
                        profile?.labName ?? 'Moustra',
                      ),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (profile != null) ...[
                Text(
                  '${profile.firstName} ${profile.lastName}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (profile.position != null)
                  Text(
                    profile.position!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required _MenuItemDef item,
    required bool isActive,
  }) {
    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.primary;

    return ListTile(
      leading: Icon(
        item.icon,
        color: isActive ? activeColor : null,
      ),
      title: Text(
        item.display,
        style: TextStyle(
          color: isActive ? activeColor : null,
          fontWeight: isActive ? FontWeight.w600 : null,
        ),
      ),
      selected: isActive,
      selectedTileColor: activeColor.withValues(alpha: 0.08),
      onTap: () {
        Navigator.of(context).pop();
        context.go(item.route);
      },
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
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
  }
}
