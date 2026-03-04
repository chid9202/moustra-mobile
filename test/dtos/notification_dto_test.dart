import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/notification_dto.dart';

void main() {
  group('NotificationDto Tests', () {
    test('should create from JSON with all fields', () {
      final json = {
        'notificationUuid': 'uuid-1',
        'notificationType': 'item_update',
        'title': 'Animal Updated',
        'message': 'Animal A001 was updated',
        'link': '/animal/uuid-1',
        'metadata': {
          'changes': [
            {'field': 'status', 'label': 'Status', 'old': 'Active', 'new': 'Inactive'},
          ],
        },
        'isRead': false,
        'createdAt': '2026-03-04T10:00:00.000Z',
      };

      final dto = NotificationDto.fromJson(json);

      expect(dto.notificationUuid, 'uuid-1');
      expect(dto.notificationType, 'item_update');
      expect(dto.title, 'Animal Updated');
      expect(dto.message, 'Animal A001 was updated');
      expect(dto.link, '/animal/uuid-1');
      expect(dto.isRead, false);
      expect(dto.createdAt, isA<DateTime>());
      expect(dto.metadata, isNotNull);
    });

    test('should create from JSON with minimal fields', () {
      final json = {
        'notificationUuid': 'uuid-2',
        'notificationType': 'system',
        'title': 'System Notice',
        'message': 'Maintenance scheduled',
        'isRead': true,
        'createdAt': '2026-03-04T10:00:00.000Z',
      };

      final dto = NotificationDto.fromJson(json);

      expect(dto.notificationUuid, 'uuid-2');
      expect(dto.link, isNull);
      expect(dto.metadata, isNull);
      expect(dto.isRead, true);
    });

    test('should convert to JSON', () {
      final dto = NotificationDto(
        notificationUuid: 'uuid-1',
        notificationType: 'system',
        title: 'Test',
        message: 'Test message',
        isRead: false,
        createdAt: DateTime.utc(2026, 3, 4, 10),
      );

      final json = dto.toJson();

      expect(json['notificationUuid'], 'uuid-1');
      expect(json['notificationType'], 'system');
      expect(json['title'], 'Test');
      expect(json['message'], 'Test message');
      expect(json['isRead'], false);
    });

    test('should handle null metadata', () {
      final dto = NotificationDto(
        notificationUuid: 'uuid-1',
        notificationType: 'system',
        title: 'Test',
        message: 'Test message',
        isRead: false,
        createdAt: DateTime.utc(2026, 3, 4),
      );

      expect(dto.metadata, isNull);
      expect(dto.changes, isEmpty);
    });

    test('changes getter parses metadata changes', () {
      final dto = NotificationDto(
        notificationUuid: 'uuid-1',
        notificationType: 'item_update',
        title: 'Updated',
        message: 'Something changed',
        metadata: {
          'changes': [
            {'field': 'status', 'label': 'Status', 'old': 'A', 'new': 'B'},
            {'field': 'name', 'label': 'Name', 'old': 'X', 'new': 'Y'},
          ],
        },
        isRead: false,
        createdAt: DateTime.utc(2026, 3, 4),
      );

      final changes = dto.changes;
      expect(changes.length, 2);
      expect(changes[0].field, 'status');
      expect(changes[0].oldValue, 'A');
      expect(changes[1].field, 'name');
      expect(changes[1].newValue, 'Y');
    });

    test('changes getter returns empty when no metadata changes key', () {
      final dto = NotificationDto(
        notificationUuid: 'uuid-1',
        notificationType: 'system',
        title: 'Test',
        message: 'Test',
        metadata: {'someKey': 'someValue'},
        isRead: true,
        createdAt: DateTime.utc(2026, 3, 4),
      );

      expect(dto.changes, isEmpty);
    });

    test('changes getter returns empty when changes is not a list', () {
      final dto = NotificationDto(
        notificationUuid: 'uuid-1',
        notificationType: 'system',
        title: 'Test',
        message: 'Test',
        metadata: {'changes': 'not-a-list'},
        isRead: true,
        createdAt: DateTime.utc(2026, 3, 4),
      );

      expect(dto.changes, isEmpty);
    });
  });
}
