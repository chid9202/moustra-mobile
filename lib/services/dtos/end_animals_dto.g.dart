// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'end_animals_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EndAnimalsResponseDto _$EndAnimalsResponseDtoFromJson(
  Map<String, dynamic> json,
) => EndAnimalsResponseDto(
  animals: (json['animals'] as List<dynamic>)
      .map((e) => AnimalDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  endTypes: (json['endTypes'] as List<dynamic>)
      .map((e) => EndTypeSummaryDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  endReasons: (json['endReasons'] as List<dynamic>)
      .map((e) => EndReasonSummaryDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$EndAnimalsResponseDtoToJson(
  EndAnimalsResponseDto instance,
) => <String, dynamic>{
  'animals': instance.animals.map((e) => e.toJson()).toList(),
  'endTypes': instance.endTypes.map((e) => e.toJson()).toList(),
  'endReasons': instance.endReasons.map((e) => e.toJson()).toList(),
};

EndAnimalFormDto _$EndAnimalFormDtoFromJson(Map<String, dynamic> json) =>
    EndAnimalFormDto(
      endDate: json['endDate'] as String,
      endType: json['endType'] as String?,
      endReason: json['endReason'] as String?,
      endComment: json['endComment'] as String?,
      endCage: json['endCage'] as bool? ?? false,
    );

Map<String, dynamic> _$EndAnimalFormDtoToJson(EndAnimalFormDto instance) =>
    <String, dynamic>{
      'endDate': instance.endDate,
      'endType': instance.endType,
      'endReason': instance.endReason,
      'endComment': instance.endComment,
      'endCage': instance.endCage,
    };
