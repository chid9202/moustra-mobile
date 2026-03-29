import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/integration_test_helpers.dart';
import '../robots/dashboard_robot.dart';

/// Fast smoke: credentials, login, dashboard shell. Run on CI or before releases.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await loadIntegrationTestEnv();
  });

  group('Smoke: Login and Dashboard', () {
    testWidgets('successful login navigates to dashboard', (tester) async {
      await pumpAppAndSignIn(tester);

      final dashboardRobot = DashboardRobot(tester);
      await dashboardRobot.verifyDashboardLoaded();
    });
  });
}
