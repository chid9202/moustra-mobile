import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:moustra/app/app.dart';
import 'package:moustra/services/auth_service.dart';
import 'package:moustra/stores/profile_store.dart';

import '../robots/login_robot.dart';

/// Load [.env.test] and initialize auth (call from [setUpAll]).
Future<void> loadIntegrationTestEnv() async {
  await dotenv.load(fileName: '.env.test');
  await authService.init();
}

/// Pump [App], sign in with [TEST_EMAIL] / [TEST_PASSWORD], wait for profile.
Future<void> pumpAppAndSignIn(WidgetTester tester) async {
  await tester.pumpWidget(const App());
  await tester.pumpAndSettle();

  final loginRobot = LoginRobot(tester);
  await loginRobot.verifyLoginScreenDisplayed();

  final email = dotenv.env['TEST_EMAIL'];
  final password = dotenv.env['TEST_PASSWORD'];
  expect(email, isNotNull, reason: 'TEST_EMAIL must be set in .env.test');
  expect(password, isNotNull, reason: 'TEST_PASSWORD must be set in .env.test');

  await loginRobot.enterEmail(email!);
  await loginRobot.enterPassword(password!);
  await loginRobot.tapSignIn();
  await tester.pumpAndSettle(const Duration(seconds: 15));

  expect(
    profileState.value,
    isNotNull,
    reason: 'Profile should load after successful login',
  );
}
