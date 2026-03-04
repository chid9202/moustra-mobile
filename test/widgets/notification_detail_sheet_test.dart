import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/notification_dto.dart';
import 'package:moustra/widgets/notification_detail_sheet.dart';

void main() {
  group('NotificationDetailSheet Widget Tests', () {
    NotificationDto createNotification({
      String? link,
      Map<String, dynamic>? metadata,
    }) {
      return NotificationDto(
        notificationUuid: 'uuid-1',
        notificationType: 'item_update',
        title: 'Test Notification',
        message: 'This is a detailed notification message',
        link: link,
        metadata: metadata,
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      );
    }

    Future<void> pumpSheet(
      WidgetTester tester,
      NotificationDto notification,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) =>
                        NotificationDetailSheet(notification: notification),
                  );
                },
                child: const Text('Open Sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();
    }

    testWidgets('should show title and message', (WidgetTester tester) async {
      await pumpSheet(tester, createNotification());

      expect(find.text('Test Notification'), findsOneWidget);
      expect(
        find.text('This is a detailed notification message'),
        findsOneWidget,
      );
    });

    testWidgets('should show Close button', (WidgetTester tester) async {
      await pumpSheet(tester, createNotification());

      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('should show Open button when link is present', (
      WidgetTester tester,
    ) async {
      await pumpSheet(tester, createNotification(link: '/animal/uuid-1'));

      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('should hide Open button when no link', (
      WidgetTester tester,
    ) async {
      await pumpSheet(tester, createNotification());

      expect(find.text('Open'), findsNothing);
    });

    testWidgets('should show full changes when metadata has changes', (
      WidgetTester tester,
    ) async {
      await pumpSheet(
        tester,
        createNotification(
          metadata: {
            'changes': [
              {
                'field': 'status',
                'label': 'Status',
                'old': 'Active',
                'new': 'Inactive',
              },
            ],
          },
        ),
      );

      expect(find.textContaining('Status'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Inactive'), findsOneWidget);
    });
  });
}
