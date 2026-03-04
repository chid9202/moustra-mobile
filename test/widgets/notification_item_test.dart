import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/notification_dto.dart';
import 'package:moustra/widgets/notification_item.dart';
import '../test_helpers/test_helpers.dart';

void main() {
  group('NotificationItem Widget Tests', () {
    NotificationDto createNotification({
      bool isRead = false,
      String type = 'system',
      Map<String, dynamic>? metadata,
    }) {
      return NotificationDto(
        notificationUuid: 'uuid-1',
        notificationType: type,
        title: 'Test Title',
        message: 'Test message content',
        isRead: isRead,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        metadata: metadata,
      );
    }

    testWidgets('should render title and message', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        NotificationItem(
          notification: createNotification(),
          onTap: () {},
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test message content'), findsOneWidget);
    });

    testWidgets('should show bold title when unread', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        NotificationItem(
          notification: createNotification(isRead: false),
          onTap: () {},
        ),
      );

      final titleWidget = tester.widget<Text>(find.text('Test Title'));
      expect(titleWidget.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('should not show bold title when read', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        NotificationItem(
          notification: createNotification(isRead: true),
          onTap: () {},
        ),
      );

      final titleWidget = tester.widget<Text>(find.text('Test Title'));
      expect(titleWidget.style?.fontWeight, isNot(FontWeight.bold));
    });

    testWidgets('should show blue dot when unread', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        NotificationItem(
          notification: createNotification(isRead: false),
          onTap: () {},
        ),
      );

      final containers = tester.widgetList<Container>(find.byType(Container));
      final blueDot = containers.where(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration as BoxDecoration).color == Colors.blue &&
            (c.decoration as BoxDecoration).shape == BoxShape.circle,
      );
      expect(blueDot.length, 1);
    });

    testWidgets('should show correct icon for type', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        NotificationItem(
          notification: createNotification(type: 'protocol_alert'),
          onTap: () {},
        ),
      );

      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('should show relative timestamp', (
      WidgetTester tester,
    ) async {
      await TestHelpers.pumpWidgetWithTheme(
        tester,
        NotificationItem(
          notification: createNotification(),
          onTap: () {},
        ),
      );

      expect(find.text('2h ago'), findsOneWidget);
    });
  });
}
