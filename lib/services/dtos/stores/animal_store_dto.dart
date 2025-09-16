import 'package:json_annotation/json_annotation.dart';

part 'animal_store_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class AnimalStoreDto {
  final int eid;
  final int animalId;
  final String animalUuid;
  final String? physicalTag;
  final bool? isEnded;
  final String? sex;
  final DateTime? dateOfBirth;

  AnimalStoreDto({
    required this.eid,
    required this.animalId,
    required this.animalUuid,
    this.physicalTag,
    this.isEnded,
    this.sex,
    this.dateOfBirth,
  });

  factory AnimalStoreDto.fromJson(dynamic json) =>
      _$AnimalStoreDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AnimalStoreDtoToJson(this);
}
