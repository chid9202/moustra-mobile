import 'package:json_annotation/json_annotation.dart';

part 'account_store_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class AccountStoreDto {
  final int accountId;
  final String accountUuid;
  final String accountName;
  final bool isActive;
  final bool onboarded;
  final String? position;
  final String? role;
  final String? status;
  final AccountStoreLabDto lab;
  final AccountStoreUserDto user;

  AccountStoreDto({
    required this.accountId,
    required this.accountUuid,
    required this.accountName,
    required this.isActive,
    required this.onboarded,
    this.position,
    this.role,
    this.status,
    required this.lab,
    required this.user,
  });

  factory AccountStoreDto.fromJson(dynamic json) =>
      _$AccountStoreDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AccountStoreDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AccountStoreLabDto {
  final int labId;
  final String labUuid;
  final String labName;

  AccountStoreLabDto({
    required this.labId,
    required this.labUuid,
    required this.labName,
  });

  factory AccountStoreLabDto.fromJson(Map<String, dynamic> json) =>
      _$AccountStoreLabDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AccountStoreLabDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AccountStoreUserDto {
  final String email;
  final String firstName;
  final String lastName;
  final bool isActive;

  AccountStoreUserDto({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isActive,
  });

  factory AccountStoreUserDto.fromJson(Map<String, dynamic> json) =>
      _$AccountStoreUserDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AccountStoreUserDtoToJson(this);
}
