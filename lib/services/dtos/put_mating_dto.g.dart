// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_mating_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PutMatingDto _$PutMatingDtoFromJson(Map<String, dynamic> json) => PutMatingDto(
  matingId: (json['matingId'] as num).toInt(),
  matingUuid: json['matingUuid'] as String,
  matingTag: json['matingTag'] as String,
  litterStrain: json['litterStrain'] == null
      ? null
      : StrainStoreDto.fromJson(json['litterStrain']),
  setUpDate: DateTime.parse(json['setUpDate'] as String),
  owner: AccountStoreDto.fromJson(json['owner']),
  comment: json['comment'] as String?,
);

Map<String, dynamic> _$PutMatingDtoToJson(PutMatingDto instance) =>
    <String, dynamic>{
      'matingId': instance.matingId,
      'matingUuid': instance.matingUuid,
      'matingTag': instance.matingTag,
      'litterStrain': instance.litterStrain?.toJson(),
      'setUpDate': instance.setUpDate.toIso8601String(),
      'owner': instance.owner.toJson(),
      'comment': instance.comment,
    };
