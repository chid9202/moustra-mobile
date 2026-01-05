import 'package:json_annotation/json_annotation.dart';
import 'package:moustra/services/dtos/stores/account_store_dto.dart';
import 'package:moustra/services/dtos/strain_dto.dart';

part 'post_cage_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class PostCageDto {
  final String cageTag;
  final AccountStoreDto owner;
  final StrainSummaryDto? strain;
  final DateTime? setUpDate;
  final String? comment;
  final String? barcode;

  PostCageDto({
    required this.cageTag,
    required this.owner,
    this.strain,
    this.setUpDate,
    this.comment,
    this.barcode,
  });

  factory PostCageDto.fromJson(Map<String, dynamic> json) =>
      _$PostCageDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PostCageDtoToJson(this);
}
