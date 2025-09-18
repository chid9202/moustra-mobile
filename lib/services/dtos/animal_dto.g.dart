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
  createdDate: json['createdDate'] == null
      ? null
      : DateTime.parse(json['createdDate'] as String),
  updatedDate: json['updatedDate'] == null
      ? null
      : DateTime.parse(json['updatedDate'] as String),
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
  'createdDate': instance.createdDate?.toIso8601String(),
  'updatedDate': instance.updatedDate?.toIso8601String(),
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
      owner: json['owner'] == null
          ? null
          : AccountDto.fromJson(json['owner'] as Map<String, dynamic>),
      strain: json['strain'] == null
          ? null
          : StrainSummaryDto.fromJson(json['strain'] as Map<String, dynamic>),
      weanDate: json['weanDate'] as String?,
      sex: json['sex'] as String?,
      comment: json['comment'] as String?,
      createdDate: json['createdDate'] == null
          ? null
          : DateTime.parse(json['createdDate'] as String),
      updatedDate: json['updatedDate'] == null
          ? null
          : DateTime.parse(json['updatedDate'] as String),
    );

Map<String, dynamic> _$AnimalSummaryDtoToJson(AnimalSummaryDto instance) =>
    <String, dynamic>{
      'animalId': instance.animalId,
      'animalUuid': instance.animalUuid,
      'physicalTag': instance.physicalTag,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'genotypes': instance.genotypes?.map((e) => e.toJson()).toList(),
      'owner': instance.owner?.toJson(),
      'strain': instance.strain?.toJson(),
      'weanDate': instance.weanDate,
      'sex': instance.sex,
      'comment': instance.comment,
      'createdDate': instance.createdDate?.toIso8601String(),
      'updatedDate': instance.updatedDate?.toIso8601String(),
    };

