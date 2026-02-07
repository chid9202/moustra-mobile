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
import 'package:moustra/screens/settings_screen.dart';
import 'package:moustra/services/auth_service.dart';
import 'package:moustra/services/error_context_service.dart';
import 'package:moustra/screens/login_screen.dart';
import 'package:moustra/screens/signup_screen.dart';

/// Navigation observer for tracking error context
final errorContextNavigationObserver = ErrorContextNavigationObserver();

final GoRouter appRouter = GoRouter(
  refreshListenable: authState,
  observers: [errorContextNavigationObserver],
  routes: [
    // Login routes without AppBar
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => const MaterialPage(child: LoginScreen()),
    ),
    GoRoute(
      path: '/signup',
      pageBuilder: (context, state) =>
          const MaterialPage(child: SignupScreen()),
    ),
    GoRoute(
      path: '/logout',
      redirect: (context, state) async {
        await authService.logout();
        return '/login';
      },
    ),
    GoRoute(path: '/', redirect: (context, state) => '/login'),
    ShellRoute(
      pageBuilder: (context, state, child) => MaterialPage(
        child: Scaffold(
          appBar: const MoustraAppBar(),
          drawer: AppMenu(),
          body: SafeArea(child: child),
        ),
      ),
      routes: [
        GoRoute(
          path: '/dashboard',
          pageBuilder: (context, state) =>
              const MaterialPage(child: DashboardScreen()),
        ),
        GoRoute(
          path: '/strain',
          pageBuilder: (context, state) =>
              const MaterialPage(child: StrainsScreen()),
        ),
        GoRoute(
          path: '/strain/:strainUuid',
          pageBuilder: (context, state) =>
              const MaterialPage(child: StrainDetailScreen()),
        ),
        GoRoute(
          path: '/strain/new',
          pageBuilder: (context, state) =>
              const MaterialPage(child: StrainDetailScreen()),
        ),
        GoRoute(
          path: '/cage/list',
          pageBuilder: (context, state) =>
              const MaterialPage(child: CagesListScreen()),
        ),
        GoRoute(
          path: '/cage/grid',
          pageBuilder: (context, state) =>
              const MaterialPage(child: CagesGridScreen()),
        ),
        GoRoute(
          path: '/cage/new',
          pageBuilder: (context, state) =>
              const MaterialPage(child: CageDetailScreen()),
        ),
        GoRoute(
          path: '/cage/:cageUuid',
          pageBuilder: (context, state) {
            final fromCageGrid =
                state.uri.queryParameters['fromCageGrid'] == 'true';
            return MaterialPage(
              child: CageDetailScreen(fromCageGrid: fromCageGrid),
            );
          },
        ),
        GoRoute(
          path: '/litter',
          pageBuilder: (context, state) =>
              const MaterialPage(child: LittersScreen()),
        ),
        GoRoute(
          path: '/litter/new',
          pageBuilder: (context, state) {
            final matingUuid = state.uri.queryParameters['matingUuid'];
            final fromCageGrid =
                state.uri.queryParameters['fromCageGrid'] == 'true';
            return MaterialPage(
              child: LitterDetailScreen(
                matingUuid: matingUuid,
                fromCageGrid: fromCageGrid,
              ),
            );
          },
        ),
        GoRoute(
          path: '/litter/:litterUuid',
          pageBuilder: (context, state) {
            final fromCageGrid =
                state.uri.queryParameters['fromCageGrid'] == 'true';
            return MaterialPage(
              child: LitterDetailScreen(fromCageGrid: fromCageGrid),
            );
          },
        ),
        GoRoute(
          path: '/animal',
          pageBuilder: (context, state) =>
              const MaterialPage(child: AnimalsScreen()),
        ),
        GoRoute(
          path: '/animal/new',
          pageBuilder: (context, state) {
            final cageUuid = state.uri.queryParameters['cageUuid'];
            final fromCageGrid =
                state.uri.queryParameters['fromCageGrid'] == 'true';
            return MaterialPage(
              child: AnimalNewScreen(
                cageUuid: cageUuid,
                fromCageGrid: fromCageGrid,
              ),
            );
          },
        ),
        GoRoute(
          path: '/animal/:animalUuid',
          pageBuilder: (context, state) {
            final fromCageGrid =
                state.uri.queryParameters['fromCageGrid'] == 'true';
            return MaterialPage(
              child: AnimalDetailScreen(fromCageGrid: fromCageGrid),
            );
          },
        ),
        GoRoute(
          path: '/mating',
          pageBuilder: (context, state) =>
              const MaterialPage(child: MatingsScreen()),
        ),
        GoRoute(
          path: '/mating/new',
          pageBuilder: (context, state) =>
              const MaterialPage(child: MatingDetailScreen()),
        ),
        GoRoute(
          path: '/mating/:matingUuid',
          pageBuilder: (context, state) {
            final fromCageGrid =
                state.uri.queryParameters['fromCageGrid'] == 'true';
            return MaterialPage(
              child: MatingDetailScreen(fromCageGrid: fromCageGrid),
            );
          },
        ),
        GoRoute(
          path: '/user',
          pageBuilder: (context, state) =>
              const MaterialPage(child: UsersScreen()),
        ),
        GoRoute(
          path: '/user/new',
          pageBuilder: (context, state) =>
              const MaterialPage(child: UserDetailScreen(isNew: true)),
        ),
        GoRoute(
          path: '/user/:userUuid',
          pageBuilder: (context, state) => MaterialPage(
            child: UserDetailScreen(userUuid: state.pathParameters['userUuid']),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) =>
              const MaterialPage(child: SettingsScreen()),
        ),
      ],
    ),
  ],
  redirect: (context, state) {
    final path = state.uri.path;
    final onAuthPage = path == '/login' || path == '/signup';
    debugPrint('path $path');

    if (!authService.isLoggedIn) {
      debugPrint('not logged in');
      return onAuthPage
          ? null
          : '/login?from=${Uri.encodeComponent(state.uri.toString())}';
    }
    if (onAuthPage) {
      debugPrint('on auth page');
      // Wait for profile to be loaded before redirecting to dashboard
      final hasAccount = profileState.value?.accountUuid != null;
      return hasAccount ? '/dashboard' : null;
    }
    debugPrint('logged in');
    return null;
  },
);
