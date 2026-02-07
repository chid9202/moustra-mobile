import 'package:json_annotation/json_annotation.dart';
import 'package:moustra/services/dtos/stores/account_store_dto.dart';
import 'package:moustra/services/dtos/stores/strain_store_dto.dart';

part 'put_litter_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class PutLitterDto {
  final String? comment;
  final DateTime? dateOfBirth;
  final DateTime? weanDate;
  final AccountStoreDto? owner;
  final String? litterTag;
  
  /// Strain to set on the litter.
  /// When serializing, this is transformed to { strain_uuid: ... } format for the backend.
  @JsonKey(includeToJson: false)
  final StrainStoreDto? strain;

  PutLitterDto({
    this.comment,
    this.dateOfBirth,
    this.weanDate,
    this.owner,
    this.litterTag,
    this.strain,
  });

  factory PutLitterDto.fromJson(Map<String, dynamic> json) =>
      _$PutLitterDtoFromJson(json);
  
  Map<String, dynamic> toJson() {
    final json = _$PutLitterDtoToJson(this);
    // Transform strain to backend format: { strain_uuid: ... } or null
    if (strain != null) {
      json['strain'] = {'strain_uuid': strain!.strainUuid};
    } else {
      json['strain'] = null;
    }
    return json;
  }
}
