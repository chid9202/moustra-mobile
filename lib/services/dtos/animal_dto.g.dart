// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animal_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnimalDto _$AnimalDtoFromJson(Map<String, dynamic> json) => AnimalDto(
  eid: (json['eid'] as num).toInt(),
  animalId: (json['animalId'] as num).toInt(),
  animalUuid: json['animalUuid'] as String,
  physicalTag: json['physicalTag'] as String?,
  dateOfBirth: json['dateOfBirth'] == null
      ? null
      : DateTime.parse(json['dateOfBirth'] as String),
  sex: json['sex'] as String?,
  genotypes:
      (json['genotypes'] as List<dynamic>?)
          ?.map((e) => GenotypeDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  weanDate: json['weanDate'] == null
      ? null
      : DateTime.parse(json['weanDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  owner: json['owner'] == null
      ? null
      : AccountDto.fromJson(json['owner'] as Map<String, dynamic>),
  cage: json['cage'] == null
      ? null
      : CageSummaryDto.fromJson(json['cage'] as Map<String, dynamic>),
  strain: json['strain'] == null
      ? null
      : StrainSummaryDto.fromJson(json['strain'] as Map<String, dynamic>),
  comment: json['comment'] as String?,
  createdDate: DateTime.parse(json['createdDate'] as String),
  updatedDate: DateTime.parse(json['updatedDate'] as String),
  sire: json['sire'] == null
      ? null
      : AnimalSummaryDto.fromJson(json['sire'] as Map<String, dynamic>),
  dam:
      (json['dam'] as List<dynamic>?)
          ?.map((e) => AnimalSummaryDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$AnimalDtoToJson(AnimalDto instance) => <String, dynamic>{
  'eid': instance.eid,
  'animalId': instance.animalId,
  'animalUuid': instance.animalUuid,
  'physicalTag': instance.physicalTag,
  'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
  'sex': instance.sex,
  'genotypes': instance.genotypes?.map((e) => e.toJson()).toList(),
  'weanDate': instance.weanDate?.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'owner': instance.owner?.toJson(),
  'cage': instance.cage?.toJson(),
  'strain': instance.strain?.toJson(),
  'comment': instance.comment,
  'createdDate': instance.createdDate.toIso8601String(),
  'updatedDate': instance.updatedDate.toIso8601String(),
  'sire': instance.sire?.toJson(),
  'dam': instance.dam?.map((e) => e.toJson()).toList(),
};

AnimalSummaryDto _$AnimalSummaryDtoFromJson(Map<String, dynamic> json) =>
    AnimalSummaryDto(
      animalId: (json['animalId'] as num).toInt(),
      animalUuid: json['animalUuid'] as String,
      physicalTag: json['physicalTag'] as String?,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      genotypes:
          (json['genotypes'] as List<dynamic>?)
              ?.map((e) => GenotypeDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      owner: (json['owner'] as num?)?.toInt(),
      strain: json['strain'] == null
          ? null
          : StrainSummaryDto.fromJson(json['strain'] as Map<String, dynamic>),
      weanDate: json['weanDate'] as String?,
      sex: json['sex'] as String?,
      comment: json['comment'] as String?,
      createdDate: DateTime.parse(json['createdDate'] as String),
      updatedDate: DateTime.parse(json['updatedDate'] as String),
    );

Map<String, dynamic> _$AnimalSummaryDtoToJson(AnimalSummaryDto instance) =>
    <String, dynamic>{
      'animalId': instance.animalId,
      'animalUuid': instance.animalUuid,
      'physicalTag': instance.physicalTag,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'genotypes': instance.genotypes?.map((e) => e.toJson()).toList(),
      'owner': instance.owner,
      'strain': instance.strain?.toJson(),
      'weanDate': instance.weanDate,
      'sex': instance.sex,
      'comment': instance.comment,
      'createdDate': instance.createdDate.toIso8601String(),
      'updatedDate': instance.updatedDate.toIso8601String(),
    };
