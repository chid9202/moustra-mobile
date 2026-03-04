import 'package:json_annotation/json_annotation.dart';

part 'record_outcome_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class RecordOutcomeDto {
  final String outcome;
  final String outcomeDate;
  final int? embryosCollected;
  final String? litter;

  RecordOutcomeDto({
    required this.outcome,
    required this.outcomeDate,
    this.embryosCollected,
    this.litter,
  });

  factory RecordOutcomeDto.fromJson(Map<String, dynamic> json) =>
      _$RecordOutcomeDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RecordOutcomeDtoToJson(this);
}
