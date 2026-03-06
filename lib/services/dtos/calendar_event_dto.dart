import 'package:json_annotation/json_annotation.dart';

part 'calendar_event_dto.g.dart';

@JsonSerializable()
class CalendarEventDto {
  final String date;
  final String title;
  final String eventType;
  final String entityType;
  final String entityUuid;
  final Map<String, dynamic>? metadata;

  CalendarEventDto({
    required this.date,
    required this.title,
    required this.eventType,
    required this.entityType,
    required this.entityUuid,
    this.metadata,
  });

  factory CalendarEventDto.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CalendarEventDtoToJson(this);
}
