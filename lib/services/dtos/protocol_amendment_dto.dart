import 'package:json_annotation/json_annotation.dart';

part 'protocol_amendment_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class ProtocolAmendmentDto {
  final String? amendmentUuid;
  final String? amendmentNumber;
  final String? amendmentType;
  final String? description;
  final String? approvedDate;
  final String? effectiveDate;
  final String? status;

  ProtocolAmendmentDto({
    this.amendmentUuid,
    this.amendmentNumber,
    this.amendmentType,
    this.description,
    this.approvedDate,
    this.effectiveDate,
    this.status,
  });

  factory ProtocolAmendmentDto.fromJson(Map<String, dynamic> json) =>
      _$ProtocolAmendmentDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ProtocolAmendmentDtoToJson(this);
}
