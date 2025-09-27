import 'package:json_annotation/json_annotation.dart';
import 'package:moustra/services/dtos/rack_dto.dart';

part 'rack_store_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class RackStoreDto {
  final RackDto rackData;
  final List<double>? transformationMatrix;

  RackStoreDto({required this.rackData, this.transformationMatrix});

  factory RackStoreDto.fromJson(dynamic json) => _$RackStoreDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RackStoreDtoToJson(this);
}
