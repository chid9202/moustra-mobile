import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/screens/animal_new_screen.dart';

void main() {
  group('AnimalNewScreen', () {
    testWidgets('can be instantiated without errors', (
      WidgetTester tester,
    ) async {
      // Test that the screen can be created without throwing exceptions
      expect(() => const AnimalNewScreen(), returnsNormally);
      expect(
        () => const AnimalNewScreen(cageUuid: 'test-uuid'),
        returnsNormally,
      );
      expect(() => const AnimalNewScreen(fromCageGrid: true), returnsNormally);
    });

    testWidgets('has correct constructor parameters', (
      WidgetTester tester,
    ) async {
      // Test constructor parameter handling
      const screen1 = AnimalNewScreen();
      const screen2 = AnimalNewScreen(cageUuid: 'test-cage-uuid');
      const screen3 = AnimalNewScreen(fromCageGrid: true);
      const screen4 = AnimalNewScreen(
        cageUuid: 'test-cage-uuid',
        fromCageGrid: true,
      );

      // All should be created successfully
      expect(screen1, isA<AnimalNewScreen>());
      expect(screen2, isA<AnimalNewScreen>());
      expect(screen3, isA<AnimalNewScreen>());
      expect(screen4, isA<AnimalNewScreen>());
    });

    testWidgets('has proper widget structure', (WidgetTester tester) async {
      // Test that the screen is a StatefulWidget
      const screen = AnimalNewScreen();
      expect(screen, isA<StatefulWidget>());

      // Test that it can be converted to a widget
      expect(screen.createState(), isA<State<AnimalNewScreen>>());
    });

    testWidgets('handles parameter combinations correctly', (
      WidgetTester tester,
    ) async {
      // Test various parameter combinations
      const combinations = [
        AnimalNewScreen(),
        AnimalNewScreen(cageUuid: 'uuid1'),
        AnimalNewScreen(fromCageGrid: true),
        AnimalNewScreen(cageUuid: 'uuid2', fromCageGrid: true),
      ];

      for (final screen in combinations) {
        expect(screen, isA<AnimalNewScreen>());
        expect(screen.createState(), isA<State<AnimalNewScreen>>());
      }
    });
  });
}
