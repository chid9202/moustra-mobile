import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/widgets/app_bar.dart';
import '../test_helpers/test_helpers.dart';

void main() {
  group('MoustraAppBar Widget Tests', () {
    testWidgets('should render with correct structure', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const Scaffold(appBar: MoustraAppBar(), body: Text('Test Body')),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should have correct preferred size', (
      WidgetTester tester,
    ) async {
      const appBar = MoustraAppBar();
      expect(
        appBar.preferredSize,
        equals(const Size.fromHeight(kToolbarHeight)),
      );
    });

    testWidgets('should display app icon', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const Scaffold(appBar: MoustraAppBar(), body: Text('Test Body')),
      );

      expect(find.byType(Image), findsOneWidget);
      final imageWidget = tester.widget<Image>(find.byType(Image));
      expect(imageWidget.image, isA<AssetImage>());
      expect(
        (imageWidget.image as AssetImage).assetName,
        equals('assets/icons/app_icon.png'),
      );
    });

    testWidgets('should have correct icon dimensions', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const Scaffold(appBar: MoustraAppBar(), body: Text('Test Body')),
      );

      final imageWidget = tester.widget<Image>(find.byType(Image));
      expect(imageWidget.height, equals(64));
      expect(imageWidget.width, equals(64));
    });

    testWidgets('should have menu button', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const Scaffold(appBar: MoustraAppBar(), body: Text('Test Body')),
      );

      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('should have center title', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const Scaffold(appBar: MoustraAppBar(), body: Text('Test Body')),
      );

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.centerTitle, equals(true));
    });

    testWidgets('should have flexible space with app icon', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const Scaffold(appBar: MoustraAppBar(), body: Text('Test Body')),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(GestureDetector), findsAtLeastNWidgets(1));
    });

    testWidgets('should have leading menu button', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const Scaffold(appBar: MoustraAppBar(), body: Text('Test Body')),
      );

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.leading, isNotNull);
      expect(appBar.leading, isA<Builder>());
    });

    testWidgets('should implement PreferredSizeWidget', (
      WidgetTester tester,
    ) async {
      const appBar = MoustraAppBar();
      expect(appBar, isA<PreferredSizeWidget>());
    });

    testWidgets('should have correct alignment for flexible space', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const Scaffold(appBar: MoustraAppBar(), body: Text('Test Body')),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.alignment, equals(Alignment.bottomCenter));
    });

    testWidgets('should have gesture detector for app icon', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const Scaffold(appBar: MoustraAppBar(), body: Text('Test Body')),
      );

      expect(find.byType(GestureDetector), findsAtLeastNWidgets(1));
      final gestureDetectors = tester.widgetList<GestureDetector>(
        find.byType(GestureDetector),
      );
      expect(
        gestureDetectors.any((detector) => detector.onTap != null),
        isTrue,
      );
    });
  });
}
