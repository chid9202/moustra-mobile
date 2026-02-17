import 'package:json_annotation/json_annotation.dart';
import 'package:moustra/services/dtos/account_dto.dart';
import 'package:moustra/services/dtos/genotype_dto.dart';
import 'package:moustra/services/dtos/cage_dto.dart';
import 'package:moustra/services/dtos/stores/animal_store_dto.dart';
import 'package:moustra/services/dtos/stores/cage_store_dto.dart';
import 'package:moustra/services/dtos/stores/strain_store_dto.dart';
import 'package:moustra/services/dtos/strain_dto.dart';
import 'package:moustra/services/dtos/note_dto.dart';

part 'animal_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class AnimalDto {
  final int eid;
  final int animalId;
  final String animalUuid;
  final String? physicalTag;
  final DateTime? dateOfBirth;
  final String? sex;
  final List<GenotypeDto>? genotypes;
  final DateTime? weanDate;
  final DateTime? endDate;
  final EndTypeSummaryDto? endType;
  final EndReasonSummaryDto? endReason;
  final String? endComment;
  final AccountDto? owner;
  final CageSummaryDto? cage;
  final StrainSummaryDto? strain;
  final String? comment;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final AnimalSummaryDto? sire;
  final List<AnimalSummaryDto>? dam;
  final List<NoteDto>? notes;

  AnimalDto({
    required this.eid,
    required this.animalId,
    required this.animalUuid,
    this.physicalTag,
    this.dateOfBirth,
    this.sex,
    this.genotypes = const [],
    this.weanDate,
    this.endDate,
    this.endType,
    this.endReason,
    this.endComment,
    this.owner,
    this.cage,
    this.strain,
    this.comment,
    this.createdDate,
    this.updatedDate,
    this.sire,
    this.dam = const [],
    this.notes,
  });

  factory AnimalDto.fromJson(Map<String, dynamic> json) =>
      _$AnimalDtoFromJson(json);
  factory AnimalDto.fromDynamicJson(dynamic json) => _$AnimalDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AnimalDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AnimalSummaryDto {
  final int animalId;
  final String animalUuid;
  final String? physicalTag;
  final DateTime? dateOfBirth;
  final List<GenotypeDto>? genotypes;
  final AccountDto? owner;
  final StrainSummaryDto? strain;
  final String? weanDate;
  final String? sex;
  final String? comment;
  final DateTime? createdDate;
  final DateTime? updatedDate;

  AnimalSummaryDto({
    required this.animalId,
    required this.animalUuid,
    this.physicalTag,
    this.dateOfBirth,
    this.genotypes = const [],
    this.owner,
    this.strain,
    this.weanDate,
    this.sex,
    this.comment,
    this.createdDate,
    this.updatedDate,
  });

  factory AnimalSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$AnimalSummaryDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AnimalSummaryDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PostAnimalDto {
  final List<PostAnimalData> animals;

  PostAnimalDto({required this.animals});

  factory PostAnimalDto.fromJson(Map<String, dynamic> json) =>
      _$PostAnimalDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PostAnimalDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PostAnimalData {
  final String idx;
  final DateTime dateOfBirth;
  final List<PostGenotype> genotypes;
  final String physicalTag;
  final String? sex;
  final StrainStoreDto? strain;
  final AnimalStoreDto? sire;
  final List<AnimalStoreDto>? dam;
  final CageStoreDto? cage;
  final DateTime? weanDate;
  final String? comment;

  PostAnimalData({
    required this.idx,
    required this.dateOfBirth,
    required this.genotypes,
    required this.physicalTag,
    this.sex,
    this.strain,
    this.sire,
    this.dam,
    this.cage,
    this.weanDate,
    this.comment,
  });

  factory PostAnimalData.fromJson(Map<String, dynamic> json) =>
      _$PostAnimalDataFromJson(json);
  Map<String, dynamic> toJson() => _$PostAnimalDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PostGenotype {
  final String gene;
  final String allele;

  PostGenotype({required this.gene, required this.allele});

  factory PostGenotype.fromJson(Map<String, dynamic> json) =>
      _$PostGenotypeFromJson(json);
  Map<String, dynamic> toJson() => _$PostGenotypeToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PostStrainData {
  final int strainId;
  final String strainUuid;
  final String strainName;
  final int weanAge;
  final List<dynamic> genotypes;

  PostStrainData({
    required this.strainId,
    required this.strainUuid,
    required this.strainName,
    required this.weanAge,
    required this.genotypes,
  });

  factory PostStrainData.fromJson(Map<String, dynamic> json) =>
      _$PostStrainDataFromJson(json);
  Map<String, dynamic> toJson() => _$PostStrainDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PostAnimalSummary {
  final int animalId;
  final String animalUuid;
  final String physicalTag;
  final String sex;
  final String dateOfBirth;
  final bool isEnded;
  final int eid;

  PostAnimalSummary({
    required this.animalId,
    required this.animalUuid,
    required this.physicalTag,
    required this.sex,
    required this.dateOfBirth,
    required this.isEnded,
    required this.eid,
  });

  factory PostAnimalSummary.fromJson(Map<String, dynamic> json) =>
      _$PostAnimalSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$PostAnimalSummaryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PostCageData {
  final int cageId;
  final String cageUuid;
  final String cageTag;
  final List<PostCageAnimal> animals;
  final PostStrainData strain;

  PostCageData({
    required this.cageId,
    required this.cageUuid,
    required this.cageTag,
    required this.animals,
    required this.strain,
  });

  factory PostCageData.fromJson(Map<String, dynamic> json) =>
      _$PostCageDataFromJson(json);
  Map<String, dynamic> toJson() => _$PostCageDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PostCageAnimal {
  final int animalId;
  final String animalUuid;
  final String physicalTag;
  final String? weanDate;
  final String sex;
  final String dateOfBirth;
  final String? comment;
  final DateTime createdDate;
  final DateTime updatedDate;
  final int eid;

  PostCageAnimal({
    required this.animalId,
    required this.animalUuid,
    required this.physicalTag,
    this.weanDate,
    required this.sex,
    required this.dateOfBirth,
    this.comment,
    required this.createdDate,
    required this.updatedDate,
    required this.eid,
  });

  factory PostCageAnimal.fromJson(Map<String, dynamic> json) =>
      _$PostCageAnimalFromJson(json);
  Map<String, dynamic> toJson() => _$PostCageAnimalToJson(this);
}

@JsonSerializable(explicitToJson: true)
class EndTypeSummaryDto {
  final int endTypeId;
  final String endTypeUuid;
  final String endTypeName;

  EndTypeSummaryDto({
    required this.endTypeId,
    required this.endTypeUuid,
    required this.endTypeName,
  });

  factory EndTypeSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$EndTypeSummaryDtoFromJson(json);
  Map<String, dynamic> toJson() => _$EndTypeSummaryDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class EndReasonSummaryDto {
  final int endReasonId;
  final String endReasonUuid;
  final String endReasonName;

  EndReasonSummaryDto({
    required this.endReasonId,
    required this.endReasonUuid,
    required this.endReasonName,
  });

  factory EndReasonSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$EndReasonSummaryDtoFromJson(json);
  Map<String, dynamic> toJson() => _$EndReasonSummaryDtoToJson(this);
}
