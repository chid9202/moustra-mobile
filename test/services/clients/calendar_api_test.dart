import 'package:dio/dio.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/calendar_events_response_dto.dart';

import 'calendar_api_test.mocks.dart';

class TestableCalendarApi {
  final DioApiClient apiClient;
  static const String _path = '/calendar';

  TestableCalendarApi(this.apiClient);

  Future<CalendarEventsResponseDto> getCalendarEvents({
    required String startDate,
    required String endDate,
    List<String>? eventTypes,
    int limit = 1000,
    int offset = 0,
  }) async {
    final query = <String, String>{
      'start_date': startDate,
      'end_date': endDate,
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    if (eventTypes != null && eventTypes.isNotEmpty) {
      query['event_type'] = eventTypes.join(',');
    }

    final res = await apiClient.get(_path, query: query);
    if (res.statusCode != null && res.statusCode! >= 400) {
      throw Exception('Failed to fetch calendar events: ${res.data}');
    }
    final Map<String, dynamic> data = res.data;
    return CalendarEventsResponseDto.fromJson(data);
  }
}

@GenerateMocks([DioApiClient])
void main() {
  group('CalendarApi Tests', () {
    late MockDioApiClient mockApiClient;
    late TestableCalendarApi calendarApi;

    final sampleEventsResponse = {
      'events': [
        {
          'date': '2026-03-04',
          'title': 'Animal F001 wean due',
          'eventType': 'animal_wean',
          'entityType': 'animal',
          'entityUuid': 'animal-uuid-1',
        },
        {
          'date': '2026-03-05',
          'title': 'Plug date for MT001',
          'eventType': 'plug_date',
          'entityType': 'plug_event',
          'entityUuid': 'plug-uuid-1',
        },
      ],
      'total': 2,
      'limit': 1000,
      'offset': 0,
    };

    final emptyEventsResponse = {
      'events': [],
      'total': 0,
      'limit': 1000,
      'offset': 0,
    };

    setUp(() {
      mockApiClient = MockDioApiClient();
      calendarApi = TestableCalendarApi(mockApiClient);
    });

    group('getCalendarEvents', () {
      test('should return calendar events for date range', () async {
        final mockResponse = Response(
          data: sampleEventsResponse,
          statusCode: 200,
          requestOptions: RequestOptions(),
        );

        when(
          mockApiClient.get(any, query: anyNamed('query')),
        ).thenAnswer((_) async => mockResponse);

        final result = await calendarApi.getCalendarEvents(
          startDate: '2026-03-01',
          endDate: '2026-03-31',
        );

        expect(result.events.length, 2);
        expect(result.total, 2);
        expect(result.events[0].title, 'Animal F001 wean due');
        expect(result.events[1].eventType, 'plug_date');
        verify(
          mockApiClient.get(
            '/calendar',
            query: argThat(
              allOf([
                containsPair('start_date', '2026-03-01'),
                containsPair('end_date', '2026-03-31'),
                containsPair('limit', '1000'),
                containsPair('offset', '0'),
              ]),
              named: 'query',
            ),
          ),
        ).called(1);
      });

      test('should include event type filter in query params', () async {
        final mockResponse = Response(
          data: sampleEventsResponse,
          statusCode: 200,
          requestOptions: RequestOptions(),
        );

        when(
          mockApiClient.get(any, query: anyNamed('query')),
        ).thenAnswer((_) async => mockResponse);

        await calendarApi.getCalendarEvents(
          startDate: '2026-03-01',
          endDate: '2026-03-31',
          eventTypes: ['animal_wean', 'plug_date'],
        );

        verify(
          mockApiClient.get(
            '/calendar',
            query: argThat(
              allOf([
                containsPair('start_date', '2026-03-01'),
                containsPair('end_date', '2026-03-31'),
                containsPair('event_type', 'animal_wean,plug_date'),
              ]),
              named: 'query',
            ),
          ),
        ).called(1);
      });

      test('should handle empty response', () async {
        final mockResponse = Response(
          data: emptyEventsResponse,
          statusCode: 200,
          requestOptions: RequestOptions(),
        );

        when(
          mockApiClient.get(any, query: anyNamed('query')),
        ).thenAnswer((_) async => mockResponse);

        final result = await calendarApi.getCalendarEvents(
          startDate: '2026-03-01',
          endDate: '2026-03-31',
        );

        expect(result.events, isEmpty);
        expect(result.total, 0);
      });

      test('should throw exception on 400 status', () async {
        final mockResponse = Response(data: 'Bad Request', statusCode: 400, requestOptions: RequestOptions());

        when(
          mockApiClient.get(any, query: anyNamed('query')),
        ).thenAnswer((_) async => mockResponse);

        expect(
          () => calendarApi.getCalendarEvents(
            startDate: '2026-03-01',
            endDate: '2026-03-31',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception on 500 status', () async {
        final mockResponse = Response(data: 'Internal Server Error', statusCode: 500, requestOptions: RequestOptions());

        when(
          mockApiClient.get(any, query: anyNamed('query')),
        ).thenAnswer((_) async => mockResponse);

        expect(
          () => calendarApi.getCalendarEvents(
            startDate: '2026-03-01',
            endDate: '2026-03-31',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('should not include event_type when list is empty', () async {
        final mockResponse = Response(
          data: emptyEventsResponse,
          statusCode: 200,
          requestOptions: RequestOptions(),
        );

        when(
          mockApiClient.get(any, query: anyNamed('query')),
        ).thenAnswer((_) async => mockResponse);

        await calendarApi.getCalendarEvents(
          startDate: '2026-03-01',
          endDate: '2026-03-31',
          eventTypes: [],
        );

        verify(
          mockApiClient.get(
            '/calendar',
            query: argThat(
              isNot(contains('event_type')),
              named: 'query',
            ),
          ),
        ).called(1);
      });
    });
  });
}
