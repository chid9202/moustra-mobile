// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDetailDto _$UserDetailDtoFromJson(Map<String, dynamic> json) =>
    UserDetailDto(
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

Map<String, dynamic> _$UserDetailDtoToJson(UserDetailDto instance) =>
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

PutUserDetailDto _$PutUserDetailDtoFromJson(Map<String, dynamic> json) =>
    PutUserDetailDto(
      accountUuid: json['accountUuid'] as String?,
      email: json['email'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      role: json['role'] as String,
      position: json['position'] as String?,
      isActive: json['isActive'] as bool,
      accountSetting: json['accountSetting'] == null
          ? null
          : AccountSettingDto.fromJson(
              json['accountSetting'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$PutUserDetailDtoToJson(PutUserDetailDto instance) =>
    <String, dynamic>{
      'accountUuid': instance.accountUuid,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'role': instance.role,
      'position': instance.position,
      'isActive': instance.isActive,
      'accountSetting': instance.accountSetting?.toJson(),
    };

PostUserDetailDto _$PostUserDetailDtoFromJson(Map<String, dynamic> json) =>
    PostUserDetailDto(
      accountUuid: json['accountUuid'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      role: json['role'] as String,
      position: json['position'] as String?,
      isActive: json['isActive'] as bool,
      lab: json['lab'] as String,
    );

Map<String, dynamic> _$PostUserDetailDtoToJson(PostUserDetailDto instance) =>
    <String, dynamic>{
      'accountUuid': instance.accountUuid,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'role': instance.role,
      'position': instance.position,
      'isActive': instance.isActive,
      'lab': instance.lab,
    };
