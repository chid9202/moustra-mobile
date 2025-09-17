import 'package:json_annotation/json_annotation.dart';

part 'gene_store_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class GeneStoreDto {
  final int geneId;
  final String geneUuid;
  final String geneName;

  GeneStoreDto({
    required this.geneId,
    required this.geneUuid,
    required this.geneName,
  });

  factory GeneStoreDto.fromJson(dynamic json) => _$GeneStoreDtoFromJson(json);
  Map<String, dynamic> toJson() => _$GeneStoreDtoToJson(this);
}
