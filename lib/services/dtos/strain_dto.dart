import 'package:json_annotation/json_annotation.dart';
import 'package:moustra/services/dtos/account_dto.dart';
import 'package:moustra/services/dtos/genotype_dto.dart';
import 'package:moustra/services/dtos/stores/account_store_dto.dart';
import 'package:moustra/services/dtos/stores/background_store_dto.dart';

part 'strain_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class StrainDto {
  final int strainId;
  final String strainUuid;
  final String strainName;
  final AccountDto owner;
  final int? weanAge;
  final String? tagPrefix;
  final String? comment;
  final DateTime createdDate;
  final List<GenotypeDto> genotypes;
  final String? color;
  final int numberOfAnimals;
  final List<StrainBackgroundDto> backgrounds;
  final bool isActive;

  StrainDto({
    required this.strainId,
    required this.strainUuid,
    required this.strainName,
    required this.owner,
    this.weanAge,
    this.tagPrefix,
    this.comment,
    required this.createdDate,
    required this.genotypes,
    this.color,
    this.numberOfAnimals = 0,
    this.backgrounds = const [],
    required this.isActive,
  });

  factory StrainDto.fromJson(Map<String, dynamic> json) =>
      _$StrainDtoFromJson(json);
  Map<String, dynamic> toJson() => _$StrainDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class StrainSummaryDto {
  final int strainId;
  final String strainUuid;
  final String strainName;
  final String? color;
  final int? weanAge;

  StrainSummaryDto({
    required this.strainId,
    required this.strainUuid,
    required this.strainName,
    this.color,
    this.weanAge,
  });

  factory StrainSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$StrainSummaryDtoFromJson(json);
  Map<String, dynamic> toJson() => _$StrainSummaryDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class StrainBackgroundDto {
  final int id;
  final String uuid;
  final String name;

  StrainBackgroundDto({
    required this.id,
    required this.uuid,
    required this.name,
  });

  factory StrainBackgroundDto.fromJson(Map<String, dynamic> json) {
    return StrainBackgroundDto(
      id: (json['id'] as int?) ?? 0,
      uuid: (json['uuid'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'uuid': uuid,
    'name': name,
  };
}

@JsonSerializable(explicitToJson: true)
class PostStrainDto {
  final List<BackgroundStoreDto> backgrounds;
  final String color;
  final String? comment;
  final AccountStoreDto account;
  final String strainName;

  PostStrainDto({
    required this.backgrounds,
    required this.color,
    this.comment,
    required this.account,
    required this.strainName,
  });

  factory PostStrainDto.fromJson(Map<String, dynamic> json) =>
      _$PostStrainDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PostStrainDtoToJson(this);
}
