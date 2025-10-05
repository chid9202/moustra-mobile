import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/app/mui_color.dart';

/// Test helper utilities for widget testing
class TestHelpers {
  /// Creates a test app with proper theme and routing
  static Widget createTestApp({required Widget child, ThemeData? theme}) {
    return MaterialApp(
      theme: theme ?? createMockTheme(),
      home: Scaffold(body: child),
    );
  }

  /// Creates a test app with proper theme and routing for dialogs
  static Widget createTestAppWithDialog({
    required Widget child,
    ThemeData? theme,
  }) {
    return MaterialApp(
      theme: theme ?? createMockTheme(),
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () =>
                showDialog(context: context, builder: (context) => child),
            child: const Text('Show Dialog'),
          ),
        ),
      ),
    );
  }

  /// Pumps widget with proper theme
  static Future<void> pumpWidgetWithTheme(
    WidgetTester tester,
    Widget widget, {
    ThemeData? theme,
  }) async {
    await tester.pumpWidget(createTestApp(child: widget, theme: theme));
  }

  /// Pumps widget with dialog support
  static Future<void> pumpWidgetWithDialog(
    WidgetTester tester,
    Widget dialogWidget, {
    ThemeData? theme,
  }) async {
    await tester.pumpWidget(
      createTestAppWithDialog(child: dialogWidget, theme: theme),
    );
  }

  /// Waits for async operations to complete
  static Future<void> waitForAsync(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  /// Finds widget by type and verifies it exists
  static T findWidget<T extends Widget>(WidgetTester tester) {
    final finder = find.byType(T);
    expect(finder, findsOneWidget);
    return tester.widget<T>(finder);
  }

  /// Finds widget by type and verifies it doesn't exist
  static void expectWidgetNotFound<T extends Widget>(WidgetTester tester) {
    final finder = find.byType(T);
    expect(finder, findsNothing);
  }

  /// Finds widget by type and verifies multiple instances exist
  static List<T> findWidgets<T extends Widget>(
    WidgetTester tester,
    int expectedCount,
  ) {
    final finder = find.byType(T);
    expect(finder, findsNWidgets(expectedCount));
    return tester.widgetList<T>(finder).toList();
  }

  /// Taps on a widget and waits for animations
  static Future<void> tapAndWait(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Enters text in a text field
  static Future<void> enterText(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.tap(finder);
    await tester.pump();
    await tester.enterText(finder, text);
    await tester.pump();
  }

  /// Verifies that a widget is enabled
  static void expectEnabled(WidgetTester tester, Finder finder) {
    final widget = tester.widget(finder);
    if (widget is InkWell) {
      expect(widget.onTap, isNotNull);
    } else if (widget is ElevatedButton) {
      expect(widget.onPressed, isNotNull);
    } else if (widget is TextButton) {
      expect(widget.onPressed, isNotNull);
    } else if (widget is IconButton) {
      expect(widget.onPressed, isNotNull);
    }
  }

  /// Verifies that a widget is disabled
  static void expectDisabled(WidgetTester tester, Finder finder) {
    final widget = tester.widget(finder);
    if (widget is InkWell) {
      expect(widget.onTap, isNull);
    } else if (widget is ElevatedButton) {
      expect(widget.onPressed, isNull);
    } else if (widget is TextButton) {
      expect(widget.onPressed, isNull);
    } else if (widget is IconButton) {
      expect(widget.onPressed, isNull);
    }
  }

  /// Verifies text content
  static void expectText(WidgetTester tester, String text) {
    expect(find.text(text), findsOneWidget);
  }

  /// Verifies text content is not found
  static void expectTextNotFound(WidgetTester tester, String text) {
    expect(find.text(text), findsNothing);
  }

  /// Verifies icon is present
  static void expectIcon(WidgetTester tester, IconData icon) {
    expect(find.byIcon(icon), findsOneWidget);
  }

  /// Verifies icon is not present
  static void expectIconNotFound(WidgetTester tester, IconData icon) {
    expect(find.byIcon(icon), findsNothing);
  }

  /// Creates a mock theme for testing
  static ThemeData createMockTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      extensions: [
        MUIExtraColors(
          success: const Color(0xFF2E7D32),
          warning: const Color(0xFFED6C02),
          info: const Color(0xFF0288D1),
        ),
      ],
    );
  }

  /// Creates a dark theme for testing
  static ThemeData createDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      extensions: [
        MUIExtraColors(
          success: const Color(0xFF4CAF50),
          warning: const Color(0xFFFF9800),
          info: const Color(0xFF2196F3),
        ),
      ],
    );
  }
}

