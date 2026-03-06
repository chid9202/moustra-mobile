// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cage_card_template_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CageCardCodeConfigDto _$CageCardCodeConfigDtoFromJson(
  Map<String, dynamic> json,
) => CageCardCodeConfigDto(
  type: json['type'] as String,
  position: json['position'] as String,
  size: json['size'] as String,
);

Map<String, dynamic> _$CageCardCodeConfigDtoToJson(
  CageCardCodeConfigDto instance,
) => <String, dynamic>{
  'type': instance.type,
  'position': instance.position,
  'size': instance.size,
};

CageCardStyleDto _$CageCardStyleDtoFromJson(Map<String, dynamic> json) =>
    CageCardStyleDto(
      fontSize: json['fontSize'] as String?,
      brandingText: json['brandingText'] as String?,
    );

Map<String, dynamic> _$CageCardStyleDtoToJson(CageCardStyleDto instance) =>
    <String, dynamic>{
      'fontSize': instance.fontSize,
      'brandingText': instance.brandingText,
    };

CageCardTemplateOwnerDto _$CageCardTemplateOwnerDtoFromJson(
  Map<String, dynamic> json,
) => CageCardTemplateOwnerDto(
  accountUuid: json['accountUuid'] as String,
  user: json['user'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$CageCardTemplateOwnerDtoToJson(
  CageCardTemplateOwnerDto instance,
) => <String, dynamic>{
  'accountUuid': instance.accountUuid,
  'user': instance.user,
};

CageCardTemplateDto _$CageCardTemplateDtoFromJson(Map<String, dynamic> json) =>
    CageCardTemplateDto(
      cageCardTemplateUuid: json['cageCardTemplateUuid'] as String,
      name: json['name'] as String,
      cardSize: json['cardSize'] as String,
      enabledFields: (json['enabledFields'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      fieldOrder: (json['fieldOrder'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      codeConfig: json['codeConfig'] == null
          ? null
          : CageCardCodeConfigDto.fromJson(
              json['codeConfig'] as Map<String, dynamic>,
            ),
      style: json['style'] == null
          ? null
          : CageCardStyleDto.fromJson(json['style'] as Map<String, dynamic>),
      isDefault: json['isDefault'] as bool,
      owner: json['owner'] == null
          ? null
          : CageCardTemplateOwnerDto.fromJson(
              json['owner'] as Map<String, dynamic>,
            ),
      createdDate: json['createdDate'] as String?,
      updatedDate: json['updatedDate'] as String?,
    );

Map<String, dynamic> _$CageCardTemplateDtoToJson(
  CageCardTemplateDto instance,
) => <String, dynamic>{
  'cageCardTemplateUuid': instance.cageCardTemplateUuid,
  'name': instance.name,
  'cardSize': instance.cardSize,
  'enabledFields': instance.enabledFields,
  'fieldOrder': instance.fieldOrder,
  'codeConfig': instance.codeConfig?.toJson(),
  'style': instance.style?.toJson(),
  'isDefault': instance.isDefault,
  'owner': instance.owner?.toJson(),
  'createdDate': instance.createdDate,
  'updatedDate': instance.updatedDate,
};
