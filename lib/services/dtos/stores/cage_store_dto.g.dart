// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cage_store_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CageStoreDto _$CageStoreDtoFromJson(Map<String, dynamic> json) => CageStoreDto(
  cageId: (json['cageId'] as num).toInt(),
  cageUuid: json['cageUuid'] as String,
  cageTag: json['cageTag'] as String?,
  strain: json['strain'] == null
      ? null
      : CageStoreStrainDto.fromJson(json['strain']),
  animals:
      (json['animals'] as List<dynamic>?)
          ?.map(CageStoreAnimalDto.fromJson)
          .toList() ??
      const [],
);

Map<String, dynamic> _$CageStoreDtoToJson(CageStoreDto instance) =>
    <String, dynamic>{
      'cageId': instance.cageId,
      'cageUuid': instance.cageUuid,
      'cageTag': instance.cageTag,
      'strain': instance.strain?.toJson(),
      'animals': instance.animals.map((e) => e.toJson()).toList(),
    };

CageStoreStrainDto _$CageStoreStrainDtoFromJson(Map<String, dynamic> json) =>
    CageStoreStrainDto(
      strainId: (json['strainId'] as num).toInt(),
      strainUuid: json['strainUuid'] as String,
      strainName: json['strainName'] as String,
      color: json['color'] as String?,
    );

Map<String, dynamic> _$CageStoreStrainDtoToJson(CageStoreStrainDto instance) =>
    <String, dynamic>{
      'strainId': instance.strainId,
      'strainUuid': instance.strainUuid,
      'strainName': instance.strainName,
      'color': instance.color,
    };

CageStoreAnimalDto _$CageStoreAnimalDtoFromJson(Map<String, dynamic> json) =>
    CageStoreAnimalDto(
      eid: (json['eid'] as num).toInt(),
      animalId: (json['animalId'] as num).toInt(),
      animalUuid: json['animalUuid'] as String,
      physicalTag: json['physicalTag'] as String?,
      sex: json['sex'] as String?,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      weanDate: json['weanDate'] == null
          ? null
          : DateTime.parse(json['weanDate'] as String),
    );

Map<String, dynamic> _$CageStoreAnimalDtoToJson(CageStoreAnimalDto instance) =>
    <String, dynamic>{
      'eid': instance.eid,
      'animalId': instance.animalId,
      'animalUuid': instance.animalUuid,
      'physicalTag': instance.physicalTag,
      'sex': instance.sex,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'weanDate': instance.weanDate?.toIso8601String(),
    };
