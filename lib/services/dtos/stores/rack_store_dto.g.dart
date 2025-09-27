// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rack_store_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RackStoreDto _$RackStoreDtoFromJson(Map<String, dynamic> json) => RackStoreDto(
  rackData: RackDto.fromJson(json['rackData'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RackStoreDtoToJson(RackStoreDto instance) =>
    <String, dynamic>{'rackData': instance.rackData.toJson()};
