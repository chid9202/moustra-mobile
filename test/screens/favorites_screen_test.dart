import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/screens/favorites_screen.dart';
import '../test_helpers/test_helpers.dart';

Future<void> pumpFavoritesScreen(WidgetTester tester) async {
  await runZonedGuarded(() async {
    await TestHelpers.pumpWidgetWithTheme(tester, const FavoritesScreen());
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

  group('FavoritesScreen', () {
    testWidgets('renders', (tester) async {
      await pumpFavoritesScreen(tester);
      expect(find.byType(FavoritesScreen), findsOneWidget);
    });
  });
}
