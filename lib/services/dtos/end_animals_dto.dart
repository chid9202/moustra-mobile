import 'package:json_annotation/json_annotation.dart';
import 'package:moustra/services/dtos/animal_dto.dart';

part 'end_animals_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class EndAnimalsResponseDto {
  final List<AnimalDto> animals;
  final List<EndTypeSummaryDto> endTypes;
  final List<EndReasonSummaryDto> endReasons;

  EndAnimalsResponseDto({
    required this.animals,
    required this.endTypes,
    required this.endReasons,
  });

  factory EndAnimalsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$EndAnimalsResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$EndAnimalsResponseDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class EndAnimalFormDto {
  final String endDate;
  final String? endType;
  final String? endReason;
  final String? endComment;
  final bool endCage;

  EndAnimalFormDto({
    required this.endDate,
    this.endType,
    this.endReason,
    this.endComment,
    this.endCage = false,
  });

  factory EndAnimalFormDto.fromJson(Map<String, dynamic> json) =>
      _$EndAnimalFormDtoFromJson(json);
  Map<String, dynamic> toJson() => _$EndAnimalFormDtoToJson(this);
}
