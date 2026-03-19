import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:moustra/app/app.dart';
import 'package:moustra/config/env.dart';
import 'package:moustra/services/auth_service.dart';
import 'package:moustra/services/connectivity_service.dart';
import 'package:moustra/services/error_report_service.dart';
import 'package:moustra/stores/theme_store.dart';

/// Keep semantics handle alive for the entire app lifetime (debug only).
/// Without this, the handle gets GC'd and the accessibility tree disappears.
Object? debugSemanticsHandle;

Future<void> main() async {
  // Set up Flutter framework error handler (zone-independent)
  FlutterError.onError = (FlutterErrorDetails details) {
    reportError(error: details.exception, stackTrace: details.stack);
    FlutterError.presentError(details);
  };

  // Catch async errors that aren't caught by Flutter
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Force-enable the semantics tree so UI testing tools (Maestro, etc.)
      // can discover Flutter widgets via iOS accessibility APIs.
      // The handle is stored in a top-level variable to prevent GC.
      if (kDebugMode) {
        debugSemanticsHandle = SemanticsBinding.instance.ensureSemantics();
      }

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

      connectivityService.init();
      ErrorReportService.initSession();
      await initThemeStore();
      await authService.init();

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
