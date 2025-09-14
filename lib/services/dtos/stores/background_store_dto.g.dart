// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'background_store_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BackgroundStoreDto _$BackgroundStoreDtoFromJson(Map<String, dynamic> json) =>
    BackgroundStoreDto(
      id: (json['id'] as num).toInt(),
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      createdDate: DateTime.parse(json['createdDate'] as String),
      lab: json['lab'] as String,
      owner: json['owner'] as String,
    );

Map<String, dynamic> _$BackgroundStoreDtoToJson(BackgroundStoreDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'name': instance.name,
      'createdDate': instance.createdDate.toIso8601String(),
      'lab': instance.lab,
      'owner': instance.owner,
    };
