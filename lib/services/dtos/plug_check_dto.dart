import 'package:json_annotation/json_annotation.dart';
import 'package:moustra/services/dtos/account_dto.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/services/dtos/mating_dto.dart';

part 'plug_check_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class PlugCheckDto {
  final int plugCheckId;
  final String plugCheckUuid;
  final AnimalSummaryDto? female;
  final MatingSummaryDto? mating;
  final DateTime checkDate;
  final String? checkTime;
  final String result;
  final AccountDto? checkedBy;
  final String? plugEventUuid;
  final String? notes;
  final AccountDto? owner;
  final DateTime? createdDate;

  PlugCheckDto({
    required this.plugCheckId,
    required this.plugCheckUuid,
    this.female,
    this.mating,
    required this.checkDate,
    this.checkTime,
    required this.result,
    this.checkedBy,
    this.plugEventUuid,
    this.notes,
    this.owner,
    this.createdDate,
  });

  factory PlugCheckDto.fromJson(Map<String, dynamic> json) =>
      _$PlugCheckDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PlugCheckDtoToJson(this);
}
