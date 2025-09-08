import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grid_view/detail_item.dart';
import 'package:grid_view/detail_view.dart';
import 'package:grid_view/interactive_grid_view.dart';
import 'package:grid_view/services/auth_service.dart';
import 'package:grid_view/widgets/app_menu.dart';
import 'package:grid_view/screens/strains_screen.dart';
import 'package:grid_view/screens/cages_list_screen.dart';
import 'package:grid_view/screens/cages_grid_screen.dart';
import 'package:grid_view/screens/litters_screen.dart';
import 'package:grid_view/screens/animals_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      routerConfig: GoRouter(
        routes: [
          ShellRoute(
            pageBuilder: (context, state, child) {
              return MaterialPage(
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
                        valueListenable: _authState,
                        builder: (context, value, _) {
                          final bool loggedIn = value;
                          return IconButton(
                            icon: Icon(loggedIn ? Icons.logout : Icons.login),
                            onPressed: () async {
                              if (loggedIn) {
                                await authService.logout();
                                _authState.value = authService.isLoggedIn;
                              } else {
                                try {
                                  await authService.login();
                                  _authState.value = authService.isLoggedIn;
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Login failed: $e'),
                                      ),
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
              );
            },
            routes: [
              GoRoute(
                path: '/',
                pageBuilder: (context, state) {
                  return MaterialPage(child: InteractiveGridScreen());
                },
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
                path: '/rooms/:roomId',
                pageBuilder: (context, state) {
                  return MaterialPage(
                    child: DetailedItemWidget(
                      item: DetailedItem(
                        title: 'Grid ${state.pathParameters['roomId']}',
                        detailLevel1: 'detailLevel1',
                        detailLevel2: 'detailLevel2',
                        detailLevel3: 'detailLevel3',
                        detailLevel4: 'detailLevel4',
                        detailLevel5: 'detailLevel5',
                      ),
                      detailLevel: 4,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

final ValueNotifier<bool> _authState = ValueNotifier<bool>(
  authService.isLoggedIn,
);
