// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_litter_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostLitterDto _$PostLitterDtoFromJson(Map<String, dynamic> json) =>
    PostLitterDto(
      mating: json['mating'] as String,
      numberOfMale: (json['numberOfMale'] as num).toInt(),
      numberOfFemale: (json['numberOfFemale'] as num).toInt(),
      numberOfUnknown: (json['numberOfUnknown'] as num).toInt(),
      litterTag: json['litterTag'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      weanDate: json['weanDate'] == null
          ? null
          : DateTime.parse(json['weanDate'] as String),
      owner: AccountStoreDto.fromJson(json['owner']),
      comment: json['comment'] as String?,
      strain: json['strain'] == null
          ? null
          : StrainStoreDto.fromJson(json['strain']),
    );

Map<String, dynamic> _$PostLitterDtoToJson(PostLitterDto instance) =>
    <String, dynamic>{
      'mating': instance.mating,
      'numberOfMale': instance.numberOfMale,
      'numberOfFemale': instance.numberOfFemale,
      'numberOfUnknown': instance.numberOfUnknown,
      'litterTag': instance.litterTag,
      'dateOfBirth': instance.dateOfBirth.toIso8601String(),
      'weanDate': instance.weanDate?.toIso8601String(),
      'owner': instance.owner.toJson(),
      'comment': instance.comment,
    };
