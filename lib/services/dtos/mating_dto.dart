import 'package:json_annotation/json_annotation.dart';
import 'package:moustra/services/dtos/account_dto.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/services/dtos/cage_dto.dart';
import 'package:moustra/services/dtos/litter_dto.dart';
import 'package:moustra/services/dtos/strain_dto.dart';
import 'package:moustra/services/dtos/note_dto.dart';

part 'mating_dto.g.dart';

double? _safeDouble(dynamic v) => v == null ? null : (v is num ? v.toDouble() : double.tryParse(v.toString()));
int? _safeInt(dynamic v) => v == null ? null : (v is num ? v.toInt() : int.tryParse(v.toString()));

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
  final List<NoteDto>? notes;
  final List<LitterDto>? litters;
  final List<MatingPlugEventDto>? plugEvents;

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
    this.notes,
    this.litters,
    this.plugEvents,
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
  final List<MatingSummaryAnimalDto>? animals;

  MatingSummaryDto({
    this.matingId,
    required this.matingUuid,
    this.matingTag,
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

@JsonSerializable(explicitToJson: true)
class MatingPlugEventDto {
  final String plugEventUuid;
  final AnimalSummaryDto? female;
  final AnimalSummaryDto? male;
  final String plugDate;
  final String? plugTime;
  @JsonKey(fromJson: _safeDouble)
  final double? targetEday;
  final String? targetDate;
  final String? expectedDeliveryStart;
  final String? expectedDeliveryEnd;
  final String? outcome;
  final String? outcomeDate;
  @JsonKey(fromJson: _safeDouble)
  final double? outcomeEday;
  @JsonKey(fromJson: _safeInt)
  final int? embryosCollected;
  @JsonKey(fromJson: _safeDouble)
  final double? currentEday;
  final String? createdDate;

  MatingPlugEventDto({
    required this.plugEventUuid,
    this.female,
    this.male,
    required this.plugDate,
    this.plugTime,
    this.targetEday,
    this.targetDate,
    this.expectedDeliveryStart,
    this.expectedDeliveryEnd,
    this.outcome,
    this.outcomeDate,
    this.outcomeEday,
    this.embryosCollected,
    this.currentEday,
    this.createdDate,
  });

  factory MatingPlugEventDto.fromJson(Map<String, dynamic> json) =>
      _$MatingPlugEventDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MatingPlugEventDtoToJson(this);
}
