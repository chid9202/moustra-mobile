import 'package:json_annotation/json_annotation.dart';

part 'account_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class AccountDto {
  final int accountId;
  final String accountUuid;
  final UserDto user;
  final String role;
  final bool isActive;

  AccountDto({
    required this.accountId,
    required this.accountUuid,
    required this.user,
    required this.role,
    required this.isActive,
  });

  factory AccountDto.fromJson(Map<String, dynamic> json) =>
      _$AccountDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AccountDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class UserDto {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final bool isActive;

  UserDto({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isActive,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);
  Map<String, dynamic> toJson() => _$UserDtoToJson(this);
}
