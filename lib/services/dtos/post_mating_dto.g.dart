// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_mating_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostMatingDto _$PostMatingDtoFromJson(Map<String, dynamic> json) =>
    PostMatingDto(
      matingTag: json['matingTag'] as String,
      maleAnimal: json['maleAnimal'] as String,
      femaleAnimals: (json['femaleAnimals'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      cage: json['cage'] == null ? null : CageStoreDto.fromJson(json['cage']),
      litterStrain: json['litterStrain'] == null
          ? null
          : StrainStoreDto.fromJson(json['litterStrain']),
      setUpDate: DateTime.parse(json['setUpDate'] as String),
      owner: AccountStoreDto.fromJson(json['owner']),
      comment: json['comment'] as String?,
    );

Map<String, dynamic> _$PostMatingDtoToJson(PostMatingDto instance) =>
    <String, dynamic>{
      'matingTag': instance.matingTag,
      'maleAnimal': instance.maleAnimal,
      'femaleAnimals': instance.femaleAnimals,
      'cage': instance.cage?.toJson(),
      'litterStrain': instance.litterStrain?.toJson(),
      'setUpDate': instance.setUpDate.toIso8601String(),
      'owner': instance.owner.toJson(),
      'comment': instance.comment,
    };
