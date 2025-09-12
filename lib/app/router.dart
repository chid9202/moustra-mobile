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

final ValueNotifier<bool> authState = ValueNotifier<bool>(
  authService.isLoggedIn,
);

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
                  print('authState ------> $value $context');
                  final bool loggedIn = value;
                  return IconButton(
                    icon: Icon(loggedIn ? Icons.logout : Icons.login),
                    onPressed: () async {
                      if (loggedIn) {
                        print('aaaaaaaaaaaaaaaaaaaaaaaaa 11');
                        await authService.logout();
                        // authState.value = false;
                        print('aaaaaaaaaaaaaaaaaaaaaaaaa 22');
                        // if (context.mounted) context.go('/login');
                      } else {
                        print('bbbbbbbbbbbbbbbbbbbbbbbbbbbb');
                        // try {
                        //   await authService.login();
                        //   authState.value = authService.isLoggedIn;
                        //   if (context.mounted) context.go('/');
                        // } catch (e) {
                        //   if (context.mounted) {
                        //     ScaffoldMessenger.of(context).showSnackBar(
                        //       SnackBar(content: Text('Login failed: $e')),
                        //     );
                        //   }
                        // }
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
        // Swallow native callback paths so GoRouter doesn't try to match them
        // GoRoute(
        //   path: '/android/:rest(.*)',
        //   pageBuilder: (context, state) {
        //     WidgetsBinding.instance.addPostFrameCallback((_) {
        //       print('android callback ------> $authService.isLoggedIn');
        //       final String next = authService.isLoggedIn
        //           ? '/dashboard'
        //           : '/login';
        //       if (context.mounted) context.go(next);
        //     });
        //     return const MaterialPage(child: SizedBox.shrink());
        //   },
        // ),
        GoRoute(
          path: '/ios/:rest(.*)',
          pageBuilder: (context, state) =>
              const MaterialPage(child: SizedBox.shrink()),
        ),
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) =>
              const MaterialPage(child: LoginScreen()),
        ),
        GoRoute(
          path: '/logout',
          pageBuilder: (context, state) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              print('android logout callback ------> $authService.isLoggedIn');
              if (context.mounted) context.go('/login');
            });
            return const MaterialPage(child: SizedBox.shrink());
          },
        ),
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
    if (onLogin) return '/dashboard';
    return null;
  },
  // redirect: (context, state) {
  //   // Implement redirect logic based on authentication status
  //   // For example, if not authenticated, redirect to login page
  //   print(
  //     'redirect 11 start ------> ${authService.isLoggedIn} ${state.matchedLocation}',
  //   );
  //   if (authService.isLoggedIn) {
  //     if (state.matchedLocation == '/') {
  //       print('redirect 22 logged in / ------> /dashboard');
  //       return '/dashboard';
  //     }
  //     if (state.matchedLocation == '/login') {
  //       print('redirect 33 logged in /login ------> /login');
  //       return '/dashboard';
  //     }
  //     print('redirect 44 logged in ------> null ${state.matchedLocation}');
  //     return state.matchedLocation;
  //   }

  //   if (!authService.isLoggedIn) {
  //     print('redirect 55 logged out ------> /login');
  //     return '/login';
  //   }
  //   print('redirect 66 ------> null');
  //   return null;
  // },
);
