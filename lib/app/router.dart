import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grid_view/shared/widgets/app_menu.dart';
import 'package:grid_view/screens/strains_screen.dart';
import 'package:grid_view/screens/cages_list_screen.dart';
import 'package:grid_view/screens/cages_grid_screen.dart';
import 'package:grid_view/screens/litters_screen.dart';
import 'package:grid_view/screens/animals_screen.dart';
import 'package:grid_view/screens/matings_screen.dart';
import 'package:grid_view/screens/dashboard_screen.dart';
import 'package:grid_view/services/auth_service.dart';

final ValueNotifier<bool> authState = ValueNotifier<bool>(
  authService.isLoggedIn,
);

final GoRouter appRouter = GoRouter(
  routes: [
    ShellRoute(
      pageBuilder: (context, state, child) => MaterialPage(
        child: Scaffold(
          appBar: AppBar(
            title: const Center(child: Text('Moustra')),
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            actions: [
              ValueListenableBuilder(
                valueListenable: authState,
                builder: (context, value, _) {
                  final bool loggedIn = value;
                  return IconButton(
                    icon: Icon(loggedIn ? Icons.logout : Icons.login),
                    onPressed: () async {
                      if (loggedIn) {
                        await authService.logout();
                        authState.value = authService.isLoggedIn;
                      } else {
                        try {
                          await authService.login();
                          authState.value = authService.isLoggedIn;
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Login failed: $e')),
                            );
                          }
                        }
                      }
                    },
                  );
                },
              ),
            ],
          ),
          drawer: const AppMenu(),
          body: child,
        ),
      ),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) =>
              const MaterialPage(child: DashboardScreen()),
        ),
        GoRoute(
          path: '/strains',
          pageBuilder: (context, state) =>
              const MaterialPage(child: StrainsScreen()),
        ),
        GoRoute(
          path: '/cages/list',
          pageBuilder: (context, state) =>
              const MaterialPage(child: CagesListScreen()),
        ),
        GoRoute(
          path: '/cages/grid',
          pageBuilder: (context, state) =>
              const MaterialPage(child: CagesGridScreen()),
        ),
        GoRoute(
          path: '/litters',
          pageBuilder: (context, state) =>
              const MaterialPage(child: LittersScreen()),
        ),
        GoRoute(
          path: '/animals',
          pageBuilder: (context, state) =>
              const MaterialPage(child: AnimalsScreen()),
        ),
        GoRoute(
          path: '/matings',
          pageBuilder: (context, state) =>
              const MaterialPage(child: MatingsScreen()),
        ),
      ],
    ),
  ],
);
