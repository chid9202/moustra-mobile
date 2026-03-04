// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_plug_event_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PutPlugEventDto _$PutPlugEventDtoFromJson(Map<String, dynamic> json) =>
    PutPlugEventDto(
      plugDate: json['plugDate'] as String?,
      targetEday: (json['targetEday'] as num?)?.toInt(),
      comment: json['comment'] as String?,
      male: json['male'] as String?,
    );

Map<String, dynamic> _$PutPlugEventDtoToJson(PutPlugEventDto instance) =>
    <String, dynamic>{
      'plugDate': instance.plugDate,
      'targetEday': instance.targetEday,
      'comment': instance.comment,
      'male': instance.male,
    };
