// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'allele_store_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlleleStoreDto _$AlleleStoreDtoFromJson(Map<String, dynamic> json) =>
    AlleleStoreDto(
      alleleId: (json['alleleId'] as num).toInt(),
      alleleUuid: json['alleleUuid'] as String,
      alleleName: json['alleleName'] as String,
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$AlleleStoreDtoToJson(AlleleStoreDto instance) =>
    <String, dynamic>{
      'alleleId': instance.alleleId,
      'alleleUuid': instance.alleleUuid,
      'alleleName': instance.alleleName,
      'isActive': instance.isActive,
    };
