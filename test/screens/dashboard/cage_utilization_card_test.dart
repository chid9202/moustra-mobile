import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/screens/dashboard/cage_utilization_card.dart';

void main() {
  group('CageUtilizationCard', () {
    testWidgets('shows title and no-data message when cageUtilization is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CageUtilizationCard(null),
          ),
        ),
      );

      expect(find.text('Cage Utilization'), findsOneWidget);
      expect(find.text('No cage utilization data available'), findsOneWidget);
    });

    testWidgets('shows lab utilization when data is provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CageUtilizationCard({
              'labUtilizationPercentage': 0.75,
              'cagesAtRisk': <dynamic>[],
              'cagesAtRiskCount': 0,
              'cagesInViolation': <dynamic>[],
              'cagesInViolationCount': 0,
            }),
          ),
        ),
      );

      expect(find.text('Cage Utilization'), findsOneWidget);
      expect(find.text('Lab Utilization'), findsOneWidget);
      // labUtilizationPercentage is stored as decimal (0.75 = 75%)
      expect(find.text('0.75%'), findsOneWidget);
    });

    testWidgets('shows cages at risk count when non-zero',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CageUtilizationCard({
                'labUtilizationPercentage': 0.65,
                'cagesAtRisk': [
                  {'cageUuid': 'cage-1', 'cageTag': 'C001'},
                ],
                'cagesAtRiskCount': 1,
                'cagesInViolation': <dynamic>[],
                'cagesInViolationCount': 0,
              }),
            ),
          ),
        ),
      );

      expect(find.text('Cage Utilization'), findsOneWidget);
      expect(find.textContaining('At Risk'), findsWidgets);
    });
  });
}
