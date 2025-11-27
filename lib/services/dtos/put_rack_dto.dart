import 'package:json_annotation/json_annotation.dart';

part 'put_rack_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class PutRackDto {
  final String rackName;
  final int rackWidth;
  final int rackHeight;

  PutRackDto({
    required this.rackName,
    required this.rackWidth,
    required this.rackHeight,
  });

  factory PutRackDto.fromJson(Map<String, dynamic> json) =>
      _$PutRackDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PutRackDtoToJson(this);
}
