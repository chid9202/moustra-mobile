// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cage_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CageDto _$CageDtoFromJson(Map<String, dynamic> json) => CageDto(
  eid: (json['eid'] as num?)?.toInt(),
  cageId: (json['cageId'] as num).toInt(),
  cageTag: json['cageTag'] as String,
  cageUuid: json['cageUuid'] as String,
  owner: AccountDto.fromJson(json['owner'] as Map<String, dynamic>),
  strain: json['strain'] == null
      ? null
      : StrainSummaryDto.fromJson(json['strain'] as Map<String, dynamic>),
  animals:
      (json['animals'] as List<dynamic>?)
          ?.map((e) => AnimalSummaryDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  order: (json['order'] as num?)?.toInt() ?? 0,
  comment: json['comment'] as String?,
  createdDate: json['createdDate'] == null
      ? null
      : DateTime.parse(json['createdDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  status: json['status'] as String,
);

Map<String, dynamic> _$CageDtoToJson(CageDto instance) => <String, dynamic>{
  'eid': instance.eid,
  'cageId': instance.cageId,
  'cageTag': instance.cageTag,
  'cageUuid': instance.cageUuid,
  'owner': instance.owner.toJson(),
  'strain': instance.strain?.toJson(),
  'animals': instance.animals.map((e) => e.toJson()).toList(),
  'order': instance.order,
  'comment': instance.comment,
  'createdDate': instance.createdDate?.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'status': instance.status,
};

CageSummaryDto _$CageSummaryDtoFromJson(Map<String, dynamic> json) =>
    CageSummaryDto(
      cageId: (json['cageId'] as num).toInt(),
      cageUuid: json['cageUuid'] as String,
      cageTag: json['cageTag'] as String?,
      status: json['status'] as String?,
    );

Map<String, dynamic> _$CageSummaryDtoToJson(CageSummaryDto instance) =>
    <String, dynamic>{
      'cageId': instance.cageId,
      'cageUuid': instance.cageUuid,
      'cageTag': instance.cageTag,
      'status': instance.status,
    };
