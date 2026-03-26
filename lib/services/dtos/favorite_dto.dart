import 'package:json_annotation/json_annotation.dart';

part 'favorite_dto.g.dart';

@JsonSerializable()
class FavoriteDto {
  final String favoriteUuid;
  final String objectType;
  final String objectUuid;
  final DateTime createdDate;

  FavoriteDto({
    required this.favoriteUuid,
    required this.objectType,
    required this.objectUuid,
    required this.createdDate,
  });

  factory FavoriteDto.fromJson(Map<String, dynamic> json) =>
      _$FavoriteDtoFromJson(json);
  Map<String, dynamic> toJson() => _$FavoriteDtoToJson(this);
}
