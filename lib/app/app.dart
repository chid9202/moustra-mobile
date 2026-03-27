import 'package:flutter/material.dart';
import 'package:moustra/app/router.dart';
import 'package:moustra/app/theme.dart';
import 'package:moustra/services/connectivity_service.dart';
import 'package:moustra/stores/theme_store.dart';
import 'package:upgrader/upgrader.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeStore,
      builder: (context, themeMode, _) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: appTheme, // Light theme
          darkTheme: appDarkTheme,
          themeMode: themeMode,
          routerConfig: appRouter,
          builder: (context, child) {
            // Override textScaleFactor to ensure consistent text rendering
            // across simulator and physical device, regardless of iOS accessibility settings
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.0)),
              child: UpgradeAlert(
                navigatorKey: appRouter.routerDelegate.navigatorKey,
                barrierDismissible: false,
                showIgnore: false,
                showLater: false,
                child: Column(
                  children: [
                    // Offline banner
                    ValueListenableBuilder<bool>(
                      valueListenable: connectivityService.isOnline,
                      builder: (context, online, _) {
                        if (online) return const SizedBox.shrink();
                        return Material(
                          child: Container(
                            width: double.infinity,
                            color: Colors.orange.shade800,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: SafeArea(
                              bottom: false,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.wifi_off,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'No internet connection',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // Main app content
                    Expanded(child: child!),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
