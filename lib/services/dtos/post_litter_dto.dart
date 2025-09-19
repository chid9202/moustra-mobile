import 'package:json_annotation/json_annotation.dart';
import 'package:moustra/services/dtos/stores/account_store_dto.dart';

part 'post_litter_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class PostLitterDto {
  final String mating;
  final int numberOfMale;
  final int numberOfFemale;
  final int numberOfUnknown;
  final String litterTag;
  final DateTime dateOfBirth;
  final DateTime? weanDate;
  final AccountStoreDto owner;
  final String? comment;

  PostLitterDto({
    required this.mating,
    required this.numberOfMale,
    required this.numberOfFemale,
    required this.numberOfUnknown,
    required this.litterTag,
    required this.dateOfBirth,
    this.weanDate,
    required this.owner,
    this.comment,
  });

  factory PostLitterDto.fromJson(Map<String, dynamic> json) =>
      _$PostLitterDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PostLitterDtoToJson(this);
}
