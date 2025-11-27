import 'package:json_annotation/json_annotation.dart';

part 'post_rack_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class PostRackDto {
  final String rackName;
  final int rackWidth;
  final int rackHeight;

  PostRackDto({
    required this.rackName,
    required this.rackWidth,
    required this.rackHeight,
  });

  factory PostRackDto.fromJson(Map<String, dynamic> json) =>
      _$PostRackDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PostRackDtoToJson(this);
}

