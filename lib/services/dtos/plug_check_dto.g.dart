// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plug_check_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlugCheckDto _$PlugCheckDtoFromJson(Map<String, dynamic> json) => PlugCheckDto(
  plugCheckId: (json['plugCheckId'] as num).toInt(),
  plugCheckUuid: json['plugCheckUuid'] as String,
  female: json['female'] == null
      ? null
      : AnimalSummaryDto.fromJson(json['female'] as Map<String, dynamic>),
  mating: json['mating'] == null
      ? null
      : MatingSummaryDto.fromJson(json['mating'] as Map<String, dynamic>),
  checkDate: DateTime.parse(json['checkDate'] as String),
  checkTime: json['checkTime'] as String?,
  result: json['result'] as String,
  checkedBy: json['checkedBy'] == null
      ? null
      : AccountDto.fromJson(json['checkedBy'] as Map<String, dynamic>),
  plugEventUuid: json['plugEventUuid'] as String?,
  notes: json['notes'] as String?,
  owner: json['owner'] == null
      ? null
      : AccountDto.fromJson(json['owner'] as Map<String, dynamic>),
  createdDate: json['createdDate'] == null
      ? null
      : DateTime.parse(json['createdDate'] as String),
);

Map<String, dynamic> _$PlugCheckDtoToJson(PlugCheckDto instance) =>
    <String, dynamic>{
      'plugCheckId': instance.plugCheckId,
      'plugCheckUuid': instance.plugCheckUuid,
      'female': instance.female?.toJson(),
      'mating': instance.mating?.toJson(),
      'checkDate': instance.checkDate.toIso8601String(),
      'checkTime': instance.checkTime,
      'result': instance.result,
      'checkedBy': instance.checkedBy?.toJson(),
      'plugEventUuid': instance.plugEventUuid,
      'notes': instance.notes,
      'owner': instance.owner?.toJson(),
      'createdDate': instance.createdDate?.toIso8601String(),
    };
