import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:moustra/app/app.dart';
import 'package:moustra/services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables; allow override via --dart-define=ENV_FILENAME=<file>
  const String envFileName = String.fromEnvironment(
    'ENV_FILENAME',
    defaultValue: '.env',
  );
  await dotenv.load(fileName: envFileName);

  await authService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => const App();
}
