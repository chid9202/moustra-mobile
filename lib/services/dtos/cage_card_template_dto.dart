import 'package:json_annotation/json_annotation.dart';

part 'cage_card_template_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class CageCardCodeConfigDto {
  final String type;
  final String position;
  final String size;

  CageCardCodeConfigDto({
    required this.type,
    required this.position,
    required this.size,
  });

  factory CageCardCodeConfigDto.fromJson(Map<String, dynamic> json) =>
      _$CageCardCodeConfigDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CageCardCodeConfigDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CageCardStyleDto {
  final String? fontSize;
  final String? brandingText;

  CageCardStyleDto({this.fontSize, this.brandingText});

  factory CageCardStyleDto.fromJson(Map<String, dynamic> json) =>
      _$CageCardStyleDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CageCardStyleDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CageCardTemplateOwnerDto {
  final String accountUuid;
  final Map<String, dynamic>? user;

  CageCardTemplateOwnerDto({required this.accountUuid, this.user});

  factory CageCardTemplateOwnerDto.fromJson(Map<String, dynamic> json) =>
      _$CageCardTemplateOwnerDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CageCardTemplateOwnerDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CageCardTemplateDto {
  final String cageCardTemplateUuid;
  final String name;
  final String cardSize;
  final List<String> enabledFields;
  final List<String> fieldOrder;
  final CageCardCodeConfigDto? codeConfig;
  final CageCardStyleDto? style;
  final bool isDefault;
  final CageCardTemplateOwnerDto? owner;
  final String? createdDate;
  final String? updatedDate;

  CageCardTemplateDto({
    required this.cageCardTemplateUuid,
    required this.name,
    required this.cardSize,
    required this.enabledFields,
    required this.fieldOrder,
    this.codeConfig,
    this.style,
    required this.isDefault,
    this.owner,
    this.createdDate,
    this.updatedDate,
  });

  factory CageCardTemplateDto.fromJson(Map<String, dynamic> json) =>
      _$CageCardTemplateDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CageCardTemplateDtoToJson(this);
}
