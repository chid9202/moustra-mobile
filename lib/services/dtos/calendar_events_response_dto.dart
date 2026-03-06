import 'package:json_annotation/json_annotation.dart';
import 'package:moustra/services/dtos/calendar_event_dto.dart';

part 'calendar_events_response_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class CalendarEventsResponseDto {
  final List<CalendarEventDto> events;
  final int total;
  final int limit;
  final int offset;

  CalendarEventsResponseDto({
    required this.events,
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory CalendarEventsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventsResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CalendarEventsResponseDtoToJson(this);
}
