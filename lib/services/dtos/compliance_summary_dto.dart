import 'package:json_annotation/json_annotation.dart';

part 'compliance_summary_dto.g.dart';

@JsonSerializable()
class ComplianceSummaryDto {
  final int totalActive;
  final int expiring30d;
  final int expiring60d;
  final int expiring90d;
  final int expiredUnresolved;
  final int overAnimalLimit;
  final int nearAnimalLimit;
  final int animalsWithoutProtocol;
  final int unacknowledgedAlerts;

  ComplianceSummaryDto({
    required this.totalActive,
    required this.expiring30d,
    required this.expiring60d,
    required this.expiring90d,
    required this.expiredUnresolved,
    required this.overAnimalLimit,
    required this.nearAnimalLimit,
    required this.animalsWithoutProtocol,
    required this.unacknowledgedAlerts,
  });

  factory ComplianceSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$ComplianceSummaryDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ComplianceSummaryDtoToJson(this);
}
