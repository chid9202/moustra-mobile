// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animal_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnimalSummaryDto _$AnimalSummaryDtoFromJson(Map<String, dynamic> json) =>
    AnimalSummaryDto(
      animalId: (json['animalId'] as num).toInt(),
      animalUuid: json['animalUuid'] as String,
      physicalTag: json['physicalTag'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
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
      'dateOfBirth': instance.dateOfBirth,
      'genotypes': instance.genotypes?.map((e) => e.toJson()).toList(),
      'owner': instance.owner,
      'strain': instance.strain?.toJson(),
      'weanDate': instance.weanDate,
      'sex': instance.sex,
      'comment': instance.comment,
      'createdDate': instance.createdDate.toIso8601String(),
      'updatedDate': instance.updatedDate.toIso8601String(),
    };
