import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/screens/protocol_form_screen.dart';
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

  group('ProtocolFormScreen', () {
    Widget buildNewProtocolScreen() {
      return MaterialApp.router(
        theme: TestHelpers.createMockTheme(),
        routerConfig: GoRouter(
          initialLocation: '/protocol/new',
          routes: [
            GoRoute(
              path: '/protocol/new',
              builder: (context, state) => const ProtocolFormScreen(),
            ),
            GoRoute(
              path: '/protocol',
              builder: (context, state) =>
                  const Scaffold(body: Text('Protocols')),
            ),
          ],
        ),
      );
    }

    testWidgets('renders form for new protocol', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildNewProtocolScreen());
      await tester.pump();

      expect(find.text('New Protocol'), findsOneWidget);
      expect(find.text('Protocol Number *'), findsOneWidget);
      expect(find.text('Title *'), findsOneWidget);
      expect(find.text('Species *'), findsOneWidget);
      expect(find.text('Max Animal Count *'), findsOneWidget);
    });

    testWidgets('shows pain category chips', (WidgetTester tester) async {
      await tester.pumpWidget(buildNewProtocolScreen());
      await tester.pump();

      expect(find.text('Pain Category *'), findsOneWidget);
      expect(find.text('Category B'), findsOneWidget);
      expect(find.text('Category C'), findsOneWidget);
      expect(find.text('Category D'), findsOneWidget);
      expect(find.text('Category E'), findsOneWidget);
    });

    testWidgets('shows date fields', (WidgetTester tester) async {
      await tester.pumpWidget(buildNewProtocolScreen());
      await tester.pump();

      expect(find.text('Dates'), findsOneWidget);
      expect(find.text('Approval Date'), findsOneWidget);
      expect(find.text('Effective Date'), findsOneWidget);
      expect(find.text('Expiration Date *'), findsOneWidget);
    });

    testWidgets('shows create protocol button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildNewProtocolScreen());
      await tester.pump();

      expect(find.text('Create Protocol'), findsOneWidget);
    });

    testWidgets('shows alert threshold slider', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildNewProtocolScreen());
      await tester.pump();

      expect(find.textContaining('Alert Threshold'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('default species is Mus musculus', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildNewProtocolScreen());
      await tester.pump();

      // The species field should have default text
      final textField = tester.widget<TextFormField>(
        find.byType(TextFormField).at(2), // Species is the 3rd TextFormField
      );
      expect(textField.controller?.text, 'Mus musculus');
    });
  });
}
