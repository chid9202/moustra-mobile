import 'package:flutter/material.dart';
import 'package:moustra/app/mui_color.dart';
import 'package:moustra/app/router.dart';
import 'package:moustra/app/theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: appTheme, // Light theme
      darkTheme: darkTheme.copyWith(
        scaffoldBackgroundColor: darkColorScheme.surface,
        appBarTheme: AppBarTheme(
          backgroundColor: darkColorScheme.surface,
          foregroundColor: darkColorScheme.onSurface,
          elevation: 0,
        ),
      ),
      themeMode: ThemeMode.system, // Follows system preference
      routerConfig: appRouter,
      builder: (context, child) {
        // Override textScaleFactor to ensure consistent text rendering
        // across simulator and physical device, regardless of iOS accessibility settings
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}
