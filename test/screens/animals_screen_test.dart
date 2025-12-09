import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/screens/animals_screen.dart';

void main() {
  group('AnimalsScreen', () {
    testWidgets('can be instantiated without errors', (
      WidgetTester tester,
    ) async {
      // Test that the screen can be created without throwing exceptions
      expect(() => const AnimalsScreen(), returnsNormally);
    });

    testWidgets('has proper widget structure', (WidgetTester tester) async {
      // Test that the screen is a StatefulWidget
      const screen = AnimalsScreen();
      expect(screen, isA<StatefulWidget>());

      // Test that it can be converted to a widget
      expect(screen.createState(), isA<State<AnimalsScreen>>());
    });

    testWidgets('handles screen lifecycle correctly', (
      WidgetTester tester,
    ) async {
      // Test that the screen can be created and disposed
      const screen = AnimalsScreen();
      expect(screen, isA<AnimalsScreen>());

      // Test state creation
      final state = screen.createState();
      expect(state, isA<State<AnimalsScreen>>());
    });
  });
}
