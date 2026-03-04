import 'package:json_annotation/json_annotation.dart';

part 'post_plug_event_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class PostPlugEventDto {
  final String female;
  final String? male;
  final String? mating;
  final String plugDate;
  final int? targetEday;
  final String? comment;

  PostPlugEventDto({
    required this.female,
    this.male,
    this.mating,
    required this.plugDate,
    this.targetEday,
    this.comment,
  });

  factory PostPlugEventDto.fromJson(Map<String, dynamic> json) =>
      _$PostPlugEventDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PostPlugEventDtoToJson(this);
}
