// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animal_store_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnimalStoreDto _$AnimalStoreDtoFromJson(Map<String, dynamic> json) =>
    AnimalStoreDto(
      eid: (json['eid'] as num).toInt(),
      animalId: (json['animalId'] as num).toInt(),
      animalUuid: json['animalUuid'] as String,
      physicalTag: json['physicalTag'] as String?,
      isEnded: json['isEnded'] as bool?,
      sex: json['sex'] as String?,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
    );

Map<String, dynamic> _$AnimalStoreDtoToJson(AnimalStoreDto instance) =>
    <String, dynamic>{
      'eid': instance.eid,
      'animalId': instance.animalId,
      'animalUuid': instance.animalUuid,
      'physicalTag': instance.physicalTag,
      'isEnded': instance.isEnded,
      'sex': instance.sex,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
    };
