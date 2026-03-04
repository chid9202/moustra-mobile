import 'package:json_annotation/json_annotation.dart';

part 'protocol_alert_dto.g.dart';

@JsonSerializable()
class ProtocolAlertDto {
  final int? id;
  final String? alertUuid;
  final String alertType;
  final String message;
  final String triggeredAt;
  final String? acknowledgedAt;
  final bool isResolved;

  ProtocolAlertDto({
    this.id,
    this.alertUuid,
    required this.alertType,
    required this.message,
    required this.triggeredAt,
    this.acknowledgedAt,
    this.isResolved = false,
  });

  factory ProtocolAlertDto.fromJson(Map<String, dynamic> json) =>
      _$ProtocolAlertDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ProtocolAlertDtoToJson(this);
}
