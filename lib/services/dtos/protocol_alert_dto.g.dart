// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'protocol_alert_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProtocolAlertDto _$ProtocolAlertDtoFromJson(Map<String, dynamic> json) =>
    ProtocolAlertDto(
      id: (json['id'] as num?)?.toInt(),
      alertUuid: json['alertUuid'] as String?,
      alertType: json['alertType'] as String,
      message: json['message'] as String,
      triggeredAt: json['triggeredAt'] as String,
      acknowledgedAt: json['acknowledgedAt'] as String?,
      isResolved: json['isResolved'] as bool? ?? false,
    );

Map<String, dynamic> _$ProtocolAlertDtoToJson(ProtocolAlertDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'alertUuid': instance.alertUuid,
      'alertType': instance.alertType,
      'message': instance.message,
      'triggeredAt': instance.triggeredAt,
      'acknowledgedAt': instance.acknowledgedAt,
      'isResolved': instance.isResolved,
    };
