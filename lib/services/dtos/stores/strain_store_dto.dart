import 'package:json_annotation/json_annotation.dart';
import 'package:moustra/services/dtos/genotype_dto.dart';
import 'package:moustra/services/dtos/stores/cage_store_dto.dart';
import 'package:moustra/services/dtos/strain_dto.dart';

part 'strain_store_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class StrainStoreDto {
  final int strainId;
  final String strainUuid;
  final String strainName;
  final int? weanAge;
  final List<GenotypeDto> genotypes;

  StrainStoreDto({
    required this.strainId,
    required this.strainUuid,
    required this.strainName,
    this.weanAge,
    required this.genotypes,
  });

  factory StrainStoreDto.fromJson(dynamic json) =>
      _$StrainStoreDtoFromJson(json);
  Map<String, dynamic> toJson() => _$StrainStoreDtoToJson(this);
  StrainSummaryDto toStrainSummaryDto() => StrainSummaryDto(
    strainId: strainId,
    strainUuid: strainUuid,
    strainName: strainName,
  );
  CageStoreStrainDto toCageStoreStrainDto() => CageStoreStrainDto(
    strainId: strainId,
    strainUuid: strainUuid,
    strainName: strainName,
  );
}
