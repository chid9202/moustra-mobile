// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'field_change_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FieldChangeDto _$FieldChangeDtoFromJson(Map<String, dynamic> json) =>
    FieldChangeDto(
      field: json['field'] as String,
      label: json['label'] as String,
      oldValue: json['old'] as String?,
      newValue: json['new'] as String?,
    );

Map<String, dynamic> _$FieldChangeDtoToJson(FieldChangeDto instance) =>
    <String, dynamic>{
      'field': instance.field,
      'label': instance.label,
      'old': instance.oldValue,
      'new': instance.newValue,
    };
