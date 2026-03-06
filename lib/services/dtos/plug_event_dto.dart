import 'package:json_annotation/json_annotation.dart';
import 'package:moustra/services/dtos/account_dto.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/services/dtos/mating_dto.dart';

part 'plug_event_dto.g.dart';

double? _safeDouble(dynamic v) => v == null ? null : (v is num ? v.toDouble() : double.tryParse(v.toString()));
int? _safeInt(dynamic v) => v == null ? null : (v is num ? v.toInt() : int.tryParse(v.toString()));

@JsonSerializable(explicitToJson: true)
class PlugEventDto {
  final int? eid;
  final int? plugEventId;
  final String plugEventUuid;
  final AnimalSummaryDto? female;
  final AnimalSummaryDto? male;
  final MatingSummaryDto? mating;
  final String plugDate;
  final String? plugTime;
  final AccountDto? checkedBy;
  @JsonKey(fromJson: _safeDouble)
  final double? currentEday;
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
  final String? comment;
  final AccountDto? owner;
  final String? createdDate;
  final String? updatedDate;

  PlugEventDto({
    this.eid,
    this.plugEventId,
    required this.plugEventUuid,
    this.female,
    this.male,
    this.mating,
    required this.plugDate,
    this.plugTime,
    this.checkedBy,
    this.currentEday,
    this.targetEday,
    this.targetDate,
    this.expectedDeliveryStart,
    this.expectedDeliveryEnd,
    this.outcome,
    this.outcomeDate,
    this.outcomeEday,
    this.embryosCollected,
    this.comment,
    this.owner,
    this.createdDate,
    this.updatedDate,
  });

  factory PlugEventDto.fromJson(Map<String, dynamic> json) =>
      _$PlugEventDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PlugEventDtoToJson(this);
}
