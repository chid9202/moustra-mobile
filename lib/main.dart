import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:moustra/app/app.dart';
import 'package:moustra/config/env.dart';
import 'package:moustra/services/auth_service.dart';
import 'package:moustra/services/connectivity_service.dart';
import 'package:moustra/services/error_report_service.dart';
import 'package:moustra/services/session_service.dart';
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

      // Flutter 3.41.x bug: iOS sends ContextMenu.onDismissSystemContextMenu
      // spuriously at startup when no SystemContextMenuClient is registered,
      // triggering a debug assert in ServicesBinding._handlePlatformMessage
      // that pauses the debugger on every cold start.
      //
      // Fix: replace the platform channel handler before the message arrives
      // so ServicesBinding._handlePlatformMessage is never reached for these
      // messages. The assert is a no-op in release builds.
      if (kDebugMode) {
        _suppressSpuriousContextMenuMessages();
      }

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

      if (authService.isLoggedIn) {
        try {
          await setupSession();
        } catch (_) {
          // Transient failure — tokens preserved, LoginScreen will retry.
        }
      }

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

/// Replaces the default [ServicesBinding] platform message handler with one
/// that silently drops ContextMenu dismiss/action messages, avoiding the
/// Flutter 3.41.x debug assert in binding.dart that pauses the debugger on
/// every cold start when iOS sends these messages with no registered client.
///
/// Only called in debug mode — the assert is stripped in release builds.
void _suppressSpuriousContextMenuMessages() {
  SystemChannels.platform.setMethodCallHandler((call) async {
    switch (call.method) {
      case 'ContextMenu.onDismissSystemContextMenu':
      case 'ContextMenu.onPerformCustomAction':
        return null;
      case 'System.requestAppExit':
        return {
          'response':
              (await ServicesBinding.instance.handleRequestAppExit()).name,
        };
      case 'SystemChrome.systemUIChange':
        return null;
      default:
        throw AssertionError('Method "${call.method}" not handled.');
    }
  });
}
