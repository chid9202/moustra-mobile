// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gene_store_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeneStoreDto _$GeneStoreDtoFromJson(Map<String, dynamic> json) => GeneStoreDto(
  geneId: (json['geneId'] as num).toInt(),
  geneUuid: json['geneUuid'] as String,
  geneName: json['geneName'] as String,
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$GeneStoreDtoToJson(GeneStoreDto instance) =>
    <String, dynamic>{
      'geneId': instance.geneId,
      'geneUuid': instance.geneUuid,
      'geneName': instance.geneName,
      'isActive': instance.isActive,
    };
