import 'package:json_annotation/json_annotation.dart';
import 'package:moustra/services/dtos/stores/account_store_dto.dart';
import 'package:moustra/services/dtos/strain_dto.dart';

part 'put_cage_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class PutCageDto {
  final int cageId;
  final String cageUuid;
  final String cageTag;
  final AccountStoreDto owner;
  final StrainSummaryDto strain;
  final DateTime setUpDate;
  final String? comment;

  PutCageDto({
    required this.cageId,
    required this.cageUuid,
    required this.cageTag,
    required this.owner,
    required this.strain,
    required this.setUpDate,
    this.comment,
  });

  factory PutCageDto.fromJson(Map<String, dynamic> json) =>
      _$PutCageDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PutCageDtoToJson(this);
}
