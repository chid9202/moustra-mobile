import 'package:flutter/material.dart';
import 'package:moustra/app/router.dart';
import 'package:moustra/app/theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(theme: appTheme, routerConfig: appRouter);
  }
}
