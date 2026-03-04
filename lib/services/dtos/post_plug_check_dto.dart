import 'package:json_annotation/json_annotation.dart';

part 'post_plug_check_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class PostPlugCheckDto {
  final String female;
  final String? mating;
  final DateTime checkDate;
  final String result;
  final String? notes;

  PostPlugCheckDto({
    required this.female,
    this.mating,
    required this.checkDate,
    required this.result,
    this.notes,
  });

  factory PostPlugCheckDto.fromJson(Map<String, dynamic> json) =>
      _$PostPlugCheckDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PostPlugCheckDtoToJson(this);
}
