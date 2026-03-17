import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/widgets/state_widgets.dart';

void main() {
  group('AppLoadingWidget', () {
    testWidgets('shows spinner', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AppLoadingWidget())),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows message when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppLoadingWidget(message: 'Loading data...')),
        ),
      );
      expect(find.text('Loading data...'), findsOneWidget);
    });

    testWidgets('hides message when null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AppLoadingWidget())),
      );
      // Only spinner, no text
      expect(find.byType(Text), findsNothing);
    });
  });

  group('AppErrorWidget', () {
    testWidgets('shows error message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppErrorWidget(message: 'Something went wrong')),
        ),
      );
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows retry button when callback provided', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppErrorWidget(
              message: 'Error',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );
      expect(find.text('Retry'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });

    testWidgets('hides retry button when no callback', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppErrorWidget(message: 'Error')),
        ),
      );
      expect(find.text('Retry'), findsNothing);
    });
  });

  group('AppEmptyWidget', () {
    testWidgets('shows message and default icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppEmptyWidget(message: 'No items found')),
        ),
      );
      expect(find.text('No items found'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('shows CTA button when provided', (tester) async {
      var ctaTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppEmptyWidget(
              message: 'Empty',
              ctaLabel: 'Add Item',
              onCta: () => ctaTapped = true,
            ),
          ),
        ),
      );
      expect(find.text('Add Item'), findsOneWidget);
      await tester.tap(find.text('Add Item'));
      expect(ctaTapped, isTrue);
    });

    testWidgets('uses custom icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppEmptyWidget(message: 'Empty', icon: Icons.search_off),
          ),
        ),
      );
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });
  });
}
