import 'package:json_annotation/json_annotation.dart';

part 'genotype_dto.g.dart';

@JsonSerializable(explicitToJson: true)
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

@JsonSerializable(explicitToJson: true)
class GeneDto {
  final int geneId;
  final String geneUuid;
  final String geneName;

  GeneDto({
    required this.geneId,
    required this.geneUuid,
    required this.geneName,
  });

  factory GeneDto.fromJson(Map<String, dynamic> json) =>
      _$GeneDtoFromJson(json);
  Map<String, dynamic> toJson() => _$GeneDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AlleleDto {
  final int alleleId;
  final String alleleUuid;
  final String alleleName;
  final DateTime? createdDate;

  AlleleDto({
    required this.alleleId,
    required this.alleleUuid,
    required this.alleleName,
    required this.createdDate,
  });

  factory AlleleDto.fromJson(Map<String, dynamic> json) =>
      _$AlleleDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AlleleDtoToJson(this);
}
