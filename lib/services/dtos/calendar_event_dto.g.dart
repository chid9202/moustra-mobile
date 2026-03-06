// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_event_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalendarEventDto _$CalendarEventDtoFromJson(Map<String, dynamic> json) =>
    CalendarEventDto(
      date: json['date'] as String,
      title: json['title'] as String,
      eventType: json['eventType'] as String,
      entityType: json['entityType'] as String,
      entityUuid: json['entityUuid'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CalendarEventDtoToJson(CalendarEventDto instance) =>
    <String, dynamic>{
      'date': instance.date,
      'title': instance.title,
      'eventType': instance.eventType,
      'entityType': instance.entityType,
      'entityUuid': instance.entityUuid,
      'metadata': instance.metadata,
    };
