import 'package:json_annotation/json_annotation.dart';
import 'package:moustra/services/dtos/genotype_dto.dart';
import 'package:moustra/services/dtos/strain_dto.dart';

part 'animal_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class AnimalSummaryDto {
  final int animalId;
  final String animalUuid;
  final String? physicalTag;
  final String? dateOfBirth;
  final List<GenotypeDto>? genotypes;
  final int? owner;
  final StrainSummaryDto? strain;
  final String? weanDate;
  final String? sex;
  final String? comment;
  final DateTime createdDate;
  final DateTime updatedDate;

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
    required this.createdDate,
    required this.updatedDate,
  });

  factory AnimalSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$AnimalSummaryDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AnimalSummaryDtoToJson(this);
}
