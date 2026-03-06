import 'package:json_annotation/json_annotation.dart';

part 'protocol_document_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class ProtocolDocumentDto {
  final String documentUuid;
  final String? documentType;
  final String? fileLink;
  final String? filename;
  final String? uploadedBy;
  final String? uploadedAt;
  final String? description;

  ProtocolDocumentDto({
    required this.documentUuid,
    this.documentType,
    this.fileLink,
    this.filename,
    this.uploadedBy,
    this.uploadedAt,
    this.description,
  });

  factory ProtocolDocumentDto.fromJson(Map<String, dynamic> json) =>
      _$ProtocolDocumentDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ProtocolDocumentDtoToJson(this);
}
