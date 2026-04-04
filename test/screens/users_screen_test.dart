import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/screens/users_screen.dart';
import 'package:moustra/widgets/shared/button.dart';
import '../test_helpers/test_helpers.dart';

Future<void> pumpUsersScreen(WidgetTester tester) async {
  await runZonedGuarded(() async {
    await TestHelpers.pumpWidgetWithTheme(tester, const UsersScreen());
    await tester.pump();
  }, (error, stack) {});
}

void main() {
  setUpAll(() async {
    installNoOpDioApiClient();
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      dotenv.loadFromString(envString: '', isOptional: true);
    }
  });

  tearDownAll(() {
    restoreDioApiClient();
  });

  group('UsersScreen', () {
    testWidgets('renders', (tester) async {
      await pumpUsersScreen(tester);
      expect(find.byType(UsersScreen), findsOneWidget);
    });

    testWidgets('has Create User action', (tester) async {
      await pumpUsersScreen(tester);
      expect(find.text('Create User'), findsOneWidget);
      expect(find.byType(MoustraButton), findsWidgets);
    });
  });
}
