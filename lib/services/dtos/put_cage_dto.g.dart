// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_cage_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PutCageDto _$PutCageDtoFromJson(Map<String, dynamic> json) => PutCageDto(
  cageId: (json['cageId'] as num).toInt(),
  cageUuid: json['cageUuid'] as String,
  cageTag: json['cageTag'] as String,
  owner: AccountStoreDto.fromJson(json['owner']),
  strain: json['strain'] == null
      ? null
      : StrainSummaryDto.fromJson(json['strain'] as Map<String, dynamic>),
  setUpDate: json['setUpDate'] == null
      ? null
      : DateTime.parse(json['setUpDate'] as String),
  comment: json['comment'] as String?,
  barcode: json['barcode'] as String?,
);

Map<String, dynamic> _$PutCageDtoToJson(PutCageDto instance) =>
    <String, dynamic>{
      'cageId': instance.cageId,
      'cageUuid': instance.cageUuid,
      'cageTag': instance.cageTag,
      'owner': instance.owner.toJson(),
      'strain': instance.strain?.toJson(),
      'setUpDate': instance.setUpDate?.toIso8601String(),
      'comment': instance.comment,
      'barcode': instance.barcode,
    };
