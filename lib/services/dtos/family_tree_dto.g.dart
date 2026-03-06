// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_tree_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FamilyTreeDto _$FamilyTreeDtoFromJson(Map<String, dynamic> json) =>
    FamilyTreeDto(
      parent: json['parent'] == null
          ? null
          : LitterDto.fromJson(json['parent'] as Map<String, dynamic>),
      children: json['children'] == null
          ? null
          : LitterDto.fromJson(json['children'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FamilyTreeDtoToJson(FamilyTreeDto instance) =>
    <String, dynamic>{
      'parent': instance.parent?.toJson(),
      'children': instance.children?.toJson(),
    };
