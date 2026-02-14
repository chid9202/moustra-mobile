// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genotype_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GenotypeDto _$GenotypeDtoFromJson(Map<String, dynamic> json) => GenotypeDto(
  id: (json['id'] as num?)?.toInt(),
  gene: json['gene'] == null
      ? null
      : GeneDto.fromJson(json['gene'] as Map<String, dynamic>),
  allele: json['allele'] == null
      ? null
      : AlleleDto.fromJson(json['allele'] as Map<String, dynamic>),
  order: (json['order'] as num?)?.toInt(),
);

Map<String, dynamic> _$GenotypeDtoToJson(GenotypeDto instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'gene': ?instance.gene?.toJson(),
      'allele': ?instance.allele?.toJson(),
      'order': ?instance.order,
    };

GeneDto _$GeneDtoFromJson(Map<String, dynamic> json) => GeneDto(
  geneId: (json['geneId'] as num).toInt(),
  geneUuid: json['geneUuid'] as String,
  geneName: json['geneName'] as String,
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$GeneDtoToJson(GeneDto instance) => <String, dynamic>{
  'geneId': instance.geneId,
  'geneUuid': instance.geneUuid,
  'geneName': instance.geneName,
  'isActive': instance.isActive,
};

AlleleDto _$AlleleDtoFromJson(Map<String, dynamic> json) => AlleleDto(
  alleleId: (json['alleleId'] as num).toInt(),
  alleleUuid: json['alleleUuid'] as String,
  alleleName: json['alleleName'] as String,
  isActive: json['isActive'] as bool? ?? true,
  createdDate: json['createdDate'] == null
      ? null
      : DateTime.parse(json['createdDate'] as String),
);

Map<String, dynamic> _$AlleleDtoToJson(AlleleDto instance) => <String, dynamic>{
  'alleleId': instance.alleleId,
  'alleleUuid': instance.alleleUuid,
  'alleleName': instance.alleleName,
  'isActive': instance.isActive,
  'createdDate': ?instance.createdDate?.toIso8601String(),
};
