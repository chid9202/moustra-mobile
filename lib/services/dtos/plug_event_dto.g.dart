// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plug_event_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlugEventDto _$PlugEventDtoFromJson(Map<String, dynamic> json) => PlugEventDto(
  eid: (json['eid'] as num?)?.toInt(),
  plugEventId: (json['plugEventId'] as num?)?.toInt(),
  plugEventUuid: json['plugEventUuid'] as String,
  female: json['female'] == null
      ? null
      : AnimalSummaryDto.fromJson(json['female'] as Map<String, dynamic>),
  male: json['male'] == null
      ? null
      : AnimalSummaryDto.fromJson(json['male'] as Map<String, dynamic>),
  mating: json['mating'] == null
      ? null
      : MatingSummaryDto.fromJson(json['mating'] as Map<String, dynamic>),
  plugDate: json['plugDate'] as String,
  plugTime: json['plugTime'] as String?,
  checkedBy: json['checkedBy'] == null
      ? null
      : AccountDto.fromJson(json['checkedBy'] as Map<String, dynamic>),
  currentEday: _safeDouble(json['currentEday']),
  targetEday: _safeDouble(json['targetEday']),
  targetDate: json['targetDate'] as String?,
  expectedDeliveryStart: json['expectedDeliveryStart'] as String?,
  expectedDeliveryEnd: json['expectedDeliveryEnd'] as String?,
  outcome: json['outcome'] as String?,
  outcomeDate: json['outcomeDate'] as String?,
  outcomeEday: _safeDouble(json['outcomeEday']),
  embryosCollected: _safeInt(json['embryosCollected']),
  comment: json['comment'] as String?,
  owner: json['owner'] == null
      ? null
      : AccountDto.fromJson(json['owner'] as Map<String, dynamic>),
  createdDate: json['createdDate'] as String?,
  updatedDate: json['updatedDate'] as String?,
);

Map<String, dynamic> _$PlugEventDtoToJson(PlugEventDto instance) =>
    <String, dynamic>{
      'eid': instance.eid,
      'plugEventId': instance.plugEventId,
      'plugEventUuid': instance.plugEventUuid,
      'female': instance.female?.toJson(),
      'male': instance.male?.toJson(),
      'mating': instance.mating?.toJson(),
      'plugDate': instance.plugDate,
      'plugTime': instance.plugTime,
      'checkedBy': instance.checkedBy?.toJson(),
      'currentEday': instance.currentEday,
      'targetEday': instance.targetEday,
      'targetDate': instance.targetDate,
      'expectedDeliveryStart': instance.expectedDeliveryStart,
      'expectedDeliveryEnd': instance.expectedDeliveryEnd,
      'outcome': instance.outcome,
      'outcomeDate': instance.outcomeDate,
      'outcomeEday': instance.outcomeEday,
      'embryosCollected': instance.embryosCollected,
      'comment': instance.comment,
      'owner': instance.owner?.toJson(),
      'createdDate': instance.createdDate,
      'updatedDate': instance.updatedDate,
    };
