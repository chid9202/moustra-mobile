import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/screens/dashboard/mice_count_by_age.dart';

void main() {
  group('MouseCountByAge', () {
    testWidgets('renders title and dropdown with data', (
      WidgetTester tester,
    ) async {
      final data = <String, dynamic>{
        'accounts': <String, dynamic>{},
        'animalByAge': <dynamic>[
          {
            'strainUuid': '00000000-0000-0000-0000-000000000000',
            'strainName': 'All',
            'ageData': <dynamic>[
              {'ageInWeeks': 4, 'count': 10},
              {'ageInWeeks': 8, 'count': 5},
            ],
          },
        ],
        'animalsSexRatio': <dynamic>[],
        'animalsToWean': <dynamic>[],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MouseCountByAge(data),
            ),
          ),
        ),
      );

      expect(find.text('Mice Count by Age'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('renders with empty animalByAge data', (
      WidgetTester tester,
    ) async {
      final data = <String, dynamic>{
        'accounts': <String, dynamic>{},
        'animalByAge': <dynamic>[],
        'animalsSexRatio': <dynamic>[],
        'animalsToWean': <dynamic>[],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MouseCountByAge(data),
            ),
          ),
        ),
      );

      expect(find.text('Mice Count by Age'), findsOneWidget);
    });

    testWidgets('renders with multiple strains', (
      WidgetTester tester,
    ) async {
      final data = <String, dynamic>{
        'accounts': <String, dynamic>{},
        'animalByAge': <dynamic>[
          {
            'strainUuid': '00000000-0000-0000-0000-000000000000',
            'strainName': 'All',
            'ageData': <dynamic>[
              {'ageInWeeks': 4, 'count': 15},
            ],
          },
          {
            'strainUuid': 'strain-uuid-1',
            'strainName': 'C57BL/6',
            'ageData': <dynamic>[
              {'ageInWeeks': 4, 'count': 10},
            ],
          },
        ],
        'animalsSexRatio': <dynamic>[],
        'animalsToWean': <dynamic>[],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MouseCountByAge(data),
            ),
          ),
        ),
      );

      expect(find.text('Mice Count by Age'), findsOneWidget);
      expect(find.byType(MouseCountByAge), findsOneWidget);
    });
  });
}
