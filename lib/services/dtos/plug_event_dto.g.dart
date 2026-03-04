// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plug_event_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlugEventDto _$PlugEventDtoFromJson(Map<String, dynamic> json) => PlugEventDto(
  eid: (json['eid'] as num?)?.toInt(),
  plugEventId: (json['plugEventId'] as num).toInt(),
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
  plugDate: DateTime.parse(json['plugDate'] as String),
  plugTime: json['plugTime'] as String?,
  checkedBy: json['checkedBy'] == null
      ? null
      : AccountDto.fromJson(json['checkedBy'] as Map<String, dynamic>),
  currentEday: (json['currentEday'] as num?)?.toDouble(),
  targetEday: (json['targetEday'] as num?)?.toDouble(),
  targetDate: json['targetDate'] == null
      ? null
      : DateTime.parse(json['targetDate'] as String),
  expectedDeliveryStart: json['expectedDeliveryStart'] == null
      ? null
      : DateTime.parse(json['expectedDeliveryStart'] as String),
  expectedDeliveryEnd: json['expectedDeliveryEnd'] == null
      ? null
      : DateTime.parse(json['expectedDeliveryEnd'] as String),
  outcome: json['outcome'] as String?,
  outcomeDate: json['outcomeDate'] == null
      ? null
      : DateTime.parse(json['outcomeDate'] as String),
  outcomeEday: (json['outcomeEday'] as num?)?.toDouble(),
  embryosCollected: (json['embryosCollected'] as num?)?.toInt(),
  notes: json['notes'] as String?,
  owner: json['owner'] == null
      ? null
      : AccountDto.fromJson(json['owner'] as Map<String, dynamic>),
  createdDate: json['createdDate'] == null
      ? null
      : DateTime.parse(json['createdDate'] as String),
  updatedDate: json['updatedDate'] == null
      ? null
      : DateTime.parse(json['updatedDate'] as String),
);

Map<String, dynamic> _$PlugEventDtoToJson(
  PlugEventDto instance,
) => <String, dynamic>{
  'eid': instance.eid,
  'plugEventId': instance.plugEventId,
  'plugEventUuid': instance.plugEventUuid,
  'female': instance.female?.toJson(),
  'male': instance.male?.toJson(),
  'mating': instance.mating?.toJson(),
  'plugDate': instance.plugDate.toIso8601String(),
  'plugTime': instance.plugTime,
  'checkedBy': instance.checkedBy?.toJson(),
  'currentEday': instance.currentEday,
  'targetEday': instance.targetEday,
  'targetDate': instance.targetDate?.toIso8601String(),
  'expectedDeliveryStart': instance.expectedDeliveryStart?.toIso8601String(),
  'expectedDeliveryEnd': instance.expectedDeliveryEnd?.toIso8601String(),
  'outcome': instance.outcome,
  'outcomeDate': instance.outcomeDate?.toIso8601String(),
  'outcomeEday': instance.outcomeEday,
  'embryosCollected': instance.embryosCollected,
  'notes': instance.notes,
  'owner': instance.owner?.toJson(),
  'createdDate': instance.createdDate?.toIso8601String(),
  'updatedDate': instance.updatedDate?.toIso8601String(),
};
