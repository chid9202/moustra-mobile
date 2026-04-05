import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moustra/app/app.dart';
import 'package:moustra/app/app_bootstrap.dart';
import 'package:moustra/services/error_report_service.dart';

Future<void> main() async {
  configureFlutterErrorReporting();

  // Catch async errors that aren't caught by Flutter
  runZonedGuarded(
    () async {
      const String envFileName = String.fromEnvironment(
        'ENV_FILENAME',
        defaultValue: '.env',
      );
      await initializeApp(envFileName: envFileName);

      runApp(const MyApp());
    },
    (error, stackTrace) {
      reportError(error: error, stackTrace: stackTrace);
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => const App();
}
