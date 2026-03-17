import 'package:flutter/material.dart';
import 'package:grid_view/app/app.dart';
import 'package:grid_view/app/router.dart';
import 'package:grid_view/config/api_config.dart';
import 'package:grid_view/config/auth0.dart';
import 'package:grid_view/services/auth_service.dart';
import 'package:grid_view/services/session_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final hasSession = await sessionService.loadSession();
  if (hasSession) {
    ApiConfig.accountUuid = sessionService.accountUuid;
    // Try to restore Auth0 credentials from the credentials manager.
    // This gives us a valid access token for API calls on restart.
    try {
      final hasCredentials =
          await auth0.credentialsManager.hasValidCredentials();
      if (hasCredentials) {
        final credentials = await auth0.credentialsManager.credentials();
        authService.restoreCredentials(credentials);
        authState.value = true;
      }
    } catch (_) {
      // Credentials expired or unavailable — user will need to log in again.
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => const App();
}
