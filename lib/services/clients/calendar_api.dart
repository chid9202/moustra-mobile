import 'dart:convert';

import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/services/dtos/calendar_events_response_dto.dart';

class CalendarApi {
  static const String _path = '/calendar';

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
    if (res.statusCode >= 400) {
      throw Exception('Failed to fetch calendar events: ${res.body}');
    }
    final Map<String, dynamic> data = jsonDecode(res.body);
    return CalendarEventsResponseDto.fromJson(data);
  }
}

final CalendarApi calendarService = CalendarApi();