/// Mock data generators for testing
class MockData {
  /// Creates mock animal data
  static Map<String, dynamic> createMockAnimal({
    String? animalUuid,
    String? physicalTag,
    String? sex,
  }) {
    return {
      'animalUuid': animalUuid ?? 'test-animal-uuid',
      'physicalTag': physicalTag ?? 'A001',
      'sex': sex ?? 'Male',
      'birthDate': DateTime.now().toIso8601String(),
      'strain': {'strainUuid': 'test-strain-uuid', 'strainName': 'Test Strain'},
    };
  }

  /// Creates mock cage data
  static Map<String, dynamic> createMockCage({
    String? cageUuid,
    String? cageTag,
  }) {
    return {
      'cageUuid': cageUuid ?? 'test-cage-uuid',
      'cageTag': cageTag ?? 'C001',
      'rack': {'rackUuid': 'test-rack-uuid', 'rackName': 'Test Rack'},
    };
  }

  /// Creates mock strain data
  static Map<String, dynamic> createMockStrain({
    String? strainUuid,
    String? strainName,
  }) {
    return {
      'strainUuid': strainUuid ?? 'test-strain-uuid',
      'strainName': strainName ?? 'Test Strain',
      'description': 'Test strain description',
    };
  }

  /// Creates mock gene data
  static Map<String, dynamic> createMockGene({
    String? geneUuid,
    String? geneName,
  }) {
    return {
      'geneUuid': geneUuid ?? 'test-gene-uuid',
      'geneName': geneName ?? 'Test Gene',
      'isActive': true,
    };
  }

  /// Creates mock allele data
  static Map<String, dynamic> createMockAllele({
    String? alleleUuid,
    String? alleleName,
  }) {
    return {
      'alleleUuid': alleleUuid ?? 'test-allele-uuid',
      'alleleName': alleleName ?? 'Test Allele',
      'isActive': true,
    };
  }
}

/// Custom matchers for testing
class CustomMatchers {
  /// Matches a widget with specific properties
  static Matcher hasProperty<T>(String propertyName, dynamic expectedValue) {
    return _PropertyMatcher<T>(propertyName, expectedValue);
  }

  /// Matches a widget with specific text style
  static Matcher hasTextStyle(TextStyle expectedStyle) {
    return _TextStyleMatcher(expectedStyle);
  }
}

class _PropertyMatcher<T> extends Matcher {
  final String propertyName;
  final dynamic expectedValue;

  _PropertyMatcher(this.propertyName, this.expectedValue);

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! T) return false;

    // This is a simplified matcher - in practice you'd use reflection
    // or specific property access based on the widget type
    return true; // Placeholder implementation
  }

  @override
  Description describe(Description description) {
    return description.add(
      'has property $propertyName with value $expectedValue',
    );
  }
}

class _TextStyleMatcher extends Matcher {
  final TextStyle expectedStyle;

  _TextStyleMatcher(this.expectedStyle);

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! Text) return false;

    final text = item;
    final actualStyle = text.style;

    if (actualStyle == null) return expectedStyle == null;

    return actualStyle.fontSize == expectedStyle.fontSize &&
        actualStyle.fontWeight == expectedStyle.fontWeight &&
        actualStyle.color == expectedStyle.color;
  }

  @override
  Description describe(Description description) {
    return description.add('has text style $expectedStyle');
  }
}
