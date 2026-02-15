import 'package:json_annotation/json_annotation.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/services/dtos/strain_dto.dart';

part 'mating_history_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class MatingHistoryDto {
  final String matingUuid;
  final String? matingTag;
  final DateTime? setUpDate;
  final DateTime? disbandedDate;
  final StrainSummaryDto? litterStrain;
  final List<MatingHistoryLitterDto>? litters;

  MatingHistoryDto({
    required this.matingUuid,
    this.matingTag,
    this.setUpDate,
    this.disbandedDate,
    this.litterStrain,
    this.litters,
  });

  factory MatingHistoryDto.fromJson(Map<String, dynamic> json) =>
      _$MatingHistoryDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MatingHistoryDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class MatingHistoryLitterDto {
  final String litterUuid;
  final String? litterTag;
  final DateTime? dateOfBirth;
  final List<AnimalSummaryDto>? animals;

  MatingHistoryLitterDto({
    required this.litterUuid,
    this.litterTag,
    this.dateOfBirth,
    this.animals,
  });

  factory MatingHistoryLitterDto.fromJson(Map<String, dynamic> json) =>
      _$MatingHistoryLitterDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MatingHistoryLitterDtoToJson(this);
}
