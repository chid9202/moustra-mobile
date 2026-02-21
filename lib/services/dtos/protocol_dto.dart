import 'package:json_annotation/json_annotation.dart';
import 'package:moustra/services/dtos/account_dto.dart';

part 'protocol_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class ProtocolDto {
  final int? protocolId;
  final String protocolUuid;
  final String protocolNumber;
  final String title;
  final AccountDto? pi;
  final String? status;
  final String? approvalDate;
  final String? effectiveDate;
  final String expirationDate;
  final String painCategory;
  final int maxAnimalCount;
  final int currentAnimalCount;
  final double? animalCountPct;
  final int? daysUntilExpiry;
  final String? alertStatus;
  final String? species;
  final String? description;
  final String? fundingSource;
  final int? alertThresholdPct;
  final List<int>? alertDays;
  final int? eid;

  ProtocolDto({
    this.protocolId,
    required this.protocolUuid,
    required this.protocolNumber,
    required this.title,
    this.pi,
    this.status,
    this.approvalDate,
    this.effectiveDate,
    required this.expirationDate,
    required this.painCategory,
    required this.maxAnimalCount,
    this.currentAnimalCount = 0,
    this.animalCountPct,
    this.daysUntilExpiry,
    this.alertStatus,
    this.species,
    this.description,
    this.fundingSource,
    this.alertThresholdPct,
    this.alertDays,
    this.eid,
  });

  factory ProtocolDto.fromJson(Map<String, dynamic> json) =>
      _$ProtocolDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ProtocolDtoToJson(this);
}
