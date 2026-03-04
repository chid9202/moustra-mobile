// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_plug_check_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostPlugCheckDto _$PostPlugCheckDtoFromJson(Map<String, dynamic> json) =>
    PostPlugCheckDto(
      female: json['female'] as String,
      mating: json['mating'] as String?,
      checkDate: DateTime.parse(json['checkDate'] as String),
      result: json['result'] as String,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$PostPlugCheckDtoToJson(PostPlugCheckDto instance) =>
    <String, dynamic>{
      'female': instance.female,
      'mating': instance.mating,
      'checkDate': instance.checkDate.toIso8601String(),
      'result': instance.result,
      'notes': instance.notes,
    };
