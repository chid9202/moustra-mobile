import 'package:json_annotation/json_annotation.dart';
import 'package:moustra/services/dtos/animal_dto.dart';

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
  final DateTime? weanDate;

  AnimalStoreDto({
    required this.eid,
    required this.animalId,
    required this.animalUuid,
    this.physicalTag,
    this.isEnded,
    this.sex,
    this.dateOfBirth,
    this.weanDate,
  });

  factory AnimalStoreDto.fromJson(dynamic json) =>
      _$AnimalStoreDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AnimalStoreDtoToJson(this);
  AnimalSummaryDto toAnimalSummaryDto() => AnimalSummaryDto(
    animalId: animalId,
    animalUuid: animalUuid,
    physicalTag: physicalTag,
    dateOfBirth: dateOfBirth,
    sex: sex,
    owner: null, // Add missing owner field
    strain: null, // Add missing strain field
    weanDate: null, // Add missing weanDate field
    comment: null, // Add missing comment field
    createdDate: null, // Add missing createdDate field
    updatedDate: null, // Add missing updatedDate field
  );
}
