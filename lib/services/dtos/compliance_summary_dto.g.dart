// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compliance_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComplianceSummaryDto _$ComplianceSummaryDtoFromJson(
  Map<String, dynamic> json,
) => ComplianceSummaryDto(
  totalActive: (json['totalActive'] as num).toInt(),
  expiring30d: (json['expiring30d'] as num).toInt(),
  expiring60d: (json['expiring60d'] as num).toInt(),
  expiring90d: (json['expiring90d'] as num).toInt(),
  expiredUnresolved: (json['expiredUnresolved'] as num).toInt(),
  overAnimalLimit: (json['overAnimalLimit'] as num).toInt(),
  nearAnimalLimit: (json['nearAnimalLimit'] as num).toInt(),
  animalsWithoutProtocol: (json['animalsWithoutProtocol'] as num).toInt(),
  unacknowledgedAlerts: (json['unacknowledgedAlerts'] as num).toInt(),
);

Map<String, dynamic> _$ComplianceSummaryDtoToJson(
  ComplianceSummaryDto instance,
) => <String, dynamic>{
  'totalActive': instance.totalActive,
  'expiring30d': instance.expiring30d,
  'expiring60d': instance.expiring60d,
  'expiring90d': instance.expiring90d,
  'expiredUnresolved': instance.expiredUnresolved,
  'overAnimalLimit': instance.overAnimalLimit,
  'nearAnimalLimit': instance.nearAnimalLimit,
  'animalsWithoutProtocol': instance.animalsWithoutProtocol,
  'unacknowledgedAlerts': instance.unacknowledgedAlerts,
};
