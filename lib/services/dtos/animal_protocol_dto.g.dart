// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animal_protocol_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnimalProtocolDto _$AnimalProtocolDtoFromJson(Map<String, dynamic> json) =>
    AnimalProtocolDto(
      id: (json['id'] as num?)?.toInt(),
      animalProtocolUuid: json['animalProtocolUuid'] as String?,
      animal: json['animal'] == null
          ? null
          : AnimalSummaryDto.fromJson(json['animal'] as Map<String, dynamic>),
      role: json['role'] as String?,
      assignedDate: json['assignedDate'] as String,
      removedDate: json['removedDate'] as String?,
      removalReason: json['removalReason'] as String?,
      assignedBy: json['assignedBy'] == null
          ? null
          : AccountDto.fromJson(json['assignedBy'] as Map<String, dynamic>),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$AnimalProtocolDtoToJson(AnimalProtocolDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'animalProtocolUuid': instance.animalProtocolUuid,
      'animal': instance.animal?.toJson(),
      'role': instance.role,
      'assignedDate': instance.assignedDate,
      'removedDate': instance.removedDate,
      'removalReason': instance.removalReason,
      'assignedBy': instance.assignedBy?.toJson(),
      'notes': instance.notes,
    };
