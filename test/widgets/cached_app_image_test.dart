import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/widgets/cached_app_image.dart';
import '../test_helpers/test_helpers.dart';

void main() {
  group('CachedAppImage', () {
    testWidgets('renders CachedNetworkImage with imageUrl', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const CachedAppImage(imageUrl: 'https://example.com/image.png'),
      );

      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });

    testWidgets('passes width and height to CachedNetworkImage', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const CachedAppImage(
          imageUrl: 'https://example.com/image.png',
          width: 100,
          height: 200,
        ),
      );

      final cachedImage = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      expect(cachedImage.width, 100);
      expect(cachedImage.height, 200);
    });

    testWidgets('uses BoxFit.cover by default', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const CachedAppImage(imageUrl: 'https://example.com/image.png'),
      );

      final cachedImage = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      expect(cachedImage.fit, BoxFit.cover);
    });

    testWidgets('uses custom BoxFit when provided', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const CachedAppImage(
          imageUrl: 'https://example.com/image.png',
          fit: BoxFit.contain,
        ),
      );

      final cachedImage = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      expect(cachedImage.fit, BoxFit.contain);
    });

    testWidgets('has null width and height by default', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const CachedAppImage(imageUrl: 'https://example.com/image.png'),
      );

      final cachedImage = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      expect(cachedImage.width, isNull);
      expect(cachedImage.height, isNull);
    });

    testWidgets('does not include auth headers by default', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const CachedAppImage(imageUrl: 'https://example.com/image.png'),
      );

      final cachedImage = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      expect(cachedImage.httpHeaders, isNull);
    });

    testWidgets('accepts includeAuthHeaders parameter', (
      WidgetTester tester,
    ) async {
      const widget = CachedAppImage(
        imageUrl: 'https://example.com/image.png',
        includeAuthHeaders: true,
      );
      expect(widget.includeAuthHeaders, isTrue);
    });

    testWidgets('renders correctly with all parameters', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const CachedAppImage(
          imageUrl: 'https://example.com/image.png',
          width: 150,
          height: 150,
          fit: BoxFit.fill,
        ),
      );

      final cachedImage = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      expect(cachedImage.imageUrl, 'https://example.com/image.png');
      expect(cachedImage.width, 150);
      expect(cachedImage.height, 150);
      expect(cachedImage.fit, BoxFit.fill);
    });

    testWidgets('is a StatelessWidget', (WidgetTester tester) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        const CachedAppImage(imageUrl: 'https://example.com/image.png'),
      );

      expect(find.byType(CachedAppImage), findsOneWidget);
    });
  });
}
