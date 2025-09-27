import 'package:json_annotation/json_annotation.dart';

part 'rack_dto.g.dart';

// Gene DTO
@JsonSerializable(explicitToJson: true)
class RackAnimalGeneDto {
  final int? geneId;
  final String? geneUuid;
  final String? geneName;

  RackAnimalGeneDto({this.geneId, this.geneUuid, this.geneName});

  factory RackAnimalGeneDto.fromJson(Map<String, dynamic> json) =>
      _$RackAnimalGeneDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RackAnimalGeneDtoToJson(this);
}

// Allele DTO
@JsonSerializable(explicitToJson: true)
class RackAnimalAlleleDto {
  final int? alleleId;
  final String? alleleUuid;
  final String? alleleName;
  final DateTime? createdDate;

  RackAnimalAlleleDto({
    this.alleleId,
    this.alleleUuid,
    this.alleleName,
    this.createdDate,
  });

  factory RackAnimalAlleleDto.fromJson(Map<String, dynamic> json) =>
      _$RackAnimalAlleleDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RackAnimalAlleleDtoToJson(this);
}

// Litter DTO
@JsonSerializable(explicitToJson: true)
class RackCageLitterDto {
  final int? litterId;
  final String? litterUuid;
  final String? litterTag;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final DateTime? dateOfBirth;
  final String? comment;
  final DateTime? weanDate;

  RackCageLitterDto({
    this.litterId,
    this.litterUuid,
    this.litterTag,
    this.createdDate,
    this.updatedDate,
    this.dateOfBirth,
    this.comment,
    this.weanDate,
  });

  factory RackCageLitterDto.fromJson(Map<String, dynamic> json) =>
      _$RackCageLitterDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RackCageLitterDtoToJson(this);
}

// Strain DTO
@JsonSerializable(explicitToJson: true)
class RackCageStrainDto {
  final int? strainId;
  final String? strainUuid;
  final String? strainName;
  final String? color;

  RackCageStrainDto({
    this.strainId,
    this.strainUuid,
    this.strainName,
    this.color,
  });

  factory RackCageStrainDto.fromJson(Map<String, dynamic> json) =>
      _$RackCageStrainDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RackCageStrainDtoToJson(this);
}

// Owner DTO
@JsonSerializable(explicitToJson: true)
class RackCageOwnerDto {
  final int? accountId;
  final String? accountUuid;
  final int? user;
  final String? role;
  final bool? isActive;

  RackCageOwnerDto({
    this.accountId,
    this.accountUuid,
    this.user,
    this.role,
    this.isActive,
  });

  factory RackCageOwnerDto.fromJson(Map<String, dynamic> json) =>
      _$RackCageOwnerDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RackCageOwnerDtoToJson(this);
}

// Genotype DTO
@JsonSerializable(explicitToJson: true)
class RackCageAnimalGenotypeDto {
  final int? id;
  final RackAnimalGeneDto? gene;
  final RackAnimalAlleleDto? allele;
  final int? order;

  RackCageAnimalGenotypeDto({this.id, this.gene, this.allele, this.order});

  factory RackCageAnimalGenotypeDto.fromJson(Map<String, dynamic> json) =>
      _$RackCageAnimalGenotypeDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RackCageAnimalGenotypeDtoToJson(this);
}

// Animal DTO
@JsonSerializable(explicitToJson: true)
class RackCageAnimalDto {
  final int? animalId;
  final String animalUuid;
  final String? physicalTag;
  final DateTime? weanDate;
  final String? sex;
  final DateTime? dateOfBirth;
  final String? comment;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final RackCageStrainDto? strain;
  final List<RackCageAnimalGenotypeDto>? genotypes;
  final RackCageLitterDto? litter;

  RackCageAnimalDto({
    this.animalId,
    required this.animalUuid,
    this.physicalTag,
    this.weanDate,
    this.sex,
    this.dateOfBirth,
    this.comment,
    this.createdDate,
    this.updatedDate,
    this.strain,
    this.genotypes,
    this.litter,
  });

  factory RackCageAnimalDto.fromJson(Map<String, dynamic> json) =>
      _$RackCageAnimalDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RackCageAnimalDtoToJson(this);
}

// Mating DTO
@JsonSerializable(explicitToJson: true)
class RackCageMatingDto {
  final int? matingId;
  final String matingUuid;
  final List<RackCageAnimalDto>? animals;
  final String? matingTag;
  final DateTime? setUpDate;
  final DateTime? pregnancyDate;
  final String? comment;
  final DateTime? disbandedDate;
  final String? disbandedBy;
  final RackCageStrainDto? litterStrain;

  RackCageMatingDto({
    this.matingId,
    required this.matingUuid,
    this.animals,
    this.matingTag,
    this.setUpDate,
    this.pregnancyDate,
    this.comment,
    this.disbandedDate,
    this.disbandedBy,
    this.litterStrain,
  });

  factory RackCageMatingDto.fromJson(Map<String, dynamic> json) =>
      _$RackCageMatingDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RackCageMatingDtoToJson(this);
}

// Cage DTO
@JsonSerializable(explicitToJson: true)
class RackCageDto {
  final int? cageId;
  final String? cageTag;
  final String cageUuid;
  final RackCageOwnerDto? owner;
  final RackCageStrainDto? strain;
  final List<RackCageAnimalDto>? animals;
  final RackCageMatingDto? mating;
  final int? order;
  final String? status;

  RackCageDto({
    this.cageId,
    this.cageTag,
    required this.cageUuid,
    this.owner,
    this.strain,
    this.animals,
    this.mating,
    this.order,
    this.status,
  });

  factory RackCageDto.fromJson(Map<String, dynamic> json) =>
      _$RackCageDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RackCageDtoToJson(this);
}

// Simple Rack DTO
@JsonSerializable(explicitToJson: true)
class RackSimpleDto {
  final int rackId;
  final String rackUuid;
  final String? rackName;

  RackSimpleDto({required this.rackId, required this.rackUuid, this.rackName});

  factory RackSimpleDto.fromJson(Map<String, dynamic> json) =>
      _$RackSimpleDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RackSimpleDtoToJson(this);
}

// Main Rack DTO
@JsonSerializable(explicitToJson: true)
class RackDto {
  final int? rackId;
  final String? rackUuid;
  final String? rackName;
  final int? rackWidth;
  final int? rackHeight;
  final List<RackCageDto>? cages;
  final List<RackSimpleDto>? racks;

  RackDto({
    this.rackId,
    this.rackUuid,
    this.rackName,
    this.rackWidth,
    this.rackHeight,
    this.cages,
    this.racks,
  });

  factory RackDto.fromJson(Map<String, dynamic> json) =>
      _$RackDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RackDtoToJson(this);
}
