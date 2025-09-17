import 'package:json_annotation/json_annotation.dart';
import 'package:moustra/services/dtos/cage_dto.dart';

part 'cage_store_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class CageStoreDto {
  final int cageId;
  final String cageUuid;
  final String? cageTag;
  final CageStoreStrainDto? strain;
  final List<CageStoreAnimalDto> animals;

  CageStoreDto({
    required this.cageId,
    required this.cageUuid,
    this.cageTag,
    this.strain,
    this.animals = const [],
  });

  factory CageStoreDto.fromJson(dynamic json) => _$CageStoreDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CageStoreDtoToJson(this);
  CageSummaryDto toCageSummaryDto() =>
      CageSummaryDto(cageId: cageId, cageUuid: cageUuid, cageTag: cageTag);
}

@JsonSerializable(explicitToJson: true)
class CageStoreStrainDto {
  final int strainId;
  final String strainUuid;
  final String strainName;
  final String? color;

  CageStoreStrainDto({
    required this.strainId,
    required this.strainUuid,
    required this.strainName,
    this.color,
  });

  factory CageStoreStrainDto.fromJson(dynamic json) =>
      _$CageStoreStrainDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CageStoreStrainDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CageStoreAnimalDto {
  final int eid;
  final int animalId;
  final String animalUuid;
  final String? physicalTag;
  final String? sex;
  final DateTime? dateOfBirth;
  final DateTime? weanDate;

  CageStoreAnimalDto({
    required this.eid,
    required this.animalId,
    required this.animalUuid,
    this.physicalTag,
    this.sex,
    this.dateOfBirth,
    this.weanDate,
  });

  factory CageStoreAnimalDto.fromJson(dynamic json) =>
      _$CageStoreAnimalDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CageStoreAnimalDtoToJson(this);
}
