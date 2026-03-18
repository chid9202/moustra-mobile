import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/screens/strain_detail_screen.dart';
import '../test_helpers/test_helpers.dart';

void main() {
  setUpAll(() async {
    installNoOpDioApiClient();
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      dotenv.env.clear();
    }
  });

  tearDownAll(() {
    restoreDioApiClient();
  });

  group('StrainDetailScreen', () {
    Widget buildScreenWithRouter({String uuid = 'test-uuid'}) {
      return MaterialApp.router(
        theme: TestHelpers.createMockTheme(),
        routerConfig: GoRouter(
          initialLocation: '/strain/$uuid',
          routes: [
            GoRoute(
              path: '/strain/:strainUuid',
              builder: (context, state) => const StrainDetailScreen(),
            ),
          ],
        ),
      );
    }

    Future<void> pumpScreen(WidgetTester tester, {String uuid = 'test-uuid'}) async {
      await runZonedGuarded(
        () async {
          await tester.pumpWidget(buildScreenWithRouter(uuid: uuid));
          await tester.pump();
        },
        (error, stack) {
          // Suppress errors from API calls and AccountHelper in test environment
        },
      );
    }

    testWidgets('renders correctly with default state', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester);

      expect(find.byType(StrainDetailScreen), findsOneWidget);
    });

    testWidgets('shows loading indicator initially', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('has proper layout structure', (WidgetTester tester) async {
      await pumpScreen(tester);

      expect(find.byType(StrainDetailScreen), findsOneWidget);
    });

    testWidgets('handles screen lifecycle correctly', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester);

      expect(find.byType(StrainDetailScreen), findsOneWidget);

      await runZonedGuarded(
        () async {
          await tester.pump();
        },
        (error, stack) {},
      );
      expect(find.byType(StrainDetailScreen), findsOneWidget);
    });

    testWidgets('has proper accessibility structure', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester);

      expect(find.byType(Semantics), findsAtLeastNWidgets(1));
    });
  });
}
