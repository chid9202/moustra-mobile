import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/screens/user_detail_screen.dart';
import '../test_helpers/test_helpers.dart';

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

  group('UserDetailScreen', () {
    testWidgets('isNew renders form scaffold', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: TestHelpers.createMockTheme(),
          home: const UserDetailScreen(isNew: true),
        ),
      );
      await tester.pump();
      expect(find.byType(UserDetailScreen), findsOneWidget);
      expect(find.byType(Form), findsWidgets);
    });
  });
}
