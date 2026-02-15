// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mating_history_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MatingHistoryDto _$MatingHistoryDtoFromJson(
  Map<String, dynamic> json,
) => MatingHistoryDto(
  matingUuid: json['matingUuid'] as String,
  matingTag: json['matingTag'] as String?,
  setUpDate: json['setUpDate'] == null
      ? null
      : DateTime.parse(json['setUpDate'] as String),
  disbandedDate: json['disbandedDate'] == null
      ? null
      : DateTime.parse(json['disbandedDate'] as String),
  litterStrain: json['litterStrain'] == null
      ? null
      : StrainSummaryDto.fromJson(json['litterStrain'] as Map<String, dynamic>),
  litters: (json['litters'] as List<dynamic>?)
      ?.map((e) => MatingHistoryLitterDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MatingHistoryDtoToJson(MatingHistoryDto instance) =>
    <String, dynamic>{
      'matingUuid': instance.matingUuid,
      'matingTag': instance.matingTag,
      'setUpDate': instance.setUpDate?.toIso8601String(),
      'disbandedDate': instance.disbandedDate?.toIso8601String(),
      'litterStrain': instance.litterStrain?.toJson(),
      'litters': instance.litters?.map((e) => e.toJson()).toList(),
    };

MatingHistoryLitterDto _$MatingHistoryLitterDtoFromJson(
  Map<String, dynamic> json,
) => MatingHistoryLitterDto(
  litterUuid: json['litterUuid'] as String,
  litterTag: json['litterTag'] as String?,
  dateOfBirth: json['dateOfBirth'] == null
      ? null
      : DateTime.parse(json['dateOfBirth'] as String),
  animals: (json['animals'] as List<dynamic>?)
      ?.map((e) => AnimalSummaryDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MatingHistoryLitterDtoToJson(
  MatingHistoryLitterDto instance,
) => <String, dynamic>{
  'litterUuid': instance.litterUuid,
  'litterTag': instance.litterTag,
  'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
  'animals': instance.animals?.map((e) => e.toJson()).toList(),
};
