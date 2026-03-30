import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/screens/rack_detail_screen.dart';
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

  group('RackDetailScreen', () {
    Future<void> pumpScreen(WidgetTester tester) async {
      await runZonedGuarded(
        () async {
          await tester.pumpWidget(
            MaterialApp.router(
              theme: TestHelpers.createMockTheme(),
              routerConfig: GoRouter(
                initialLocation: '/rack/rack-uuid-1',
                routes: [
                  GoRoute(
                    path: '/rack/:rackUuid',
                    builder: (context, state) => const RackDetailScreen(),
                  ),
                ],
              ),
            ),
          );
          await tester.pump();
        },
        (error, stack) {},
      );
    }

    testWidgets('renders', (tester) async {
      await pumpScreen(tester);
      expect(find.byType(RackDetailScreen), findsOneWidget);
    });
  });
}
