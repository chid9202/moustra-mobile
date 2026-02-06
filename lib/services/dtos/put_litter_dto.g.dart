// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_litter_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PutLitterDto _$PutLitterDtoFromJson(Map<String, dynamic> json) => PutLitterDto(
  comment: json['comment'] as String?,
  dateOfBirth: json['dateOfBirth'] == null
      ? null
      : DateTime.parse(json['dateOfBirth'] as String),
  weanDate: json['weanDate'] == null
      ? null
      : DateTime.parse(json['weanDate'] as String),
  owner: json['owner'] == null ? null : AccountStoreDto.fromJson(json['owner']),
  litterTag: json['litterTag'] as String?,
  strain: json['strain'] == null
      ? null
      : StrainStoreDto.fromJson(json['strain']),
);

Map<String, dynamic> _$PutLitterDtoToJson(PutLitterDto instance) =>
    <String, dynamic>{
      'comment': instance.comment,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'weanDate': instance.weanDate?.toIso8601String(),
      'owner': instance.owner?.toJson(),
      'litterTag': instance.litterTag,
    };
