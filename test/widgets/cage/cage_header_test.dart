import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/widgets/cage/cage_header.dart';
import '../../test_helpers/test_helpers.dart';

void main() {
  group('CageHeader', () {
    testWidgets('renders cage tag', (WidgetTester tester) async {
      final cage = RackCageDto(
        cageUuid: 'uuid-1',
        cageTag: 'C042',
      );

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        CageHeader(cage: cage),
      );

      expect(find.text('C042'), findsOneWidget);
    });

    testWidgets('renders "Unnamed" when cageTag is null', (
      WidgetTester tester,
    ) async {
      final cage = RackCageDto(
        cageUuid: 'uuid-1',
        cageTag: null,
      );

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        CageHeader(cage: cage),
      );

      expect(find.text('Unnamed'), findsOneWidget);
    });

    testWidgets('renders strain name when present', (
      WidgetTester tester,
    ) async {
      final cage = RackCageDto(
        cageUuid: 'uuid-1',
        cageTag: 'C042',
        strain: RackCageStrainDto(
          strainUuid: 'strain-1',
          strainName: 'B6-Cre',
        ),
      );

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        CageHeader(cage: cage),
      );

      // Text.rich uses TextSpan children, so find.text won't match individual spans.
      // Instead check the RichText content via textSpan.
      final richText = tester.widget<Text>(find.byType(Text).first);
      final textSpan = richText.textSpan! as TextSpan;
      final allText = textSpan.children!
          .whereType<TextSpan>()
          .map((s) => s.text ?? '')
          .join();
      expect(allText, contains('C042'));
      expect(allText, contains('B6-Cre'));
    });

    testWidgets('does not render strain name when null', (
      WidgetTester tester,
    ) async {
      final cage = RackCageDto(
        cageUuid: 'uuid-1',
        cageTag: 'C042',
        strain: null,
      );

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        CageHeader(cage: cage),
      );

      expect(find.text('C042'), findsOneWidget);
      // Only the cage tag TextSpan should be present
      final richText = tester.widget<Text>(find.byType(Text).first);
      final textSpan = richText.textSpan! as TextSpan;
      // With no strain, there should be only one child (cage tag)
      expect(textSpan.children!.length, equals(1));
    });

    testWidgets('does not show menu by default', (WidgetTester tester) async {
      final cage = RackCageDto(
        cageUuid: 'uuid-1',
        cageTag: 'C042',
      );

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        CageHeader(cage: cage),
      );

      // The more_vert icon from CageHeaderMenu should not be present
      expect(find.byIcon(Icons.more_vert), findsNothing);
    });

    testWidgets('renders with dark theme', (WidgetTester tester) async {
      final cage = RackCageDto(
        cageUuid: 'uuid-1',
        cageTag: 'DarkCage',
        strain: RackCageStrainDto(
          strainUuid: 'strain-1',
          strainName: 'TestStrain',
        ),
      );

      await TestHelpers.pumpWidgetWithTheme(
        tester,
        CageHeader(cage: cage),
        theme: TestHelpers.createDarkTheme(),
      );

      final richText = tester.widget<Text>(find.byType(Text).first);
      final textSpan = richText.textSpan! as TextSpan;
      final allText = textSpan.children!
          .whereType<TextSpan>()
          .map((s) => s.text ?? '')
          .join();
      expect(allText, contains('DarkCage'));
      expect(allText, contains('TestStrain'));
    });
  });
}
