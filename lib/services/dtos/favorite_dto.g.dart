// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FavoriteDto _$FavoriteDtoFromJson(Map<String, dynamic> json) => FavoriteDto(
  favoriteUuid: json['favoriteUuid'] as String,
  objectType: json['objectType'] as String,
  objectUuid: json['objectUuid'] as String,
  createdDate: DateTime.parse(json['createdDate'] as String),
);

Map<String, dynamic> _$FavoriteDtoToJson(FavoriteDto instance) =>
    <String, dynamic>{
      'favoriteUuid': instance.favoriteUuid,
      'objectType': instance.objectType,
      'objectUuid': instance.objectUuid,
      'createdDate': instance.createdDate.toIso8601String(),
    };
