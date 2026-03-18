import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/screens/dashboard/mice_by_sex.dart';

void main() {
  group('MiceBySex', () {
    testWidgets('renders with male, female, and unknown data', (
      WidgetTester tester,
    ) async {
      final sexData = <dynamic>[
        {'sex': 'M', 'count': 10},
        {'sex': 'F', 'count': 8},
        {'sex': null, 'count': 2},
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MiceBySex(sexData),
          ),
        ),
      );

      expect(find.text('Male'), findsOneWidget);
      expect(find.text('Female'), findsOneWidget);
      expect(find.text('Unknown'), findsOneWidget);
    });

    testWidgets('renders with empty data', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MiceBySex([]),
          ),
        ),
      );

      // Indicators should still be shown
      expect(find.text('Male'), findsOneWidget);
      expect(find.text('Female'), findsOneWidget);
      expect(find.text('Unknown'), findsOneWidget);
    });

    testWidgets('renders with only males', (WidgetTester tester) async {
      final sexData = <dynamic>[
        {'sex': 'M', 'count': 5},
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MiceBySex(sexData),
          ),
        ),
      );

      expect(find.byType(MiceBySex), findsOneWidget);
    });

    testWidgets('renders Indicator widget correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Indicator(
              color: Colors.blue,
              text: 'Test',
              isSquare: false,
            ),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('Indicator with square shape', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Indicator(
              color: Colors.red,
              text: 'Square',
              isSquare: true,
            ),
          ),
        ),
      );

      expect(find.text('Square'), findsOneWidget);
    });
  });
}
