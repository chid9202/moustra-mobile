import 'package:json_annotation/json_annotation.dart';
import 'package:moustra/services/dtos/account_dto.dart';

part 'account_store_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class AccountStoreDto {
  final int accountId;
  final String accountUuid;
  final bool? isActive;
  final UserDto user;

  AccountStoreDto({
    required this.accountId,
    required this.accountUuid,
    required this.user,
    this.isActive,
  });

  factory AccountStoreDto.fromJson(dynamic json) =>
      _$AccountStoreDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AccountStoreDtoToJson(this);
}
