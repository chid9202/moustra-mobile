import 'package:json_annotation/json_annotation.dart';

part 'genotype_dto.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class GenotypeDto {
  final int? id;
  final GeneDto? gene;
  final AlleleDto? allele;
  final int? order;

  GenotypeDto({this.id, this.gene, this.allele, this.order});

  factory GenotypeDto.fromJson(Map<String, dynamic> json) =>
      _$GenotypeDtoFromJson(json);
  Map<String, dynamic> toJson() => _$GenotypeDtoToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class GeneDto {
  final int geneId;
  final String geneUuid;
  final String geneName;
  @JsonKey(defaultValue: true)
  final bool isActive;

  GeneDto({
    required this.geneId,
    required this.geneUuid,
    required this.geneName,
    this.isActive = true,
  });

  factory GeneDto.fromJson(Map<String, dynamic> json) =>
      _$GeneDtoFromJson(json);
  Map<String, dynamic> toJson() => _$GeneDtoToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class AlleleDto {
  final int alleleId;
  final String alleleUuid;
  final String alleleName;
  @JsonKey(defaultValue: true)
  final bool isActive;
  final DateTime? createdDate;

  AlleleDto({
    required this.alleleId,
    required this.alleleUuid,
    required this.alleleName,
    this.isActive = true,
    this.createdDate,
  });

  factory AlleleDto.fromJson(Map<String, dynamic> json) =>
      _$AlleleDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AlleleDtoToJson(this);
}
