import 'package:json_annotation/json_annotation.dart';
import 'package:moustra/services/dtos/litter_dto.dart';

part 'family_tree_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class FamilyTreeDto {
  final LitterDto? parent;
  final LitterDto? children;

  FamilyTreeDto({
    this.parent,
    this.children,
  });

  factory FamilyTreeDto.fromJson(Map<String, dynamic> json) =>
      _$FamilyTreeDtoFromJson(json);
  Map<String, dynamic> toJson() => _$FamilyTreeDtoToJson(this);
}
