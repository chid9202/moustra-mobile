import 'package:json_annotation/json_annotation.dart';
import 'package:moustra/services/dtos/stores/account_store_dto.dart';
import 'package:moustra/services/dtos/stores/cage_store_dto.dart';
import 'package:moustra/services/dtos/stores/strain_store_dto.dart';

part 'put_mating_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class PutMatingDto {
  final int matingId;
  final String matingUuid;
  final String matingTag;
  final StrainStoreDto? litterStrain;
  final DateTime setUpDate;
  final AccountStoreDto owner;
  final String? comment;

  PutMatingDto({
    required this.matingId,
    required this.matingUuid,
    required this.matingTag,
    this.litterStrain,
    required this.setUpDate,
    required this.owner,
    this.comment,
  });

  factory PutMatingDto.fromJson(Map<String, dynamic> json) =>
      _$PutMatingDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PutMatingDtoToJson(this);
}
