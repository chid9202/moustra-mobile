// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'protocol_document_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProtocolDocumentDto _$ProtocolDocumentDtoFromJson(Map<String, dynamic> json) =>
    ProtocolDocumentDto(
      documentUuid: json['documentUuid'] as String,
      documentType: json['documentType'] as String?,
      fileLink: json['fileLink'] as String?,
      filename: json['filename'] as String?,
      uploadedBy: json['uploadedBy'] as String?,
      uploadedAt: json['uploadedAt'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$ProtocolDocumentDtoToJson(
  ProtocolDocumentDto instance,
) => <String, dynamic>{
  'documentUuid': instance.documentUuid,
  'documentType': instance.documentType,
  'fileLink': instance.fileLink,
  'filename': instance.filename,
  'uploadedBy': instance.uploadedBy,
  'uploadedAt': instance.uploadedAt,
  'description': instance.description,
};
