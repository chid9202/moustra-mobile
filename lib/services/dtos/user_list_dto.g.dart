// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_list_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserListDto _$UserListDtoFromJson(Map<String, dynamic> json) => UserListDto(
  accountId: (json['accountId'] as num).toInt(),
  accountUuid: json['accountUuid'] as String,
  user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
  status: json['status'] as String,
  role: json['role'] as String,
  isActive: json['isActive'] as bool,
  position: json['position'] as String?,
  accountSetting: AccountSettingDto.fromJson(
    json['accountSetting'] as Map<String, dynamic>,
  ),
  onboarded: json['onboarded'] as bool,
  lab: LabDto.fromJson(json['lab'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserListDtoToJson(UserListDto instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'accountUuid': instance.accountUuid,
      'user': instance.user.toJson(),
      'status': instance.status,
      'role': instance.role,
      'isActive': instance.isActive,
      'position': instance.position,
      'accountSetting': instance.accountSetting.toJson(),
      'onboarded': instance.onboarded,
      'lab': instance.lab.toJson(),
    };

UserDto _$UserDtoFromJson(Map<String, dynamic> json) => UserDto(
  email: json['email'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$UserDtoToJson(UserDto instance) => <String, dynamic>{
  'email': instance.email,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'isActive': instance.isActive,
};

AccountSettingDto _$AccountSettingDtoFromJson(Map<String, dynamic> json) =>
    AccountSettingDto(
      enableDailyReport: json['enableDailyReport'] as bool,
      onboardingTour: json['onboardingTour'] as bool,
      animalCreationTour: json['animalCreationTour'] as bool,
    );

Map<String, dynamic> _$AccountSettingDtoToJson(AccountSettingDto instance) =>
    <String, dynamic>{
      'enableDailyReport': instance.enableDailyReport,
      'onboardingTour': instance.onboardingTour,
      'animalCreationTour': instance.animalCreationTour,
    };

LabDto _$LabDtoFromJson(Map<String, dynamic> json) => LabDto(
  labId: (json['labId'] as num).toInt(),
  labUuid: json['labUuid'] as String,
  labName: json['labName'] as String,
);

Map<String, dynamic> _$LabDtoToJson(LabDto instance) => <String, dynamic>{
  'labId': instance.labId,
  'labUuid': instance.labUuid,
  'labName': instance.labName,
};
