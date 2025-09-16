// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'strain_store_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StrainStoreDto _$StrainStoreDtoFromJson(Map<String, dynamic> json) =>
    StrainStoreDto(
      strainId: (json['strainId'] as num).toInt(),
      strainUuid: json['strainUuid'] as String,
      strainName: json['strainName'] as String,
      weanAge: (json['weanAge'] as num?)?.toInt(),
      genotypes: (json['genotypes'] as List<dynamic>)
          .map((e) => GenotypeDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StrainStoreDtoToJson(StrainStoreDto instance) =>
    <String, dynamic>{
      'strainId': instance.strainId,
      'strainUuid': instance.strainUuid,
      'strainName': instance.strainName,
      'weanAge': instance.weanAge,
      'genotypes': instance.genotypes.map((e) => e.toJson()).toList(),
    };
