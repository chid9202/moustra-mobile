// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'protocol_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProtocolDto _$ProtocolDtoFromJson(Map<String, dynamic> json) => ProtocolDto(
  protocolId: (json['protocolId'] as num?)?.toInt(),
  protocolUuid: json['protocolUuid'] as String,
  protocolNumber: json['protocolNumber'] as String,
  title: json['title'] as String,
  pi: json['pi'] == null
      ? null
      : AccountDto.fromJson(json['pi'] as Map<String, dynamic>),
  status: json['status'] as String?,
  approvalDate: json['approvalDate'] as String?,
  effectiveDate: json['effectiveDate'] as String?,
  expirationDate: json['expirationDate'] as String,
  painCategory: json['painCategory'] as String,
  maxAnimalCount: (json['maxAnimalCount'] as num).toInt(),
  currentAnimalCount: (json['currentAnimalCount'] as num?)?.toInt() ?? 0,
  animalCountPct: (json['animalCountPct'] as num?)?.toDouble(),
  daysUntilExpiry: (json['daysUntilExpiry'] as num?)?.toInt(),
  alertStatus: json['alertStatus'] as String?,
  species: json['species'] as String?,
  description: json['description'] as String?,
  fundingSource: json['fundingSource'] as String?,
  alertThresholdPct: (json['alertThresholdPct'] as num?)?.toInt(),
  alertDays: (json['alertDays'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  eid: (json['eid'] as num?)?.toInt(),
);

Map<String, dynamic> _$ProtocolDtoToJson(ProtocolDto instance) =>
    <String, dynamic>{
      'protocolId': instance.protocolId,
      'protocolUuid': instance.protocolUuid,
      'protocolNumber': instance.protocolNumber,
      'title': instance.title,
      'pi': instance.pi?.toJson(),
      'status': instance.status,
      'approvalDate': instance.approvalDate,
      'effectiveDate': instance.effectiveDate,
      'expirationDate': instance.expirationDate,
      'painCategory': instance.painCategory,
      'maxAnimalCount': instance.maxAnimalCount,
      'currentAnimalCount': instance.currentAnimalCount,
      'animalCountPct': instance.animalCountPct,
      'daysUntilExpiry': instance.daysUntilExpiry,
      'alertStatus': instance.alertStatus,
      'species': instance.species,
      'description': instance.description,
      'fundingSource': instance.fundingSource,
      'alertThresholdPct': instance.alertThresholdPct,
      'alertDays': instance.alertDays,
      'eid': instance.eid,
    };
