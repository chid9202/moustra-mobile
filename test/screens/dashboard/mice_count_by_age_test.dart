import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/screens/dashboard/mice_count_by_age.dart';

void main() {
  group('MouseCountByAge', () {
    testWidgets('renders title and dropdown with bucketed data', (
      WidgetTester tester,
    ) async {
      final data = <String, dynamic>{
        'accounts': <String, dynamic>{},
        'animalByAge': <dynamic>[
          {
            'strainUuid': '00000000-0000-0000-0000-000000000000',
            'strainName': 'All',
            'ageData': <dynamic>[
              {'ageBucket': '0-4 wk', 'count': 10, 'sortOrder': 0},
              {'ageBucket': '4-8 wk', 'count': 5, 'sortOrder': 1},
              {'ageBucket': '8-12 wk', 'count': 0, 'sortOrder': 2},
              {'ageBucket': '12-26 wk', 'count': 3, 'sortOrder': 3},
              {'ageBucket': '26-52 wk', 'count': 0, 'sortOrder': 4},
              {'ageBucket': '52+ wk', 'count': 1, 'sortOrder': 5},
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
              {'ageBucket': '0-4 wk', 'count': 15, 'sortOrder': 0},
              {'ageBucket': '4-8 wk', 'count': 0, 'sortOrder': 1},
              {'ageBucket': '8-12 wk', 'count': 0, 'sortOrder': 2},
              {'ageBucket': '12-26 wk', 'count': 0, 'sortOrder': 3},
              {'ageBucket': '26-52 wk', 'count': 0, 'sortOrder': 4},
              {'ageBucket': '52+ wk', 'count': 0, 'sortOrder': 5},
            ],
          },
          {
            'strainUuid': 'strain-uuid-1',
            'strainName': 'C57BL/6',
            'ageData': <dynamic>[
              {'ageBucket': '0-4 wk', 'count': 10, 'sortOrder': 0},
              {'ageBucket': '4-8 wk', 'count': 0, 'sortOrder': 1},
              {'ageBucket': '8-12 wk', 'count': 0, 'sortOrder': 2},
              {'ageBucket': '12-26 wk', 'count': 0, 'sortOrder': 3},
              {'ageBucket': '26-52 wk', 'count': 0, 'sortOrder': 4},
              {'ageBucket': '52+ wk', 'count': 0, 'sortOrder': 5},
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
