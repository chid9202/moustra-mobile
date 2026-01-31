import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:moustra/app/app.dart';
import 'package:moustra/services/auth_service.dart';

import 'robots/dashboard_robot.dart';
import 'robots/login_robot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Load test environment variables
    await dotenv.load(fileName: '.env.test');

    // Initialize auth service
    await authService.init();
  });

  group('Login and Dashboard Flow', () {
    testWidgets('successful login navigates to dashboard', (tester) async {
      // 1. Load app with test configuration
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      // 2. Verify login screen is displayed
      final loginRobot = LoginRobot(tester);
      await loginRobot.verifyLoginScreenDisplayed();

      // 3. Get credentials from .env.test
      final email = dotenv.env['TEST_EMAIL'];
      final password = dotenv.env['TEST_PASSWORD'];

      // Ensure credentials are configured
      expect(
        email,
        isNotNull,
        reason: 'TEST_EMAIL must be set in .env.test',
      );
      expect(
        password,
        isNotNull,
        reason: 'TEST_PASSWORD must be set in .env.test',
      );

      // 4. Enter credentials
      await loginRobot.enterEmail(email!);
      await loginRobot.enterPassword(password!);

      // 5. Tap Sign In and wait for auth + navigation
      await loginRobot.tapSignIn();

      // Wait for network operations (Auth0 login + profile fetch + navigation)
      // Using longer timeout to accommodate real network calls
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // 6. Verify dashboard is loaded with cards
      final dashboardRobot = DashboardRobot(tester);
      await dashboardRobot.verifyDashboardLoaded();
    });
  });
}
