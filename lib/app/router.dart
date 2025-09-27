import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/screens/animal_detail_screen.dart';
import 'package:moustra/screens/animal_new_screen.dart';
import 'package:moustra/screens/cage_detail_screen.dart';
import 'package:moustra/screens/litter_detail_screen.dart';
import 'package:moustra/screens/mating_detail_screen.dart';
import 'package:moustra/screens/strain_detail_screen.dart';
import 'package:moustra/stores/auth_store.dart';
import 'package:moustra/stores/profile_store.dart';
import 'package:moustra/widgets/app_bar.dart';
import 'package:moustra/widgets/app_menu.dart';
import 'package:moustra/screens/strains_screen.dart';
import 'package:moustra/screens/cages_list_screen.dart';
import 'package:moustra/screens/cages_grid_screen.dart';
import 'package:moustra/screens/litters_screen.dart';
import 'package:moustra/screens/animals_screen.dart';
import 'package:moustra/screens/matings_screen.dart';
import 'package:moustra/screens/users_screen.dart';
import 'package:moustra/screens/user_detail_screen.dart';
import 'package:moustra/screens/dashboard_screen.dart';
import 'package:moustra/services/auth_service.dart';
import 'package:moustra/screens/login_screen.dart';

final GoRouter appRouter = GoRouter(
  refreshListenable: authState,
  routes: [
    // Login routes without AppBar
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => const MaterialPage(child: LoginScreen()),
    ),
    GoRoute(path: '/', redirect: (context, state) => '/login'),
    ShellRoute(
      pageBuilder: (context, state, child) => MaterialPage(
        child: Scaffold(
          appBar: const MoustraAppBar(),
          drawer: const AppMenu(),
          body: child,
        ),
      ),
      routes: [
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
          path: '/strains/:strainUuid',
          pageBuilder: (context, state) =>
              const MaterialPage(child: StrainDetailScreen()),
        ),
        GoRoute(
          path: '/strains/new',
          pageBuilder: (context, state) =>
              const MaterialPage(child: StrainDetailScreen()),
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
          path: '/cages/new',
          pageBuilder: (context, state) =>
              const MaterialPage(child: CageDetailScreen()),
        ),
        GoRoute(
          path: '/cages/:cageUuid',
          pageBuilder: (context, state) =>
              const MaterialPage(child: CageDetailScreen()),
        ),
        GoRoute(
          path: '/litters',
          pageBuilder: (context, state) =>
              const MaterialPage(child: LittersScreen()),
        ),
        GoRoute(
          path: '/litters/new',
          pageBuilder: (context, state) =>
              const MaterialPage(child: LitterDetailScreen()),
        ),
        GoRoute(
          path: '/litters/:litterUuid',
          pageBuilder: (context, state) =>
              const MaterialPage(child: LitterDetailScreen()),
        ),
        GoRoute(
          path: '/animals',
          pageBuilder: (context, state) =>
              const MaterialPage(child: AnimalsScreen()),
        ),
        GoRoute(
          path: '/animals/new',
          pageBuilder: (context, state) {
            final cageUuid = state.uri.queryParameters['cageUuid'];
            return MaterialPage(child: AnimalNewScreen(cageUuid: cageUuid));
          },
        ),
        GoRoute(
          path: '/animals/:animalUuid',
          pageBuilder: (context, state) =>
              const MaterialPage(child: AnimalDetailScreen()),
        ),
        GoRoute(
          path: '/matings',
          pageBuilder: (context, state) =>
              const MaterialPage(child: MatingsScreen()),
        ),
        GoRoute(
          path: '/matings/new',
          pageBuilder: (context, state) =>
              const MaterialPage(child: MatingDetailScreen()),
        ),
        GoRoute(
          path: '/matings/:matingUuid',
          pageBuilder: (context, state) =>
              const MaterialPage(child: MatingDetailScreen()),
        ),
        GoRoute(
          path: '/users',
          pageBuilder: (context, state) =>
              const MaterialPage(child: UsersScreen()),
        ),
        GoRoute(
          path: '/users/new',
          pageBuilder: (context, state) =>
              const MaterialPage(child: UserDetailScreen(isNew: true)),
        ),
        GoRoute(
          path: '/users/:userUuid',
          pageBuilder: (context, state) => MaterialPage(
            child: UserDetailScreen(userUuid: state.pathParameters['userUuid']),
          ),
        ),
      ],
    ),
  ],
  redirect: (context, state) {
    final path = state.uri.path;
    final onLogin = path == '/login';
    print('path $path');

    if (!authService.isLoggedIn) {
      print('not logged in');
      return onLogin
          ? null
          : '/login?from=${Uri.encodeComponent(state.uri.toString())}';
    }
    if (onLogin) {
      print('on login');
      // Wait for profile to be loaded before redirecting to dashboard
      final hasAccount = profileState.value?.accountUuid != null;
      return hasAccount ? '/dashboard' : null;
    }
    print('logged in');
    return null;
  },
);
