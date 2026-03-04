import 'package:json_annotation/json_annotation.dart';

part 'put_plug_event_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class PutPlugEventDto {
  final String? plugDate;
  final int? targetEday;
  final String? comment;
  final String? male;

  PutPlugEventDto({
    this.plugDate,
    this.targetEday,
    this.comment,
    this.male,
  });

  factory PutPlugEventDto.fromJson(Map<String, dynamic> json) =>
      _$PutPlugEventDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PutPlugEventDtoToJson(this);
}
