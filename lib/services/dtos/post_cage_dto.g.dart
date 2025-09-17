// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_cage_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostCageDto _$PostCageDtoFromJson(Map<String, dynamic> json) => PostCageDto(
  cageTag: json['cageTag'] as String,
  owner: AccountStoreDto.fromJson(json['owner']),
  strain: StrainSummaryDto.fromJson(json['strain'] as Map<String, dynamic>),
  setUpDate: DateTime.parse(json['setUpDate'] as String),
  comment: json['comment'] as String?,
);

Map<String, dynamic> _$PostCageDtoToJson(PostCageDto instance) =>
    <String, dynamic>{
      'cageTag': instance.cageTag,
      'owner': instance.owner.toJson(),
      'strain': instance.strain.toJson(),
      'setUpDate': instance.setUpDate.toIso8601String(),
      'comment': instance.comment,
    };
