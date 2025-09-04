import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grid_view/detail_item.dart';
import 'package:grid_view/detail_view.dart';
import 'package:grid_view/interactive_grid_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: GoRouter(
        routes: [
          ShellRoute(
            pageBuilder: (context, state, child) {
              return MaterialPage(
                child: Scaffold(
                  appBar: AppBar(
                    title: const Center(child: Text('Moustra')),
                    leading: GoRouter.of(context).state.path != '/'
                        ? IconButton(
                            icon: Icon(Icons.arrow_back_ios_rounded),
                            onPressed: () {
                              GoRouter.of(context).go('/');
                            },
                          )
                        : null,
                  ),
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
