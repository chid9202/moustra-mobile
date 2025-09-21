import 'package:json_annotation/json_annotation.dart';
import 'package:moustra/services/dtos/user_list_dto.dart';

part 'user_detail_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class UserDetailDto {
  final int accountId;
  final String accountUuid;
  final String accountName;
  final UserDto user;
  final String status;
  final String role;
  final bool isActive;
  final String? position;
  final AccountSettingDto accountSetting;
  final bool onboarded;
  final LabDto lab;

  UserDetailDto({
    required this.accountId,
    required this.accountUuid,
    required this.accountName,
    required this.user,
    required this.status,
    required this.role,
    required this.isActive,
    this.position,
    required this.accountSetting,
    required this.onboarded,
    required this.lab,
  });

  factory UserDetailDto.fromJson(Map<String, dynamic> json) =>
      _$UserDetailDtoFromJson(json);
  Map<String, dynamic> toJson() => _$UserDetailDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PutUserDetailDto {
  final String? accountUuid;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String role;
  final String? position;
  final bool isActive;
  final AccountSettingDto? accountSetting;

  PutUserDetailDto({
    this.accountUuid,
    this.email,
    this.firstName,
    this.lastName,
    required this.role,
    this.position,
    required this.isActive,
    this.accountSetting,
  });

  factory PutUserDetailDto.fromJson(Map<String, dynamic> json) =>
      _$PutUserDetailDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PutUserDetailDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PostUserDetailDto {
  final String accountUuid;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? position;
  final bool isActive;
  final String lab;

  PostUserDetailDto({
    required this.accountUuid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.position,
    required this.isActive,
    required this.lab,
  });

  factory PostUserDetailDto.fromJson(Map<String, dynamic> json) =>
      _$PostUserDetailDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PostUserDetailDtoToJson(this);
}
