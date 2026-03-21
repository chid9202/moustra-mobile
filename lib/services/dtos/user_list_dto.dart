import 'package:json_annotation/json_annotation.dart';

part 'user_list_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class UserListDto {
  @JsonKey(defaultValue: 0)
  final int accountId;
  @JsonKey(defaultValue: '')
  final String accountUuid;
  final UserDto user;
  @JsonKey(defaultValue: '')
  final String status;
  @JsonKey(defaultValue: 'User')
  final String role;
  @JsonKey(name: 'isActive', defaultValue: true)
  final bool isActive;
  final String? position;
  final AccountSettingDto? accountSetting;
  @JsonKey(defaultValue: false)
  final bool onboarded;
  final LabDto lab;

  UserListDto({
    this.accountId = 0,
    this.accountUuid = '',
    required this.user,
    this.status = '',
    this.role = 'User',
    this.isActive = true,
    this.position,
    this.accountSetting,
    this.onboarded = false,
    required this.lab,
  });

  factory UserListDto.fromJson(Map<String, dynamic> json) =>
      _$UserListDtoFromJson(json);
  Map<String, dynamic> toJson() => _$UserListDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class UserDto {
  @JsonKey(defaultValue: '')
  final String email;
  @JsonKey(defaultValue: '')
  final String firstName;
  @JsonKey(defaultValue: '')
  final String lastName;
  @JsonKey(defaultValue: true)
  final bool isActive;

  UserDto({
    this.email = '',
    this.firstName = '',
    this.lastName = '',
    this.isActive = true,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);
  Map<String, dynamic> toJson() => _$UserDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AccountSettingDto {
  @JsonKey(defaultValue: false)
  final bool enableDailyReport;
  @JsonKey(defaultValue: false)
  final bool onboardingTour;
  @JsonKey(defaultValue: false)
  final bool animalCreationTour;

  AccountSettingDto({
    this.enableDailyReport = false,
    this.onboardingTour = false,
    this.animalCreationTour = false,
  });

  factory AccountSettingDto.fromJson(Map<String, dynamic> json) =>
      _$AccountSettingDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AccountSettingDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class LabDto {
  @JsonKey(defaultValue: 0)
  final int labId;
  @JsonKey(defaultValue: '')
  final String labUuid;
  @JsonKey(defaultValue: '')
  final String labName;

  LabDto({this.labId = 0, this.labUuid = '', this.labName = ''});

  factory LabDto.fromJson(Map<String, dynamic> json) => _$LabDtoFromJson(json);
  Map<String, dynamic> toJson() => _$LabDtoToJson(this);
}
