import 'package:json_annotation/json_annotation.dart';
import 'package:moustra/services/dtos/account_dto.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/services/dtos/cage_dto.dart';
import 'package:moustra/services/dtos/strain_dto.dart';

part 'mating_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class MatingDto {
  final int? eid;
  final int matingId;
  final String matingUuid;
  final List<AnimalSummaryDto>? animals;
  final StrainSummaryDto? litterStrain;
  final AccountDto? owner;
  final String? matingTag;
  final DateTime? setUpDate;
  final DateTime? pregnancyDate;
  final String? comment;
  final DateTime? disbandedDate;
  final AccountDto? disbandedBy;
  final DateTime? createdDate;
  final CageSummaryDto? cage;

  MatingDto({
    this.eid,
    required this.matingId,
    required this.matingUuid,
    this.animals = const [],
    this.litterStrain,
    this.owner,
    this.matingTag,
    this.setUpDate,
    this.pregnancyDate,
    this.comment,
    this.disbandedDate,
    this.disbandedBy,
    this.createdDate,
    this.cage,
  });

  factory MatingDto.fromJson(Map<String, dynamic> json) =>
      _$MatingDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MatingDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class MatingSummaryDto {
  final int? matingId;
  final String matingUuid;
  final String? matingTag;
  final StrainSummaryDto? litterStrain;
  final List<MatingSummaryAnimalDto>? animals;

  MatingSummaryDto({
    this.matingId,
    required this.matingUuid,
    this.matingTag,
    this.litterStrain,
    this.animals = const [],
  });

  factory MatingSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$MatingSummaryDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MatingSummaryDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class MatingSummaryAnimalDto {
  final int animalId;
  final String animalUuid;
  final String? physicalTag;
  final String? sex;
  final DateTime? dateOfBirth;

  MatingSummaryAnimalDto({
    required this.animalId,
    required this.animalUuid,
    this.physicalTag,
    this.sex,
    this.dateOfBirth,
  });

  factory MatingSummaryAnimalDto.fromJson(Map<String, dynamic> json) =>
      _$MatingSummaryAnimalDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MatingSummaryAnimalDtoToJson(this);
}
