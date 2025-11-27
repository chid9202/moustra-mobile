// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_rack_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostRackDto _$PostRackDtoFromJson(Map<String, dynamic> json) => PostRackDto(
  rackName: json['rackName'] as String,
  rackWidth: (json['rackWidth'] as num).toInt(),
  rackHeight: (json['rackHeight'] as num).toInt(),
);

Map<String, dynamic> _$PostRackDtoToJson(PostRackDto instance) =>
    <String, dynamic>{
      'rackName': instance.rackName,
      'rackWidth': instance.rackWidth,
      'rackHeight': instance.rackHeight,
    };
