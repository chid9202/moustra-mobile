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
import 'package:grid_view/screens/settings_screen.dart';
import 'package:grid_view/screens/onboarding/onboarding_screen.dart';
import 'package:grid_view/services/auth_service.dart';
import 'package:grid_view/services/session_service.dart';

final ValueNotifier<bool> authState = ValueNotifier<bool>(
  authService.isLoggedIn,
);

final GoRouter appRouter = GoRouter(
  refreshListenable: Listenable.merge([authState, sessionService.onboardedNotifier]),
  redirect: (context, state) {
    final loggedIn = authState.value;
    final onboarded = sessionService.onboarded;
    final path = state.uri.path;

    if (!loggedIn) {
      if (path == '/onboarding') return '/';
      return null;
    }

    if (!onboarded && path != '/onboarding') {
      return '/onboarding';
    }

    if (onboarded && path == '/onboarding') {
      return '/';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) =>
          const MaterialPage(child: OnboardingScreen()),
    ),
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
                        authState.value = false;
                      } else {
                        try {
                          await authService.login();
                          authState.value = true;
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
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) =>
              const MaterialPage(child: SettingsScreen()),
        ),
      ],
    ),
  ],
);
