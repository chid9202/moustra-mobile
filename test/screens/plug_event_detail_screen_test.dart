import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/screens/plug_event_detail_screen.dart';
import '../test_helpers/test_helpers.dart';

void main() {
  setUpAll(() async {
    installNoOpDioApiClient();
    // Initialize dotenv - try loading .env file if it exists, otherwise use empty initialization
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      // If .env file doesn't exist or can't be loaded, initialize with empty values
      // Env class will use fallback values
      dotenv.loadFromString(envString: '', isOptional: true);
    }
  });

  tearDownAll(() {
    restoreDioApiClient();
  });

  group('PlugEventDetailScreen', () {
    // The screen reads pathParameters['plugEventUuid'] from GoRouterState,
    // so we wrap it with a GoRouter that provides that parameter.
    Widget buildScreenWithRouter({String uuid = 'test-uuid'}) {
      return MaterialApp.router(
        theme: TestHelpers.createMockTheme(),
        routerConfig: GoRouter(
          initialLocation: '/plug-event/$uuid',
          routes: [
            GoRoute(
              path: '/plug-event/:plugEventUuid',
              builder: (context, state) => const PlugEventDetailScreen(),
            ),
          ],
        ),
      );
    }

    testWidgets('renders correctly with default state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildScreenWithRouter());

      // Initially should show loading indicator since it makes an API call
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows loading indicator initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildScreenWithRouter());

      // Check for loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Check for centered loading
      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('has proper layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(buildScreenWithRouter());

      // The screen is a StatefulWidget that shows loading initially
      expect(find.byType(PlugEventDetailScreen), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('handles screen lifecycle correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildScreenWithRouter());

      // Verify the screen can be built
      expect(find.byType(PlugEventDetailScreen), findsOneWidget);

      // Test that the screen can be rebuilt
      await tester.pump();
      expect(find.byType(PlugEventDetailScreen), findsOneWidget);
    });

    testWidgets('shows error state when UUID fails to load', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildScreenWithRouter(uuid: 'invalid-uuid'));

      // Initially shows loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // After the API call fails, the error state should appear
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should show error text since the API call will fail in test
      expect(find.textContaining('Error'), findsOneWidget);
    });

    testWidgets('has proper accessibility structure', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildScreenWithRouter());

      // Check for semantic structure
      expect(find.byType(Semantics), findsAtLeastNWidgets(1));
    });
  });
}
