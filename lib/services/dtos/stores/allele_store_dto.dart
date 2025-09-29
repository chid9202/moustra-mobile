import 'package:json_annotation/json_annotation.dart';

part 'allele_store_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class AlleleStoreDto {
  final int alleleId;
  final String alleleUuid;
  final String alleleName;
  final bool isActive;

  AlleleStoreDto({
    required this.alleleId,
    required this.alleleUuid,
    required this.alleleName,
    required this.isActive,
  });

  factory AlleleStoreDto.fromJson(dynamic json) =>
      _$AlleleStoreDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AlleleStoreDtoToJson(this);
}
