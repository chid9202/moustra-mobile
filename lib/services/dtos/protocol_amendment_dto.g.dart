// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'protocol_amendment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProtocolAmendmentDto _$ProtocolAmendmentDtoFromJson(
  Map<String, dynamic> json,
) => ProtocolAmendmentDto(
  amendmentUuid: json['amendmentUuid'] as String?,
  amendmentNumber: json['amendmentNumber'] as String?,
  amendmentType: json['amendmentType'] as String?,
  description: json['description'] as String?,
  approvedDate: json['approvedDate'] as String?,
  effectiveDate: json['effectiveDate'] as String?,
  status: json['status'] as String?,
);

Map<String, dynamic> _$ProtocolAmendmentDtoToJson(
  ProtocolAmendmentDto instance,
) => <String, dynamic>{
  'amendmentUuid': instance.amendmentUuid,
  'amendmentNumber': instance.amendmentNumber,
  'amendmentType': instance.amendmentType,
  'description': instance.description,
  'approvedDate': instance.approvedDate,
  'effectiveDate': instance.effectiveDate,
  'status': instance.status,
};
