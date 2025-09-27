// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rack_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RackAnimalGeneDto _$RackAnimalGeneDtoFromJson(Map<String, dynamic> json) =>
    RackAnimalGeneDto(
      geneId: (json['geneId'] as num?)?.toInt(),
      geneUuid: json['geneUuid'] as String?,
      geneName: json['geneName'] as String?,
    );

Map<String, dynamic> _$RackAnimalGeneDtoToJson(RackAnimalGeneDto instance) =>
    <String, dynamic>{
      'geneId': instance.geneId,
      'geneUuid': instance.geneUuid,
      'geneName': instance.geneName,
    };

RackAnimalAlleleDto _$RackAnimalAlleleDtoFromJson(Map<String, dynamic> json) =>
    RackAnimalAlleleDto(
      alleleId: (json['alleleId'] as num?)?.toInt(),
      alleleUuid: json['alleleUuid'] as String?,
      alleleName: json['alleleName'] as String?,
      createdDate: json['createdDate'] == null
          ? null
          : DateTime.parse(json['createdDate'] as String),
    );

Map<String, dynamic> _$RackAnimalAlleleDtoToJson(
  RackAnimalAlleleDto instance,
) => <String, dynamic>{
  'alleleId': instance.alleleId,
  'alleleUuid': instance.alleleUuid,
  'alleleName': instance.alleleName,
  'createdDate': instance.createdDate?.toIso8601String(),
};

RackCageLitterDto _$RackCageLitterDtoFromJson(Map<String, dynamic> json) =>
    RackCageLitterDto(
      litterId: (json['litterId'] as num?)?.toInt(),
      litterUuid: json['litterUuid'] as String?,
      litterTag: json['litterTag'] as String?,
      createdDate: json['createdDate'] == null
          ? null
          : DateTime.parse(json['createdDate'] as String),
      updatedDate: json['updatedDate'] == null
          ? null
          : DateTime.parse(json['updatedDate'] as String),
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      comment: json['comment'] as String?,
      weanDate: json['weanDate'] == null
          ? null
          : DateTime.parse(json['weanDate'] as String),
    );

Map<String, dynamic> _$RackCageLitterDtoToJson(RackCageLitterDto instance) =>
    <String, dynamic>{
      'litterId': instance.litterId,
      'litterUuid': instance.litterUuid,
      'litterTag': instance.litterTag,
      'createdDate': instance.createdDate?.toIso8601String(),
      'updatedDate': instance.updatedDate?.toIso8601String(),
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'comment': instance.comment,
      'weanDate': instance.weanDate?.toIso8601String(),
    };

RackCageStrainDto _$RackCageStrainDtoFromJson(Map<String, dynamic> json) =>
    RackCageStrainDto(
      strainId: (json['strainId'] as num?)?.toInt(),
      strainUuid: json['strainUuid'] as String?,
      strainName: json['strainName'] as String?,
      color: json['color'] as String?,
    );

Map<String, dynamic> _$RackCageStrainDtoToJson(RackCageStrainDto instance) =>
    <String, dynamic>{
      'strainId': instance.strainId,
      'strainUuid': instance.strainUuid,
      'strainName': instance.strainName,
      'color': instance.color,
    };

RackCageOwnerDto _$RackCageOwnerDtoFromJson(Map<String, dynamic> json) =>
    RackCageOwnerDto(
      accountId: (json['accountId'] as num?)?.toInt(),
      accountUuid: json['accountUuid'] as String?,
      user: (json['user'] as num?)?.toInt(),
      role: json['role'] as String?,
      isActive: json['isActive'] as bool?,
    );

Map<String, dynamic> _$RackCageOwnerDtoToJson(RackCageOwnerDto instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'accountUuid': instance.accountUuid,
      'user': instance.user,
      'role': instance.role,
      'isActive': instance.isActive,
    };

RackCageAnimalGenotypeDto _$RackCageAnimalGenotypeDtoFromJson(
  Map<String, dynamic> json,
) => RackCageAnimalGenotypeDto(
  id: (json['id'] as num?)?.toInt(),
  gene: json['gene'] == null
      ? null
      : RackAnimalGeneDto.fromJson(json['gene'] as Map<String, dynamic>),
  allele: json['allele'] == null
      ? null
      : RackAnimalAlleleDto.fromJson(json['allele'] as Map<String, dynamic>),
  order: (json['order'] as num?)?.toInt(),
);

Map<String, dynamic> _$RackCageAnimalGenotypeDtoToJson(
  RackCageAnimalGenotypeDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'gene': instance.gene?.toJson(),
  'allele': instance.allele?.toJson(),
  'order': instance.order,
};

