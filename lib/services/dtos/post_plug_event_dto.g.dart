// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_plug_event_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostPlugEventDto _$PostPlugEventDtoFromJson(Map<String, dynamic> json) =>
    PostPlugEventDto(
      female: json['female'] as String,
      male: json['male'] as String?,
      mating: json['mating'] as String?,
      plugDate: json['plugDate'] as String,
      targetEday: (json['targetEday'] as num?)?.toInt(),
      comment: json['comment'] as String?,
    );

Map<String, dynamic> _$PostPlugEventDtoToJson(PostPlugEventDto instance) =>
    <String, dynamic>{
      'female': instance.female,
      'male': instance.male,
      'mating': instance.mating,
      'plugDate': instance.plugDate,
      'targetEday': instance.targetEday,
      'comment': instance.comment,
    };
