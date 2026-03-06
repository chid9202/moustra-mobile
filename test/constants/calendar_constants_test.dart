import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/constants/calendar_constants.dart';

void main() {
  group('CalendarConstants', () {
    group('eventTypes', () {
      test('should have non-empty event types list', () {
        expect(CalendarConstants.eventTypes, isNotEmpty);
      });

      test('each event type should have value, label, color, and category', () {
        for (final type in CalendarConstants.eventTypes) {
          expect(type.value, isNotEmpty);
          expect(type.label, isNotEmpty);
          expect(type.color, isNotNull);
          expect(type.category, isNotEmpty);
        }
      });

      test('should include expected event type values', () {
        final values = CalendarConstants.eventTypes.map((e) => e.value).toSet();
        expect(values, contains('animal_wean'));
        expect(values, contains('plug_date'));
        expect(values, contains('task_due'));
        expect(values, contains('protocol_expiration'));
      });

      test('should have unique event type values', () {
        final values = CalendarConstants.eventTypes.map((e) => e.value).toList();
        expect(values.toSet().length, values.length);
      });
    });

    group('getEventColor', () {
      test('should return correct color for known event type', () {
        final color = CalendarConstants.getEventColor('animal_wean');
        expect(color, const Color(0xFF2196F3));
      });

      test('should return grey for unknown event type', () {
        final color = CalendarConstants.getEventColor('unknown_type');
        expect(color, Colors.grey);
      });

      test('should return grey for empty string', () {
        final color = CalendarConstants.getEventColor('');
        expect(color, Colors.grey);
      });
    });

    group('getEventLabel', () {
      test('should return correct label for known event type', () {
        final label = CalendarConstants.getEventLabel('animal_wean');
        expect(label, 'Animal Wean');
      });

      test('should return event type string for unknown type', () {
        final label = CalendarConstants.getEventLabel('unknown_type');
        expect(label, 'unknown_type');
      });
    });

    group('entityRoutes', () {
      test('should contain expected entity routes', () {
        expect(CalendarConstants.entityRoutes['animal'], '/animal');
        expect(CalendarConstants.entityRoutes['litter'], '/litter');
        expect(CalendarConstants.entityRoutes['mating'], '/mating');
        expect(CalendarConstants.entityRoutes['plug_event'], '/plug-event');
        expect(CalendarConstants.entityRoutes['protocol'], '/protocol');
        expect(CalendarConstants.entityRoutes['task'], '/task');
      });

      test('should have 6 entity routes', () {
        expect(CalendarConstants.entityRoutes.length, 6);
      });
    });
  });
}
