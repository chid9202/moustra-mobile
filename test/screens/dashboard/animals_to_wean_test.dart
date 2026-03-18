import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/screens/dashboard/animals_to_wean.dart';

void main() {
  group('AnimalsToWean', () {
    testWidgets('shows empty message when no animals', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimalsToWean([]),
          ),
        ),
      );

      expect(find.text('Animals To Wean'), findsOneWidget);
      expect(find.text('No animals to wean'), findsOneWidget);
    });

    testWidgets('shows animal data when provided', (
      WidgetTester tester,
    ) async {
      final animals = <dynamic>[
        {
          'physicalTag': 'A001',
          'weanDate': '2026-03-20T00:00:00Z',
          'cage': {'cageTag': 'C001'},
        },
        {
          'physicalTag': 'A002',
          'weanDate': '2026-03-21T00:00:00Z',
          'cage': {'cageTag': 'C002'},
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AnimalsToWean(animals),
            ),
          ),
        ),
      );

      expect(find.text('Animals To Wean'), findsOneWidget);
      expect(find.text('A001'), findsOneWidget);
      expect(find.text('A002'), findsOneWidget);
      expect(find.text('C001'), findsOneWidget);
      expect(find.text('C002'), findsOneWidget);
    });

    testWidgets('shows (no tag) for animals without physicalTag', (
      WidgetTester tester,
    ) async {
      final animals = <dynamic>[
        {
          'physicalTag': '',
          'weanDate': '',
          'cage': {'cageTag': 'C001'},
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AnimalsToWean(animals),
            ),
          ),
        ),
      );

      expect(find.text('(no tag)'), findsOneWidget);
    });

    testWidgets('limits displayed animals to 10', (
      WidgetTester tester,
    ) async {
      final animals = List.generate(
        15,
        (i) => {
          'physicalTag': 'TAG-$i',
          'weanDate': '2026-03-20T00:00:00Z',
          'cage': {'cageTag': 'C-$i'},
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AnimalsToWean(animals),
            ),
          ),
        ),
      );

      // Should show first 10 but not the 11th
      expect(find.text('TAG-0'), findsOneWidget);
      expect(find.text('TAG-9'), findsOneWidget);
      expect(find.text('TAG-10'), findsNothing);
    });
  });
}
