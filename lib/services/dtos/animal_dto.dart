import 'package:json_annotation/json_annotation.dart';
import 'package:moustra/services/dtos/account_dto.dart';
import 'package:moustra/services/dtos/genotype_dto.dart';
import 'package:moustra/services/dtos/cage_dto.dart';
import 'package:moustra/services/dtos/strain_dto.dart';

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
  final AccountDto? owner;
  final CageSummaryDto? cage;
  final StrainSummaryDto? strain;
  final String? comment;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final AnimalSummaryDto? sire;
  final List<AnimalSummaryDto>? dam;

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
    this.owner,
    this.cage,
    this.strain,
    this.comment,
    this.createdDate,
    this.updatedDate,
    this.sire,
    this.dam = const [],
  });

  factory AnimalDto.fromJson(Map<String, dynamic> json) =>
      _$AnimalDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AnimalDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AnimalSummaryDto {
  final int animalId;
  final String animalUuid;
  final String? physicalTag;
  final DateTime? dateOfBirth;
  final List<GenotypeDto>? genotypes;
  final int? owner;
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
