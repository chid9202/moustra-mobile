import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:moustra/app/app.dart';
import 'package:moustra/config/env.dart';
import 'package:moustra/services/auth_service.dart';
import 'package:moustra/services/error_report_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables; allow override via --dart-define=ENV_FILENAME=<file>
  const String envFileName = String.fromEnvironment(
    'ENV_FILENAME',
    defaultValue: '.env',
  );
  await dotenv.load(fileName: envFileName);

  // Initialize Stripe
  final stripeKey = Env.stripePublishableKey;
  if (stripeKey.isNotEmpty) {
    Stripe.publishableKey = stripeKey;
  }

  await authService.init();

  // Set up global error handlers
  FlutterError.onError = (FlutterErrorDetails details) {
    // Report Flutter framework errors
    reportError(error: details.exception, stackTrace: details.stack);
    // Also log to console in debug mode
    FlutterError.presentError(details);
  };

  // Catch async errors that aren't caught by Flutter
  runZonedGuarded(
    () {
      runApp(const MyApp());
    },
    (error, stackTrace) {
      // Report uncaught async errors
      reportError(error: error, stackTrace: stackTrace);
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => const App();
}
