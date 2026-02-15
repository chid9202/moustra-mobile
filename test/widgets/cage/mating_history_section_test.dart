import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/mating_history_dto.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/services/dtos/strain_dto.dart';
import 'package:moustra/widgets/cage/mating_history_section.dart';
import '../../test_helpers/test_helpers.dart';

void main() {
  group('MatingHistorySection', () {
    testWidgets('should render section title and count', (tester) async {
      final matings = [
        MatingHistoryDto(matingUuid: 'uuid-1', matingTag: 'M001'),
        MatingHistoryDto(matingUuid: 'uuid-2', matingTag: 'M002'),
      ];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SingleChildScrollView(
          child: MatingHistorySection(matings: matings),
        ),
      );

      expect(find.text('Mating History'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('should display mating tag when present', (tester) async {
      final matings = [
        MatingHistoryDto(matingUuid: 'uuid-1', matingTag: 'M001'),
      ];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SingleChildScrollView(
          child: MatingHistorySection(matings: matings),
        ),
      );

      expect(find.text('M001'), findsOneWidget);
    });

    testWidgets('should show "(no tag)" when matingTag is null', (tester) async {
      final matings = [
        MatingHistoryDto(matingUuid: 'uuid-1', matingTag: null),
      ];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SingleChildScrollView(
          child: MatingHistorySection(matings: matings),
        ),
      );

      expect(find.text('(no tag)'), findsOneWidget);
    });

    testWidgets('should show Active chip for non-disbanded mating', (tester) async {
      final matings = [
        MatingHistoryDto(
          matingUuid: 'uuid-1',
          matingTag: 'M001',
          disbandedDate: null,
        ),
      ];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SingleChildScrollView(
          child: MatingHistorySection(matings: matings),
        ),
      );

      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('should show Disbanded chip when disbandedDate exists', (tester) async {
      final matings = [
        MatingHistoryDto(
          matingUuid: 'uuid-1',
          matingTag: 'M001',
          disbandedDate: DateTime(2023, 12, 1),
        ),
      ];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SingleChildScrollView(
          child: MatingHistorySection(matings: matings),
        ),
      );

      expect(find.text('Disbanded'), findsOneWidget);
    });

    testWidgets('should display strain name', (tester) async {
      final matings = [
        MatingHistoryDto(
          matingUuid: 'uuid-1',
          matingTag: 'M001',
          litterStrain: StrainSummaryDto(
            strainId: 1,
            strainUuid: 'strain-uuid-1',
            strainName: 'C57BL/6',
          ),
        ),
      ];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SingleChildScrollView(
          child: MatingHistorySection(matings: matings),
        ),
      );

      expect(find.textContaining('C57BL/6'), findsOneWidget);
    });

    testWidgets('should show litter tag when present', (tester) async {
      final matings = [
        MatingHistoryDto(
          matingUuid: 'uuid-1',
          matingTag: 'M001',
          litters: [
            MatingHistoryLitterDto(
              litterUuid: 'litter-uuid-1',
              litterTag: 'L001',
              dateOfBirth: DateTime(2023, 7, 15),
            ),
          ],
        ),
      ];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SingleChildScrollView(
          child: MatingHistorySection(matings: matings),
        ),
      );

      expect(find.text('L001'), findsOneWidget);
      expect(find.text('Litter: '), findsOneWidget);
    });

    testWidgets('should show "(no tag)" when litterTag is null', (tester) async {
      final matings = [
        MatingHistoryDto(
          matingUuid: 'uuid-1',
          matingTag: 'M001',
          litters: [
            MatingHistoryLitterDto(
              litterUuid: 'litter-uuid-1',
              litterTag: null,
              dateOfBirth: DateTime(2023, 7, 15),
            ),
          ],
        ),
      ];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SingleChildScrollView(
          child: MatingHistorySection(matings: matings),
        ),
      );

      // One "(no tag)" for the litter (mating has a tag 'M001')
      expect(find.text('(no tag)'), findsOneWidget);
    });

    testWidgets('should display sex breakdown chips for litter animals', (tester) async {
      final matings = [
        MatingHistoryDto(
          matingUuid: 'uuid-1',
          matingTag: 'M001',
          litters: [
            MatingHistoryLitterDto(
              litterUuid: 'litter-uuid-1',
              litterTag: 'L001',
              dateOfBirth: DateTime(2023, 7, 15),
              animals: [
                AnimalSummaryDto(
                  animalId: 1,
                  animalUuid: 'a-1',
                  physicalTag: 'A001',
                  sex: 'male',
                  dateOfBirth: DateTime(2023, 7, 15),
                ),
                AnimalSummaryDto(
                  animalId: 2,
                  animalUuid: 'a-2',
                  physicalTag: 'A002',
                  sex: 'male',
                  dateOfBirth: DateTime(2023, 7, 15),
                ),
                AnimalSummaryDto(
                  animalId: 3,
                  animalUuid: 'a-3',
                  physicalTag: 'A003',
                  sex: 'female',
                  dateOfBirth: DateTime(2023, 7, 15),
                ),
              ],
            ),
          ],
        ),
      ];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SingleChildScrollView(
          child: MatingHistorySection(matings: matings),
        ),
      );

      expect(find.text('2 M'), findsOneWidget);
      expect(find.text('1 F'), findsOneWidget);
    });

    testWidgets('should show multiple matings', (tester) async {
      final matings = [
        MatingHistoryDto(matingUuid: 'uuid-1', matingTag: 'M001'),
        MatingHistoryDto(matingUuid: 'uuid-2', matingTag: 'M002'),
        MatingHistoryDto(matingUuid: 'uuid-3', matingTag: 'M003'),
      ];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SingleChildScrollView(
          child: MatingHistorySection(matings: matings),
        ),
      );

      expect(find.text('3'), findsOneWidget); // count chip
      expect(find.text('M001'), findsOneWidget);
      expect(find.text('M002'), findsOneWidget);
      expect(find.text('M003'), findsOneWidget);
    });

    testWidgets('should format set up date correctly', (tester) async {
      final matings = [
        MatingHistoryDto(
          matingUuid: 'uuid-1',
          matingTag: 'M001',
          setUpDate: DateTime(2023, 6, 1),
        ),
      ];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SingleChildScrollView(
          child: MatingHistorySection(matings: matings),
        ),
      );

      expect(find.textContaining('Set up: 06/01/2023'), findsOneWidget);
    });

    testWidgets('should format disbanded date correctly', (tester) async {
      final matings = [
        MatingHistoryDto(
          matingUuid: 'uuid-1',
          matingTag: 'M001',
          disbandedDate: DateTime(2023, 12, 15),
        ),
      ];

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        SingleChildScrollView(
          child: MatingHistorySection(matings: matings),
        ),
      );

      expect(find.textContaining('Disbanded: 12/15/2023'), findsOneWidget);
    });
  });
}
