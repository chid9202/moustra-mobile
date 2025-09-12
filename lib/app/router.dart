import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/widgets/app_menu.dart';
import 'package:moustra/screens/strains_screen.dart';
import 'package:moustra/screens/cages_list_screen.dart';
import 'package:moustra/screens/cages_grid_screen.dart';
import 'package:moustra/screens/litters_screen.dart';
import 'package:moustra/screens/animals_screen.dart';
import 'package:moustra/screens/matings_screen.dart';
import 'package:moustra/screens/dashboard_screen.dart';
import 'package:moustra/services/auth_service.dart';
import 'package:moustra/screens/login_screen.dart';
import 'package:moustra/services/dtos/profile_dto.dart';

final ValueNotifier<bool> authState = ValueNotifier<bool>(
  authService.isLoggedIn,
);

// TODO: move to state management later
final ValueNotifier<ProfileResponseDto?> profileState =
    ValueNotifier<ProfileResponseDto?>(null);

final GoRouter appRouter = GoRouter(
  refreshListenable: authState,
  routes: [
    ShellRoute(
      pageBuilder: (context, state, child) => MaterialPage(
        child: Scaffold(
          appBar: AppBar(
            title: const Center(child: Text('moustra')),
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
        // GoRoute(
        //   path: '/ios/:rest(.*)',
        //   pageBuilder: (context, state) =>
        //       const MaterialPage(child: SizedBox.shrink()),
        // ),
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) =>
              const MaterialPage(child: LoginScreen()),
        ),
        // GoRoute(
        //   path: '/logout',
        //   pageBuilder: (context, state) {
        //     WidgetsBinding.instance.addPostFrameCallback((_) {
        //       print('android logout callback ------> $authService.isLoggedIn');
        //       if (context.mounted) context.go('/login');
        //     });
        //     return const MaterialPage(child: SizedBox.shrink());
        //   },
        // ),
        GoRoute(
          path: '/',
          pageBuilder: (context, state) =>
              const MaterialPage(child: LoginScreen()),
        ),
        GoRoute(
          path: '/dashboard',
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
  redirect: (context, state) {
    final path = state.uri.path;
    final onLogin = path == '/login';

    if (!authService.isLoggedIn) {
      return onLogin
          ? null
          : '/login?from=${Uri.encodeComponent(state.uri.toString())}';
    }
    if (onLogin) {
      // Wait for profile to be loaded before redirecting to dashboard
      final hasAccount = profileState.value?.accountUuid != null;
      return hasAccount ? '/dashboard' : null;
    }
    return null;
  },
);
