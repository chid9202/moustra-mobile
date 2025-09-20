import 'package:json_annotation/json_annotation.dart';

part 'user_list_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class UserListDto {
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

  UserListDto({
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

  factory UserListDto.fromJson(Map<String, dynamic> json) =>
      _$UserListDtoFromJson(json);
  Map<String, dynamic> toJson() => _$UserListDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class UserDto {
  final String email;
  final String firstName;
  final String lastName;
  final bool isActive;

  UserDto({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isActive,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);
  Map<String, dynamic> toJson() => _$UserDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AccountSettingDto {
  final bool enableDailyReport;
  final bool onboardingTour;
  final bool animalCreationTour;

  AccountSettingDto({
    required this.enableDailyReport,
    required this.onboardingTour,
    required this.animalCreationTour,
  });

  factory AccountSettingDto.fromJson(Map<String, dynamic> json) =>
      _$AccountSettingDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AccountSettingDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class LabDto {
  final int labId;
  final String labUuid;
  final String labName;

  LabDto({required this.labId, required this.labUuid, required this.labName});

  factory LabDto.fromJson(Map<String, dynamic> json) => _$LabDtoFromJson(json);
  Map<String, dynamic> toJson() => _$LabDtoToJson(this);
}
