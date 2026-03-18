import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/screens/barcode_scanner_screen.dart';

void main() {
  group('BarcodeScannerScreen', () {
    testWidgets('renders scaffold with app bar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const BarcodeScannerScreen(),
        ),
      );

      // The scaffold and app bar should render even if camera fails
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Scan Barcode'), findsOneWidget);
    });

    testWidgets('has close button in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const BarcodeScannerScreen(),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('has keyboard (manual entry) button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const BarcodeScannerScreen(),
        ),
      );

      expect(find.byIcon(Icons.keyboard), findsOneWidget);
    });

    testWidgets('renders BarcodeScannerScreen widget', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const BarcodeScannerScreen(),
        ),
      );

      expect(find.byType(BarcodeScannerScreen), findsOneWidget);
    });
  });
}
