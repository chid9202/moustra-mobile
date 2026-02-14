// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'strain_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StrainDto _$StrainDtoFromJson(Map<String, dynamic> json) => StrainDto(
  strainId: (json['strainId'] as num).toInt(),
  strainUuid: json['strainUuid'] as String,
  strainName: json['strainName'] as String,
  owner: AccountDto.fromJson(json['owner'] as Map<String, dynamic>),
  weanAge: (json['weanAge'] as num?)?.toInt(),
  tagPrefix: json['tagPrefix'] as String?,
  comment: json['comment'] as String?,
  createdDate: DateTime.parse(json['createdDate'] as String),
  genotypes: (json['genotypes'] as List<dynamic>)
      .map((e) => GenotypeDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  color: json['color'] as String?,
  numberOfAnimals: (json['numberOfAnimals'] as num?)?.toInt() ?? 0,
  backgrounds:
      (json['backgrounds'] as List<dynamic>?)
          ?.map((e) => StrainBackgroundDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$StrainDtoToJson(StrainDto instance) => <String, dynamic>{
  'strainId': instance.strainId,
  'strainUuid': instance.strainUuid,
  'strainName': instance.strainName,
  'owner': instance.owner.toJson(),
  'weanAge': instance.weanAge,
  'tagPrefix': instance.tagPrefix,
  'comment': instance.comment,
  'createdDate': instance.createdDate.toIso8601String(),
  'genotypes': instance.genotypes.map((e) => e.toJson()).toList(),
  'color': instance.color,
  'numberOfAnimals': instance.numberOfAnimals,
  'backgrounds': instance.backgrounds.map((e) => e.toJson()).toList(),
  'isActive': instance.isActive,
};

StrainSummaryDto _$StrainSummaryDtoFromJson(Map<String, dynamic> json) =>
    StrainSummaryDto(
      strainId: (json['strainId'] as num).toInt(),
      strainUuid: json['strainUuid'] as String,
      strainName: json['strainName'] as String,
      color: json['color'] as String?,
      weanAge: (json['weanAge'] as num?)?.toInt(),
    );

Map<String, dynamic> _$StrainSummaryDtoToJson(StrainSummaryDto instance) =>
    <String, dynamic>{
      'strainId': instance.strainId,
      'strainUuid': instance.strainUuid,
      'strainName': instance.strainName,
      'color': instance.color,
      'weanAge': instance.weanAge,
    };

StrainBackgroundDto _$StrainBackgroundDtoFromJson(Map<String, dynamic> json) =>
    StrainBackgroundDto(
      id: (json['id'] as num).toInt(),
      uuid: json['uuid'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$StrainBackgroundDtoToJson(
  StrainBackgroundDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'uuid': instance.uuid,
  'name': instance.name,
};

PostStrainDto _$PostStrainDtoFromJson(Map<String, dynamic> json) =>
    PostStrainDto(
      backgrounds: (json['backgrounds'] as List<dynamic>)
          .map(BackgroundStoreDto.fromJson)
          .toList(),
      color: json['color'] as String,
      comment: json['comment'] as String?,
      owner: AccountStoreDto.fromJson(json['owner']),
      strainName: json['strainName'] as String,
      genotypes:
          (json['genotypes'] as List<dynamic>?)
              ?.map((e) => GenotypeDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$PostStrainDtoToJson(PostStrainDto instance) =>
    <String, dynamic>{
      'backgrounds': instance.backgrounds.map((e) => e.toJson()).toList(),
      'color': instance.color,
      'comment': instance.comment,
      'owner': instance.owner.toJson(),
      'strainName': instance.strainName,
      'genotypes': instance.genotypes.map((e) => e.toJson()).toList(),
    };

PutStrainDto _$PutStrainDtoFromJson(Map<String, dynamic> json) => PutStrainDto(
  strainId: (json['strainId'] as num).toInt(),
  strainUuid: json['strainUuid'] as String,
  isActive: json['isActive'] as bool?,
  backgrounds: (json['backgrounds'] as List<dynamic>)
      .map(BackgroundStoreDto.fromJson)
      .toList(),
  color: json['color'] as String,
  comment: json['comment'] as String?,
  owner: AccountStoreDto.fromJson(json['owner']),
  strainName: json['strainName'] as String,
  genotypes:
      (json['genotypes'] as List<dynamic>?)
          ?.map((e) => GenotypeDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$PutStrainDtoToJson(PutStrainDto instance) =>
    <String, dynamic>{
      'backgrounds': instance.backgrounds.map((e) => e.toJson()).toList(),
      'color': instance.color,
      'comment': instance.comment,
      'owner': instance.owner.toJson(),
      'strainName': instance.strainName,
      'genotypes': instance.genotypes.map((e) => e.toJson()).toList(),
      'strainId': instance.strainId,
      'strainUuid': instance.strainUuid,
      'isActive': instance.isActive,
    };
