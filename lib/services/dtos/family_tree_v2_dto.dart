import 'package:json_annotation/json_annotation.dart';
import 'package:moustra/services/dtos/strain_dto.dart';

part 'family_tree_v2_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class FamilyTreeAnimalDto {
  final int? animalId;
  final String? animalUuid;
  final String? sex;
  final DateTime? dateOfBirth;
  final String? physicalTag;
  final StrainSummaryDto? strain;
  final List<FamilyTreeGenotypeDto> genotypes;

  FamilyTreeAnimalDto({
    this.animalId,
    this.animalUuid,
    this.sex,
    this.dateOfBirth,
    this.physicalTag,
    this.strain,
    this.genotypes = const [],
  });

  factory FamilyTreeAnimalDto.fromJson(Map<String, dynamic> json) =>
      _$FamilyTreeAnimalDtoFromJson(json);
  Map<String, dynamic> toJson() => _$FamilyTreeAnimalDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FamilyTreeGenotypeDto {
  final FamilyTreeGeneDto? gene;
  final FamilyTreeAlleleDto? allele;

  FamilyTreeGenotypeDto({this.gene, this.allele});

  factory FamilyTreeGenotypeDto.fromJson(Map<String, dynamic> json) =>
      _$FamilyTreeGenotypeDtoFromJson(json);
  Map<String, dynamic> toJson() => _$FamilyTreeGenotypeDtoToJson(this);
}

@JsonSerializable()
class FamilyTreeGeneDto {
  final int? geneId;
  final String? geneUuid;
  final String? geneName;

  FamilyTreeGeneDto({this.geneId, this.geneUuid, this.geneName});

  factory FamilyTreeGeneDto.fromJson(Map<String, dynamic> json) =>
      _$FamilyTreeGeneDtoFromJson(json);
  Map<String, dynamic> toJson() => _$FamilyTreeGeneDtoToJson(this);
}

@JsonSerializable()
class FamilyTreeAlleleDto {
  final int? alleleId;
  final String? alleleUuid;
  final String? alleleName;

  FamilyTreeAlleleDto({this.alleleId, this.alleleUuid, this.alleleName});

  factory FamilyTreeAlleleDto.fromJson(Map<String, dynamic> json) =>
      _$FamilyTreeAlleleDtoFromJson(json);
  Map<String, dynamic> toJson() => _$FamilyTreeAlleleDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FamilyTreeMatingDto {
  final String? matingUuid;
  final String? matingTag;
  final StrainSummaryDto? litterStrain;
  final List<FamilyTreeAnimalDto> animals;

  FamilyTreeMatingDto({
    this.matingUuid,
    this.matingTag,
    this.litterStrain,
    this.animals = const [],
  });

  factory FamilyTreeMatingDto.fromJson(Map<String, dynamic> json) =>
      _$FamilyTreeMatingDtoFromJson(json);
  Map<String, dynamic> toJson() => _$FamilyTreeMatingDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FamilyTreeLitterDto {
  final String? litterUuid;
  final String? litterTag;
  final DateTime? weanDate;
  final FamilyTreeMatingDto? mating;
  final List<FamilyTreeAnimalDto> animals;
  final DateTime? createdDate;
  final String? comment;
  final DateTime? dateOfBirth;

  FamilyTreeLitterDto({
    this.litterUuid,
    this.litterTag,
    this.weanDate,
    this.mating,
    this.animals = const [],
    this.createdDate,
    this.comment,
    this.dateOfBirth,
  });

  factory FamilyTreeLitterDto.fromJson(Map<String, dynamic> json) =>
      _$FamilyTreeLitterDtoFromJson(json);
  Map<String, dynamic> toJson() => _$FamilyTreeLitterDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FamilyTreeNodeDto {
  final FamilyTreeAnimalDto animal;
  final FamilyTreeLitterDto? birthLitter;
  final List<FamilyTreeLitterDto> offspringLitters;
  final List<FamilyTreeNodeDto> parents;
  final List<FamilyTreeNodeDto> children;

  FamilyTreeNodeDto({
    required this.animal,
    this.birthLitter,
    this.offspringLitters = const [],
    this.parents = const [],
    this.children = const [],
  });

  bool get hasConnections =>
      birthLitter != null ||
      offspringLitters.isNotEmpty ||
      parents.isNotEmpty ||
      children.isNotEmpty;

  factory FamilyTreeNodeDto.fromJson(Map<String, dynamic> json) =>
      _$FamilyTreeNodeDtoFromJson(json);
  Map<String, dynamic> toJson() => _$FamilyTreeNodeDtoToJson(this);
}
