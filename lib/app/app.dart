import 'package:flutter/material.dart';
import 'package:grid_view/app/router.dart';
import 'package:grid_view/app/theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(theme: appTheme, routerConfig: appRouter);
  }
}