PostAnimalDto _$PostAnimalDtoFromJson(Map<String, dynamic> json) =>
    PostAnimalDto(
      animals: (json['animals'] as List<dynamic>)
          .map((e) => PostAnimalData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PostAnimalDtoToJson(PostAnimalDto instance) =>
    <String, dynamic>{
      'animals': instance.animals.map((e) => e.toJson()).toList(),
    };

PostAnimalData _$PostAnimalDataFromJson(Map<String, dynamic> json) =>
    PostAnimalData(
      idx: json['idx'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      genotypes: (json['genotypes'] as List<dynamic>)
          .map((e) => PostGenotype.fromJson(e as Map<String, dynamic>))
          .toList(),
      physicalTag: json['physicalTag'] as String,
      sex: json['sex'] as String?,
      strain: json['strain'] == null
          ? null
          : StrainStoreDto.fromJson(json['strain']),
      sire: json['sire'] == null ? null : AnimalStoreDto.fromJson(json['sire']),
      dam: (json['dam'] as List<dynamic>?)
          ?.map(AnimalStoreDto.fromJson)
          .toList(),
      cage: json['cage'] == null ? null : CageStoreDto.fromJson(json['cage']),
      weanDate: json['weanDate'] == null
          ? null
          : DateTime.parse(json['weanDate'] as String),
      comment: json['comment'] as String?,
    );

Map<String, dynamic> _$PostAnimalDataToJson(PostAnimalData instance) =>
    <String, dynamic>{
      'idx': instance.idx,
      'dateOfBirth': instance.dateOfBirth.toIso8601String(),
      'genotypes': instance.genotypes.map((e) => e.toJson()).toList(),
      'physicalTag': instance.physicalTag,
      'sex': instance.sex,
      'strain': instance.strain?.toJson(),
      'sire': instance.sire?.toJson(),
      'dam': instance.dam?.map((e) => e.toJson()).toList(),
      'cage': instance.cage?.toJson(),
      'weanDate': instance.weanDate?.toIso8601String(),
      'comment': instance.comment,
    };

PostGenotype _$PostGenotypeFromJson(Map<String, dynamic> json) => PostGenotype(
  gene: json['gene'] as String,
  allele: json['allele'] as String,
);

Map<String, dynamic> _$PostGenotypeToJson(PostGenotype instance) =>
    <String, dynamic>{'gene': instance.gene, 'allele': instance.allele};

PostStrainData _$PostStrainDataFromJson(Map<String, dynamic> json) =>
    PostStrainData(
      strainId: (json['strainId'] as num).toInt(),
      strainUuid: json['strainUuid'] as String,
      strainName: json['strainName'] as String,
      weanAge: (json['weanAge'] as num).toInt(),
      genotypes: json['genotypes'] as List<dynamic>,
    );

Map<String, dynamic> _$PostStrainDataToJson(PostStrainData instance) =>
    <String, dynamic>{
      'strainId': instance.strainId,
      'strainUuid': instance.strainUuid,
      'strainName': instance.strainName,
      'weanAge': instance.weanAge,
      'genotypes': instance.genotypes,
    };

PostAnimalSummary _$PostAnimalSummaryFromJson(Map<String, dynamic> json) =>
    PostAnimalSummary(
      animalId: (json['animalId'] as num).toInt(),
      animalUuid: json['animalUuid'] as String,
      physicalTag: json['physicalTag'] as String,
      sex: json['sex'] as String,
      dateOfBirth: json['dateOfBirth'] as String,
      isEnded: json['isEnded'] as bool,
      eid: (json['eid'] as num).toInt(),
    );

Map<String, dynamic> _$PostAnimalSummaryToJson(PostAnimalSummary instance) =>
    <String, dynamic>{
      'animalId': instance.animalId,
      'animalUuid': instance.animalUuid,
      'physicalTag': instance.physicalTag,
      'sex': instance.sex,
      'dateOfBirth': instance.dateOfBirth,
      'isEnded': instance.isEnded,
      'eid': instance.eid,
    };

PostCageData _$PostCageDataFromJson(Map<String, dynamic> json) => PostCageData(
  cageId: (json['cageId'] as num).toInt(),
  cageUuid: json['cageUuid'] as String,
  cageTag: json['cageTag'] as String,
  animals: (json['animals'] as List<dynamic>)
      .map((e) => PostCageAnimal.fromJson(e as Map<String, dynamic>))
      .toList(),
  strain: PostStrainData.fromJson(json['strain'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PostCageDataToJson(PostCageData instance) =>
    <String, dynamic>{
      'cageId': instance.cageId,
      'cageUuid': instance.cageUuid,
      'cageTag': instance.cageTag,
      'animals': instance.animals.map((e) => e.toJson()).toList(),
      'strain': instance.strain.toJson(),
    };

PostCageAnimal _$PostCageAnimalFromJson(Map<String, dynamic> json) =>
    PostCageAnimal(
      animalId: (json['animalId'] as num).toInt(),
      animalUuid: json['animalUuid'] as String,
      physicalTag: json['physicalTag'] as String,
      weanDate: json['weanDate'] as String?,
      sex: json['sex'] as String,
      dateOfBirth: json['dateOfBirth'] as String,
      comment: json['comment'] as String?,
      createdDate: DateTime.parse(json['createdDate'] as String),
      updatedDate: DateTime.parse(json['updatedDate'] as String),
      eid: (json['eid'] as num).toInt(),
    );

Map<String, dynamic> _$PostCageAnimalToJson(PostCageAnimal instance) =>
    <String, dynamic>{
      'animalId': instance.animalId,
      'animalUuid': instance.animalUuid,
      'physicalTag': instance.physicalTag,
      'weanDate': instance.weanDate,
      'sex': instance.sex,
      'dateOfBirth': instance.dateOfBirth,
      'comment': instance.comment,
      'createdDate': instance.createdDate.toIso8601String(),
      'updatedDate': instance.updatedDate.toIso8601String(),
      'eid': instance.eid,
    };
