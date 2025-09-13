import 'package:json_annotation/json_annotation.dart';
import 'package:moustra/services/dtos/account_dto.dart';
import 'package:moustra/services/dtos/mating_dto.dart';

part 'litter_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class LitterDto {
  final int eid;
  final String litterUuid;
  final String? litterTag;
  final DateTime? weanDate;
  final MatingSummaryDto mating;
  final AccountDto owner;
  final List<LitterAnimalDto>? animals;
  final DateTime? createdDate;
  final String? comment;
  final DateTime? dateOfBirth;

  LitterDto({
    required this.eid,
    required this.litterUuid,
    this.litterTag,
    this.weanDate,
    required this.mating,
    required this.owner,
    this.animals = const [],
    this.createdDate,
    this.comment,
    this.dateOfBirth,
  });

  factory LitterDto.fromJson(Map<String, dynamic> json) =>
      _$LitterDtoFromJson(json);
  Map<String, dynamic> toJson() => _$LitterDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class LitterAnimalDto {
  final int animalId;
  final String animalUuid;
  final String? physicalTag;
  final String? sex;
  final DateTime? dateOfBirth;

  LitterAnimalDto({
    required this.animalId,
    required this.animalUuid,
    this.physicalTag,
    this.sex,
    this.dateOfBirth,
  });

  factory LitterAnimalDto.fromJson(Map<String, dynamic> json) =>
      _$LitterAnimalDtoFromJson(json);
  Map<String, dynamic> toJson() => _$LitterAnimalDtoToJson(this);
}
