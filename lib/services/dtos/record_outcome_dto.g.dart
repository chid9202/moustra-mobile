// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_outcome_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecordOutcomeDto _$RecordOutcomeDtoFromJson(Map<String, dynamic> json) =>
    RecordOutcomeDto(
      outcome: json['outcome'] as String,
      outcomeDate: json['outcomeDate'] as String,
      embryosCollected: (json['embryosCollected'] as num?)?.toInt(),
      litter: json['litter'] as String?,
    );

Map<String, dynamic> _$RecordOutcomeDtoToJson(RecordOutcomeDto instance) =>
    <String, dynamic>{
      'outcome': instance.outcome,
      'outcomeDate': instance.outcomeDate,
      'embryosCollected': instance.embryosCollected,
      'litter': instance.litter,
    };
