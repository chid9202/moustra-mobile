// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_events_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalendarEventsResponseDto _$CalendarEventsResponseDtoFromJson(
  Map<String, dynamic> json,
) => CalendarEventsResponseDto(
  events: (json['events'] as List<dynamic>)
      .map((e) => CalendarEventDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
  offset: (json['offset'] as num).toInt(),
);

Map<String, dynamic> _$CalendarEventsResponseDtoToJson(
  CalendarEventsResponseDto instance,
) => <String, dynamic>{
  'events': instance.events.map((e) => e.toJson()).toList(),
  'total': instance.total,
  'limit': instance.limit,
  'offset': instance.offset,
};
