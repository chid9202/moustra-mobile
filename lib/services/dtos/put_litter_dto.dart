import 'package:json_annotation/json_annotation.dart';
import 'package:moustra/services/dtos/stores/account_store_dto.dart';

part 'put_litter_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class PutLitterDto {
  final String? comment;
  final DateTime? dateOfBirth;
  final DateTime? weanDate;
  final AccountStoreDto? owner;
  final String? litterTag;

  PutLitterDto({
    this.comment,
    this.dateOfBirth,
    this.weanDate,
    this.owner,
    this.litterTag,
  });

  factory PutLitterDto.fromJson(Map<String, dynamic> json) =>
      _$PutLitterDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PutLitterDtoToJson(this);
}
