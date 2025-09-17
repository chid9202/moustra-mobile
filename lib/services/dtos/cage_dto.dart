import 'package:json_annotation/json_annotation.dart';
import 'package:moustra/services/dtos/account_dto.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/services/dtos/strain_dto.dart';

part 'cage_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class CageDto {
  final int? eid;
  final int cageId;
  final String cageTag;
  final String cageUuid;
  final AccountDto owner;
  final StrainSummaryDto? strain;
  final List<AnimalSummaryDto> animals;
  final int? order;
  final String? comment;
  final DateTime? createdDate;
  final DateTime? endDate;
  final String status;

  CageDto({
    this.eid,
    required this.cageId,
    required this.cageTag,
    required this.cageUuid,
    required this.owner,
    this.strain,
    this.animals = const [],
    this.order = 0,
    this.comment,
    this.createdDate,
    this.endDate,
    required this.status,
  });

  factory CageDto.fromJson(Map<String, dynamic> json) =>
      _$CageDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CageDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CageSummaryDto {
  final int cageId;
  final String cageUuid;
  final String? cageTag;
  final String? status;

  CageSummaryDto({
    required this.cageId,
    required this.cageUuid,
    this.cageTag,
    this.status,
  });

  factory CageSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$CageSummaryDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CageSummaryDtoToJson(this);
}
