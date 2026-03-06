import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/calendar_event_dto.dart';
import 'package:moustra/services/dtos/calendar_events_response_dto.dart';

void main() {
  group('CalendarEventDto Tests', () {
    test('should create CalendarEventDto from JSON with all fields', () {
      final json = {
        'date': '2026-03-04',
        'title': 'Animal F001 wean due',
        'eventType': 'animal_wean',
        'entityType': 'animal',
        'entityUuid': 'animal-uuid-1',
        'metadata': {'physicalTag': 'F001'},
      };

      final dto = CalendarEventDto.fromJson(json);

      expect(dto.date, '2026-03-04');
      expect(dto.title, 'Animal F001 wean due');
      expect(dto.eventType, 'animal_wean');
      expect(dto.entityType, 'animal');
      expect(dto.entityUuid, 'animal-uuid-1');
      expect(dto.metadata, isNotNull);
      expect(dto.metadata!['physicalTag'], 'F001');
    });

    test('should create CalendarEventDto from JSON with minimal fields', () {
      final json = {
        'date': '2026-03-04',
        'title': 'Test event',
        'eventType': 'task_due',
        'entityType': 'task',
        'entityUuid': 'task-uuid-1',
      };

      final dto = CalendarEventDto.fromJson(json);

      expect(dto.date, '2026-03-04');
      expect(dto.title, 'Test event');
      expect(dto.eventType, 'task_due');
      expect(dto.entityType, 'task');
      expect(dto.entityUuid, 'task-uuid-1');
      expect(dto.metadata, isNull);
    });

    test('should convert CalendarEventDto to JSON', () {
      final dto = CalendarEventDto(
        date: '2026-03-04',
        title: 'Mating setup',
        eventType: 'mating_setup',
        entityType: 'mating',
        entityUuid: 'mating-uuid-1',
        metadata: {'tag': 'MT001'},
      );

      final json = dto.toJson();

      expect(json['date'], '2026-03-04');
      expect(json['title'], 'Mating setup');
      expect(json['eventType'], 'mating_setup');
      expect(json['entityType'], 'mating');
      expect(json['entityUuid'], 'mating-uuid-1');
      expect(json['metadata'], {'tag': 'MT001'});
    });

    test('should handle null metadata', () {
      final json = {
        'date': '2026-03-04',
        'title': 'Protocol expiration',
        'eventType': 'protocol_expiration',
        'entityType': 'protocol',
        'entityUuid': 'protocol-uuid-1',
        'metadata': null,
      };

      final dto = CalendarEventDto.fromJson(json);

      expect(dto.metadata, isNull);

      final output = dto.toJson();
      expect(output['metadata'], isNull);
    });
  });

  group('CalendarEventsResponseDto Tests', () {
    test('should create CalendarEventsResponseDto from JSON with events', () {
      final json = {
        'events': [
          {
            'date': '2026-03-04',
            'title': 'Animal birth',
            'eventType': 'animal_birth',
            'entityType': 'animal',
            'entityUuid': 'animal-uuid-1',
          },
          {
            'date': '2026-03-05',
            'title': 'Plug date',
            'eventType': 'plug_date',
            'entityType': 'plug_event',
            'entityUuid': 'plug-uuid-1',
            'metadata': {'eday': 14},
          },
        ],
        'total': 2,
        'limit': 1000,
        'offset': 0,
      };

      final dto = CalendarEventsResponseDto.fromJson(json);

      expect(dto.events.length, 2);
      expect(dto.total, 2);
      expect(dto.limit, 1000);
      expect(dto.offset, 0);
      expect(dto.events[0].title, 'Animal birth');
      expect(dto.events[1].eventType, 'plug_date');
    });

    test('should handle empty events array', () {
      final json = {
        'events': [],
        'total': 0,
        'limit': 1000,
        'offset': 0,
      };

      final dto = CalendarEventsResponseDto.fromJson(json);

      expect(dto.events, isEmpty);
      expect(dto.total, 0);
    });

    test('should convert CalendarEventsResponseDto to JSON', () {
      final dto = CalendarEventsResponseDto(
        events: [
          CalendarEventDto(
            date: '2026-03-04',
            title: 'Test',
            eventType: 'task_due',
            entityType: 'task',
            entityUuid: 'task-uuid-1',
          ),
        ],
        total: 1,
        limit: 1000,
        offset: 0,
      );

      final json = dto.toJson();

      expect(json['events'], isList);
      expect((json['events'] as List).length, 1);
      expect(json['total'], 1);
      expect(json['limit'], 1000);
      expect(json['offset'], 0);
    });
  });
}
