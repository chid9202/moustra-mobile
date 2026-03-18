import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/helpers/snackbar_helper.dart';
import 'package:moustra/helpers/util_helper.dart';
import 'package:moustra/services/auth_service.dart';
import 'package:moustra/services/dtos/profile_dto.dart';
import 'package:moustra/stores/profile_store.dart';

/// Menu item definition
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

/// Collapsible menu group
class _MenuGroup {
  final String label;
  final List<_MenuItemDef> items;

  const _MenuGroup({required this.label, required this.items});
}

/// Grouped menu sections matching React web structure
const List<_MenuGroup> _menuGroups = [
  _MenuGroup(
    label: 'COLONY',
    items: [
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
    ],
  ),
  _MenuGroup(
    label: 'ANIMALS',
    items: [
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
    ],
  ),
  _MenuGroup(
    label: 'BREEDING',
    items: [
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
        id: 'plugEvent',
        icon: Icons.event_note,
        display: 'Plug Events',
        route: '/plug-event',
      ),
    ],
  ),
];

/// Flat items below the groups
const _insightsItem = _MenuItemDef(
  id: 'dashboard',
  icon: Icons.bar_chart_sharp,
  display: 'Insights',
  route: '/dashboard',
);

/// Bottom utility items
const List<_MenuItemDef> _bottomItems = [
  _MenuItemDef(
    id: 'user',
    icon: Icons.groups,
    display: 'User',
    route: '/user',
  ),
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
    if (routePath == currentPath) return true;

    if (routePath == '/cage/grid') {
      return currentPath == '/cage/grid';
    }
    if (routePath == '/cage/list') {
      return currentPath == '/cage/list';
    }
    if (routePath == '/strain') {
      return currentPath.startsWith('/strain');
    }
    if (routePath == '/animal') {
      return currentPath.startsWith('/animal');
    }
    if (routePath == '/mating') {
      return currentPath.startsWith('/mating');
    }
    if (routePath == '/plug-event') {
      return currentPath.startsWith('/plug-event');
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

          // Main menu with collapsible groups
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Collapsible groups
                ..._menuGroups.map(
                  (group) => _buildMenuGroup(
                    context: context,
                    group: group,
                    currentPath: currentPath,
                  ),
                ),

                const Divider(height: 1),

                // Insights (flat item)
                _buildMenuItem(
                  context: context,
                  item: _insightsItem,
                  isActive: _isActive(_insightsItem.route, currentPath),
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
          Semantics(
            label: 'Logout',
            button: true,
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () => _handleLogout(context),
            ),
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

  Widget _buildMenuGroup({
    required BuildContext context,
    required _MenuGroup group,
    required String currentPath,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: group.label,
          header: true,
          child: Padding(
            padding: const EdgeInsets.only(left: 16, top: 12, bottom: 4),
            child: Text(
              group.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
        ...group.items.map(
          (item) => _buildMenuItem(
            context: context,
            item: item,
            isActive: _isActive(item.route, currentPath),
            indent: true,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required _MenuItemDef item,
    required bool isActive,
    bool indent = false,
  }) {
    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.primary;

    return Semantics(
      label: item.display,
      button: true,
      child: ListTile(
        contentPadding: indent
            ? const EdgeInsets.only(left: 32, right: 16)
            : null,
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
      ),
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
        showAppSnackBar(context, 'Error logging out: $e', isError: true);
      }
    }
  }
}