RackCageAnimalDto _$RackCageAnimalDtoFromJson(Map<String, dynamic> json) =>
    RackCageAnimalDto(
      animalId: (json['animalId'] as num?)?.toInt(),
      animalUuid: json['animalUuid'] as String,
      physicalTag: json['physicalTag'] as String?,
      weanDate: json['weanDate'] == null
          ? null
          : DateTime.parse(json['weanDate'] as String),
      sex: json['sex'] as String?,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      comment: json['comment'] as String?,
      createdDate: json['createdDate'] == null
          ? null
          : DateTime.parse(json['createdDate'] as String),
      updatedDate: json['updatedDate'] == null
          ? null
          : DateTime.parse(json['updatedDate'] as String),
      strain: json['strain'] == null
          ? null
          : RackCageStrainDto.fromJson(json['strain'] as Map<String, dynamic>),
      genotypes: (json['genotypes'] as List<dynamic>?)
          ?.map(
            (e) =>
                RackCageAnimalGenotypeDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      litter: json['litter'] == null
          ? null
          : RackCageLitterDto.fromJson(json['litter'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RackCageAnimalDtoToJson(RackCageAnimalDto instance) =>
    <String, dynamic>{
      'animalId': instance.animalId,
      'animalUuid': instance.animalUuid,
      'physicalTag': instance.physicalTag,
      'weanDate': instance.weanDate?.toIso8601String(),
      'sex': instance.sex,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'comment': instance.comment,
      'createdDate': instance.createdDate?.toIso8601String(),
      'updatedDate': instance.updatedDate?.toIso8601String(),
      'strain': instance.strain?.toJson(),
      'genotypes': instance.genotypes?.map((e) => e.toJson()).toList(),
      'litter': instance.litter?.toJson(),
    };

RackCageMatingDto _$RackCageMatingDtoFromJson(Map<String, dynamic> json) =>
    RackCageMatingDto(
      matingId: (json['matingId'] as num?)?.toInt(),
      matingUuid: json['matingUuid'] as String,
      animals: (json['animals'] as List<dynamic>?)
          ?.map((e) => RackCageAnimalDto.fromJson(e as Map<String, dynamic>))
          .toList(),
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
      disbandedBy: json['disbandedBy'] as String?,
      litterStrain: json['litterStrain'] == null
          ? null
          : RackCageStrainDto.fromJson(
              json['litterStrain'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$RackCageMatingDtoToJson(RackCageMatingDto instance) =>
    <String, dynamic>{
      'matingId': instance.matingId,
      'matingUuid': instance.matingUuid,
      'animals': instance.animals?.map((e) => e.toJson()).toList(),
      'matingTag': instance.matingTag,
      'setUpDate': instance.setUpDate?.toIso8601String(),
      'pregnancyDate': instance.pregnancyDate?.toIso8601String(),
      'comment': instance.comment,
      'disbandedDate': instance.disbandedDate?.toIso8601String(),
      'disbandedBy': instance.disbandedBy,
      'litterStrain': instance.litterStrain?.toJson(),
    };

RackCageDto _$RackCageDtoFromJson(Map<String, dynamic> json) => RackCageDto(
  cageId: (json['cageId'] as num?)?.toInt(),
  cageTag: json['cageTag'] as String?,
  cageUuid: json['cageUuid'] as String,
  owner: json['owner'] == null
      ? null
      : RackCageOwnerDto.fromJson(json['owner'] as Map<String, dynamic>),
  strain: json['strain'] == null
      ? null
      : RackCageStrainDto.fromJson(json['strain'] as Map<String, dynamic>),
  animals: (json['animals'] as List<dynamic>?)
      ?.map((e) => RackCageAnimalDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  mating: json['mating'] == null
      ? null
      : RackCageMatingDto.fromJson(json['mating'] as Map<String, dynamic>),
  order: (json['order'] as num?)?.toInt(),
  status: json['status'] as String?,
);

Map<String, dynamic> _$RackCageDtoToJson(RackCageDto instance) =>
    <String, dynamic>{
      'cageId': instance.cageId,
      'cageTag': instance.cageTag,
      'cageUuid': instance.cageUuid,
      'owner': instance.owner?.toJson(),
      'strain': instance.strain?.toJson(),
      'animals': instance.animals?.map((e) => e.toJson()).toList(),
      'mating': instance.mating?.toJson(),
      'order': instance.order,
      'status': instance.status,
    };

RackSimpleDto _$RackSimpleDtoFromJson(Map<String, dynamic> json) =>
    RackSimpleDto(
      rackId: (json['rackId'] as num).toInt(),
      rackUuid: json['rackUuid'] as String,
      rackName: json['rackName'] as String?,
    );

Map<String, dynamic> _$RackSimpleDtoToJson(RackSimpleDto instance) =>
    <String, dynamic>{
      'rackId': instance.rackId,
      'rackUuid': instance.rackUuid,
      'rackName': instance.rackName,
    };

RackDto _$RackDtoFromJson(Map<String, dynamic> json) => RackDto(
  rackId: (json['rackId'] as num?)?.toInt(),
  rackUuid: json['rackUuid'] as String?,
  rackName: json['rackName'] as String?,
  rackWidth: (json['rackWidth'] as num?)?.toInt(),
  rackHeight: (json['rackHeight'] as num?)?.toInt(),
  cages: (json['cages'] as List<dynamic>?)
      ?.map((e) => RackCageDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  racks: (json['racks'] as List<dynamic>?)
      ?.map((e) => RackSimpleDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RackDtoToJson(RackDto instance) => <String, dynamic>{
  'rackId': instance.rackId,
  'rackUuid': instance.rackUuid,
  'rackName': instance.rackName,
  'rackWidth': instance.rackWidth,
  'rackHeight': instance.rackHeight,
  'cages': instance.cages?.map((e) => e.toJson()).toList(),
  'racks': instance.racks?.map((e) => e.toJson()).toList(),
};
