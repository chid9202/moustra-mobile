// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'litter_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LitterDto _$LitterDtoFromJson(Map<String, dynamic> json) => LitterDto(
  eid: (json['eid'] as num?)?.toInt(),
  litterUuid: json['litterUuid'] as String,
  litterTag: json['litterTag'] as String?,
  weanDate: json['weanDate'] == null
      ? null
      : DateTime.parse(json['weanDate'] as String),
  mating: json['mating'] == null
      ? null
      : MatingSummaryDto.fromJson(json['mating'] as Map<String, dynamic>),
  owner: json['owner'] == null
      ? null
      : AccountDto.fromJson(json['owner'] as Map<String, dynamic>),
  animals:
      (json['animals'] as List<dynamic>?)
          ?.map((e) => LitterAnimalDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  createdDate: json['createdDate'] == null
      ? null
      : DateTime.parse(json['createdDate'] as String),
  comment: json['comment'] as String?,
  dateOfBirth: json['dateOfBirth'] == null
      ? null
      : DateTime.parse(json['dateOfBirth'] as String),
);

Map<String, dynamic> _$LitterDtoToJson(LitterDto instance) => <String, dynamic>{
  'eid': instance.eid,
  'litterUuid': instance.litterUuid,
  'litterTag': instance.litterTag,
  'weanDate': instance.weanDate?.toIso8601String(),
  'mating': instance.mating?.toJson(),
  'owner': instance.owner?.toJson(),
  'animals': instance.animals.map((e) => e.toJson()).toList(),
  'createdDate': instance.createdDate?.toIso8601String(),
  'comment': instance.comment,
  'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
};

LitterAnimalDto _$LitterAnimalDtoFromJson(Map<String, dynamic> json) =>
    LitterAnimalDto(
      animalId: (json['animalId'] as num).toInt(),
      animalUuid: json['animalUuid'] as String,
      physicalTag: json['physicalTag'] as String?,
      sex: json['sex'] as String?,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
    );

Map<String, dynamic> _$LitterAnimalDtoToJson(LitterAnimalDto instance) =>
    <String, dynamic>{
      'animalId': instance.animalId,
      'animalUuid': instance.animalUuid,
      'physicalTag': instance.physicalTag,
      'sex': instance.sex,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
    };
