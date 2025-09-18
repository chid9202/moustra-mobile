import 'package:json_annotation/json_annotation.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/services/dtos/cage_dto.dart';
import 'package:moustra/services/dtos/stores/account_store_dto.dart';
import 'package:moustra/services/dtos/stores/cage_store_dto.dart';
import 'package:moustra/services/dtos/stores/strain_store_dto.dart';
import 'package:moustra/services/dtos/strain_dto.dart';

part 'post_mating_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class PostMatingDto {
  final String matingTag;
  final String maleAnimal;
  final List<String> femaleAnimals;
  final CageStoreDto? cage;
  final StrainStoreDto? litterStrain;
  final DateTime setUpDate;
  final AccountStoreDto owner;
  final String? comment;

  PostMatingDto({
    required this.matingTag,
    required this.maleAnimal,
    required this.femaleAnimals,
    this.cage,
    this.litterStrain,
    required this.setUpDate,
    required this.owner,
    this.comment,
  });

  factory PostMatingDto.fromJson(Map<String, dynamic> json) =>
      _$PostMatingDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PostMatingDtoToJson(this);
}
