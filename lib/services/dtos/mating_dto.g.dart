// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mating_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MatingDto _$MatingDtoFromJson(Map<String, dynamic> json) => MatingDto(
  eid: (json['eid'] as num?)?.toInt(),
  matingId: (json['matingId'] as num).toInt(),
  matingUuid: json['matingUuid'] as String,
  animals:
      (json['animals'] as List<dynamic>?)
          ?.map((e) => AnimalSummaryDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  litterStrain: json['litterStrain'] == null
      ? null
      : StrainSummaryDto.fromJson(json['litterStrain'] as Map<String, dynamic>),
  owner: json['owner'] == null
      ? null
      : AccountDto.fromJson(json['owner'] as Map<String, dynamic>),
  matingTag: json['matingTag'] as String?,
  setUpDate: json['setUpDate'] == null
      ? null
      : DateTime.parse(json['setUpDate'] as String),
  pregnancyDate: json['pregnancyDate'] == null
      ? null
      : DateTime.parse(json['pregnancyDate'] as String),
  comment: json['comment'] as String?,
  disbandedDate: json['disbandedDate'] == null
      ? null
      : DateTime.parse(json['disbandedDate'] as String),
  disbandedBy: json['disbandedBy'] == null
      ? null
      : AccountDto.fromJson(json['disbandedBy'] as Map<String, dynamic>),
  createdDate: json['createdDate'] == null
      ? null
      : DateTime.parse(json['createdDate'] as String),
  cage: json['cage'] == null
      ? null
      : CageSummaryDto.fromJson(json['cage'] as Map<String, dynamic>),
  notes: (json['notes'] as List<dynamic>?)
      ?.map((e) => NoteDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MatingDtoToJson(MatingDto instance) => <String, dynamic>{
  'eid': instance.eid,
  'matingId': instance.matingId,
  'matingUuid': instance.matingUuid,
  'animals': instance.animals?.map((e) => e.toJson()).toList(),
  'litterStrain': instance.litterStrain?.toJson(),
  'owner': instance.owner?.toJson(),
  'matingTag': instance.matingTag,
  'setUpDate': instance.setUpDate?.toIso8601String(),
  'pregnancyDate': instance.pregnancyDate?.toIso8601String(),
  'comment': instance.comment,
  'disbandedDate': instance.disbandedDate?.toIso8601String(),
  'disbandedBy': instance.disbandedBy?.toJson(),
  'createdDate': instance.createdDate?.toIso8601String(),
  'cage': instance.cage?.toJson(),
  'notes': instance.notes?.map((e) => e.toJson()).toList(),
};

MatingSummaryDto _$MatingSummaryDtoFromJson(Map<String, dynamic> json) =>
    MatingSummaryDto(
      matingId: (json['matingId'] as num?)?.toInt(),
      matingUuid: json['matingUuid'] as String,
      matingTag: json['matingTag'] as String?,
      litterStrain: json['litterStrain'] == null
          ? null
          : StrainSummaryDto.fromJson(
              json['litterStrain'] as Map<String, dynamic>,
            ),
      animals:
          (json['animals'] as List<dynamic>?)
              ?.map(
                (e) =>
                    MatingSummaryAnimalDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$MatingSummaryDtoToJson(MatingSummaryDto instance) =>
    <String, dynamic>{
      'matingId': instance.matingId,
      'matingUuid': instance.matingUuid,
      'matingTag': instance.matingTag,
      'litterStrain': instance.litterStrain?.toJson(),
      'animals': instance.animals?.map((e) => e.toJson()).toList(),
    };

MatingSummaryAnimalDto _$MatingSummaryAnimalDtoFromJson(
  Map<String, dynamic> json,
) => MatingSummaryAnimalDto(
  animalId: (json['animalId'] as num).toInt(),
  animalUuid: json['animalUuid'] as String,
  physicalTag: json['physicalTag'] as String?,
  sex: json['sex'] as String?,
  dateOfBirth: json['dateOfBirth'] == null
      ? null
      : DateTime.parse(json['dateOfBirth'] as String),
);

Map<String, dynamic> _$MatingSummaryAnimalDtoToJson(
  MatingSummaryAnimalDto instance,
) => <String, dynamic>{
  'animalId': instance.animalId,
  'animalUuid': instance.animalUuid,
  'physicalTag': instance.physicalTag,
  'sex': instance.sex,
  'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
};
