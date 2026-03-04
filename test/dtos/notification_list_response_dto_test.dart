import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/notification_list_response_dto.dart';

void main() {
  group('NotificationListResponseDto Tests', () {
    test('should create from JSON with notifications', () {
      final json = {
        'notifications': [
          {
            'notificationUuid': 'uuid-1',
            'notificationType': 'system',
            'title': 'Test',
            'message': 'Test message',
            'isRead': false,
            'createdAt': '2026-03-04T10:00:00.000Z',
          },
        ],
        'count': 1,
        'unreadCount': 1,
      };

      final dto = NotificationListResponseDto.fromJson(json);

      expect(dto.notifications.length, 1);
      expect(dto.notifications[0].title, 'Test');
      expect(dto.count, 1);
      expect(dto.unreadCount, 1);
    });

    test('should handle empty notifications list', () {
      final json = {
        'notifications': [],
        'count': 0,
        'unreadCount': 0,
      };

      final dto = NotificationListResponseDto.fromJson(json);

      expect(dto.notifications, isEmpty);
      expect(dto.count, 0);
      expect(dto.unreadCount, 0);
    });

    test('should handle missing fields with defaults', () {
      final json = <String, dynamic>{};

      final dto = NotificationListResponseDto.fromJson(json);

      expect(dto.notifications, isEmpty);
      expect(dto.count, 0);
      expect(dto.unreadCount, 0);
    });
  });
}
