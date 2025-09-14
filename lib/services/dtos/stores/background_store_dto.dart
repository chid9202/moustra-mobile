import 'package:json_annotation/json_annotation.dart';

part 'background_store_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class BackgroundStoreDto {
  final int id;
  final String uuid;
  final String name;
  final DateTime? createdDate;
  final String? lab; // lab uuid
  final String? owner; // owner uuid

  BackgroundStoreDto({
    required this.id,
    required this.uuid,
    required this.name,
    this.createdDate,
    this.lab,
    this.owner,
  });

  factory BackgroundStoreDto.fromJson(dynamic json) =>
      _$BackgroundStoreDtoFromJson(json);
  Map<String, dynamic> toJson() => _$BackgroundStoreDtoToJson(this);
}
