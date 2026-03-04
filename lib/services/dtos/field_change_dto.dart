import 'package:json_annotation/json_annotation.dart';

part 'field_change_dto.g.dart';

@JsonSerializable()
class FieldChangeDto {
  final String field;
  final String label;
  @JsonKey(name: 'old')
  final String? oldValue;
  @JsonKey(name: 'new')
  final String? newValue;

  FieldChangeDto({
    required this.field,
    required this.label,
    this.oldValue,
    this.newValue,
  });

  factory FieldChangeDto.fromJson(Map<String, dynamic> json) =>
      _$FieldChangeDtoFromJson(json);
  Map<String, dynamic> toJson() => _$FieldChangeDtoToJson(this);
}
