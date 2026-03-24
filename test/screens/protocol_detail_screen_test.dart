import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/screens/protocol_detail_screen.dart';
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

  group('ProtocolDetailScreen', () {
    Widget buildScreenWithRouter({String uuid = 'test-uuid'}) {
      return MaterialApp.router(
        theme: TestHelpers.createMockTheme(),
        routerConfig: GoRouter(
          initialLocation: '/protocol/$uuid',
          routes: [
            GoRoute(
              path: '/protocol/:protocolUuid',
              builder: (context, state) => const ProtocolDetailScreen(),
            ),
          ],
        ),
      );
    }

    testWidgets('shows loading indicator initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildScreenWithRouter());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders the ProtocolDetailScreen widget', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildScreenWithRouter());

      expect(find.byType(ProtocolDetailScreen), findsOneWidget);
    });

    testWidgets('shows error state after API failure', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildScreenWithRouter(uuid: 'invalid-uuid'));

      // Initially shows loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // After the API call fails
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should show error state
      expect(find.textContaining('Error'), findsOneWidget);
    });

    testWidgets('handles screen lifecycle correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildScreenWithRouter());

      expect(find.byType(ProtocolDetailScreen), findsOneWidget);

      await tester.pump();
      expect(find.byType(ProtocolDetailScreen), findsOneWidget);
    });
  });
}
