import 'package:json_annotation/json_annotation.dart';
import 'package:moustra/services/dtos/account_dto.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/services/dtos/mating_dto.dart';

part 'plug_event_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class PlugEventDto {
  final int? eid;
  final int plugEventId;
  final String plugEventUuid;
  final AnimalSummaryDto? female;
  final AnimalSummaryDto? male;
  final MatingSummaryDto? mating;
  final DateTime plugDate;
  final String? plugTime;
  final AccountDto? checkedBy;
  final double? currentEday;
  final double? targetEday;
  final DateTime? targetDate;
  final DateTime? expectedDeliveryStart;
  final DateTime? expectedDeliveryEnd;
  final String? outcome;
  final DateTime? outcomeDate;
  final double? outcomeEday;
  final int? embryosCollected;
  final String? notes;
  final AccountDto? owner;
  final DateTime? createdDate;
  final DateTime? updatedDate;

  PlugEventDto({
    this.eid,
    required this.plugEventId,
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
    this.notes,
    this.owner,
    this.createdDate,
    this.updatedDate,
  });

  factory PlugEventDto.fromJson(Map<String, dynamic> json) =>
      _$PlugEventDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PlugEventDtoToJson(this);
}
