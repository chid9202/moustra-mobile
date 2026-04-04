// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_tree_v2_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FamilyTreeAnimalDto _$FamilyTreeAnimalDtoFromJson(Map<String, dynamic> json) =>
    FamilyTreeAnimalDto(
      animalId: (json['animalId'] as num?)?.toInt(),
      animalUuid: json['animalUuid'] as String?,
      sex: json['sex'] as String?,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      physicalTag: json['physicalTag'] as String?,
      strain: json['strain'] == null
          ? null
          : StrainSummaryDto.fromJson(json['strain'] as Map<String, dynamic>),
      genotypes:
          (json['genotypes'] as List<dynamic>?)
              ?.map(
                (e) =>
                    FamilyTreeGenotypeDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$FamilyTreeAnimalDtoToJson(
  FamilyTreeAnimalDto instance,
) => <String, dynamic>{
  'animalId': instance.animalId,
  'animalUuid': instance.animalUuid,
  'sex': instance.sex,
  'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
  'physicalTag': instance.physicalTag,
  'strain': instance.strain?.toJson(),
  'genotypes': instance.genotypes.map((e) => e.toJson()).toList(),
};

FamilyTreeGenotypeDto _$FamilyTreeGenotypeDtoFromJson(
  Map<String, dynamic> json,
) => FamilyTreeGenotypeDto(
  gene: json['gene'] == null
      ? null
      : FamilyTreeGeneDto.fromJson(json['gene'] as Map<String, dynamic>),
  allele: json['allele'] == null
      ? null
      : FamilyTreeAlleleDto.fromJson(json['allele'] as Map<String, dynamic>),
);

Map<String, dynamic> _$FamilyTreeGenotypeDtoToJson(
  FamilyTreeGenotypeDto instance,
) => <String, dynamic>{
  'gene': instance.gene?.toJson(),
  'allele': instance.allele?.toJson(),
};

FamilyTreeGeneDto _$FamilyTreeGeneDtoFromJson(Map<String, dynamic> json) =>
    FamilyTreeGeneDto(
      geneId: (json['geneId'] as num?)?.toInt(),
      geneUuid: json['geneUuid'] as String?,
      geneName: json['geneName'] as String?,
    );

Map<String, dynamic> _$FamilyTreeGeneDtoToJson(FamilyTreeGeneDto instance) =>
    <String, dynamic>{
      'geneId': instance.geneId,
      'geneUuid': instance.geneUuid,
      'geneName': instance.geneName,
    };

FamilyTreeAlleleDto _$FamilyTreeAlleleDtoFromJson(Map<String, dynamic> json) =>
    FamilyTreeAlleleDto(
      alleleId: (json['alleleId'] as num?)?.toInt(),
      alleleUuid: json['alleleUuid'] as String?,
      alleleName: json['alleleName'] as String?,
    );

Map<String, dynamic> _$FamilyTreeAlleleDtoToJson(
  FamilyTreeAlleleDto instance,
) => <String, dynamic>{
  'alleleId': instance.alleleId,
  'alleleUuid': instance.alleleUuid,
  'alleleName': instance.alleleName,
};

FamilyTreeMatingDto _$FamilyTreeMatingDtoFromJson(
  Map<String, dynamic> json,
) => FamilyTreeMatingDto(
  matingUuid: json['matingUuid'] as String?,
  matingTag: json['matingTag'] as String?,
  litterStrain: json['litterStrain'] == null
      ? null
      : StrainSummaryDto.fromJson(json['litterStrain'] as Map<String, dynamic>),
  animals:
      (json['animals'] as List<dynamic>?)
          ?.map((e) => FamilyTreeAnimalDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$FamilyTreeMatingDtoToJson(
  FamilyTreeMatingDto instance,
) => <String, dynamic>{
  'matingUuid': instance.matingUuid,
  'matingTag': instance.matingTag,
  'litterStrain': instance.litterStrain?.toJson(),
  'animals': instance.animals.map((e) => e.toJson()).toList(),
};

FamilyTreeLitterDto _$FamilyTreeLitterDtoFromJson(
  Map<String, dynamic> json,
) => FamilyTreeLitterDto(
  litterUuid: json['litterUuid'] as String?,
  litterTag: json['litterTag'] as String?,
  weanDate: json['weanDate'] == null
      ? null
      : DateTime.parse(json['weanDate'] as String),
  mating: json['mating'] == null
      ? null
      : FamilyTreeMatingDto.fromJson(json['mating'] as Map<String, dynamic>),
  animals:
      (json['animals'] as List<dynamic>?)
          ?.map((e) => FamilyTreeAnimalDto.fromJson(e as Map<String, dynamic>))
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

Map<String, dynamic> _$FamilyTreeLitterDtoToJson(
  FamilyTreeLitterDto instance,
) => <String, dynamic>{
  'litterUuid': instance.litterUuid,
  'litterTag': instance.litterTag,
  'weanDate': instance.weanDate?.toIso8601String(),
  'mating': instance.mating?.toJson(),
  'animals': instance.animals.map((e) => e.toJson()).toList(),
  'createdDate': instance.createdDate?.toIso8601String(),
  'comment': instance.comment,
  'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
};

FamilyTreeNodeDto _$FamilyTreeNodeDtoFromJson(
  Map<String, dynamic> json,
) => FamilyTreeNodeDto(
  animal: FamilyTreeAnimalDto.fromJson(json['animal'] as Map<String, dynamic>),
  birthLitter: json['birthLitter'] == null
      ? null
      : FamilyTreeLitterDto.fromJson(
          json['birthLitter'] as Map<String, dynamic>,
        ),
  offspringLitters:
      (json['offspringLitters'] as List<dynamic>?)
          ?.map((e) => FamilyTreeLitterDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  parents:
      (json['parents'] as List<dynamic>?)
          ?.map((e) => FamilyTreeNodeDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  children:
      (json['children'] as List<dynamic>?)
          ?.map((e) => FamilyTreeNodeDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$FamilyTreeNodeDtoToJson(
  FamilyTreeNodeDto instance,
) => <String, dynamic>{
  'animal': instance.animal.toJson(),
  'birthLitter': instance.birthLitter?.toJson(),
  'offspringLitters': instance.offspringLitters.map((e) => e.toJson()).toList(),
  'parents': instance.parents.map((e) => e.toJson()).toList(),
  'children': instance.children.map((e) => e.toJson()).toList(),
};
