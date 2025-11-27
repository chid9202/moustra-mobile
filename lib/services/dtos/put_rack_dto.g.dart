// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_rack_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PutRackDto _$PutRackDtoFromJson(Map<String, dynamic> json) => PutRackDto(
  rackName: json['rackName'] as String,
  rackWidth: (json['rackWidth'] as num).toInt(),
  rackHeight: (json['rackHeight'] as num).toInt(),
);

Map<String, dynamic> _$PutRackDtoToJson(PutRackDto instance) =>
    <String, dynamic>{
      'rackName': instance.rackName,
      'rackWidth': instance.rackWidth,
      'rackHeight': instance.rackHeight,
    };
