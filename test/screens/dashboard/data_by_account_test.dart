import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/screens/dashboard/data_by_account.dart';

void main() {
  group('DataByAccount', () {
    testWidgets('renders title and legend', (WidgetTester tester) async {
      final accounts = <String, dynamic>{
        'acc-1': {
          'name': 'Lab A',
          'animalsCount': 20,
          'cagesCount': 5,
          'matingsCount': 3,
          'littersCount': 2,
        },
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DataByAccount(accounts),
            ),
          ),
        ),
      );

      expect(find.text('Data by Account'), findsOneWidget);
      expect(find.text('Animals'), findsOneWidget);
      expect(find.text('Cages'), findsOneWidget);
      expect(find.text('Matings'), findsOneWidget);
      expect(find.text('Litters'), findsOneWidget);
    });

    testWidgets('renders with empty accounts', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DataByAccount(const <String, dynamic>{}),
            ),
          ),
        ),
      );

      expect(find.text('Data by Account'), findsOneWidget);
    });

    testWidgets('renders with multiple accounts', (
      WidgetTester tester,
    ) async {
      final accounts = <String, dynamic>{
        'acc-1': {
          'name': 'Lab A',
          'animalsCount': 20,
          'cagesCount': 5,
          'matingsCount': 3,
          'littersCount': 2,
        },
        'acc-2': {
          'name': 'Lab B',
          'animalsCount': 15,
          'cagesCount': 8,
          'matingsCount': 1,
          'littersCount': 0,
        },
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DataByAccount(accounts),
            ),
          ),
        ),
      );

      expect(find.byType(DataByAccount), findsOneWidget);
    });
  });
}
