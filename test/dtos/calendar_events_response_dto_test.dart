import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/calendar_event_dto.dart';
import 'package:moustra/services/dtos/calendar_events_response_dto.dart';

void main() {
  group('CalendarEventsResponseDto', () {
    test('should create from JSON with events', () {
      final json = {
        'events': [
          {
            'date': '2026-03-04',
            'title': 'Wean due',
            'eventType': 'animal_wean',
            'entityType': 'animal',
            'entityUuid': 'uuid-1',
          },
        ],
        'total': 1,
        'limit': 1000,
        'offset': 0,
      };

      final dto = CalendarEventsResponseDto.fromJson(json);

      expect(dto.events.length, 1);
      expect(dto.events.first.date, '2026-03-04');
      expect(dto.events.first.title, 'Wean due');
      expect(dto.events.first.eventType, 'animal_wean');
      expect(dto.total, 1);
      expect(dto.limit, 1000);
      expect(dto.offset, 0);
    });

    test('should create from JSON with empty events', () {
      final json = {
        'events': [],
        'total': 0,
        'limit': 1000,
        'offset': 0,
      };

      final dto = CalendarEventsResponseDto.fromJson(json);

      expect(dto.events, isEmpty);
      expect(dto.total, 0);
      expect(dto.limit, 1000);
      expect(dto.offset, 0);
    });

    test('should convert to JSON', () {
      final dto = CalendarEventsResponseDto(
        events: [
          CalendarEventDto(
            date: '2026-03-05',
            title: 'Plug date',
            eventType: 'plug_date',
            entityType: 'plug_event',
            entityUuid: 'plug-uuid-1',
          ),
        ],
        total: 1,
        limit: 500,
        offset: 0,
      );

      final json = dto.toJson();

      expect(json['events'], isA<List>());
      expect((json['events'] as List).length, 1);
      expect((json['events'] as List).first['date'], '2026-03-05');
      expect(json['total'], 1);
      expect(json['limit'], 500);
      expect(json['offset'], 0);
    });
  });
}
