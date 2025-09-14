// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountStoreDto _$AccountStoreDtoFromJson(Map<String, dynamic> json) =>
    AccountStoreDto(
      accountId: (json['accountId'] as num).toInt(),
      accountUuid: json['accountUuid'] as String,
      accountName: json['accountName'] as String,
      isActive: json['isActive'] as bool,
      onboarded: json['onboarded'] as bool,
      position: json['position'] as String,
      role: json['role'] as String,
      status: json['status'] as String,
      lab: AccountStoreLabDto.fromJson(json['lab'] as Map<String, dynamic>),
      user: AccountStoreUserDto.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AccountStoreDtoToJson(AccountStoreDto instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'accountUuid': instance.accountUuid,
      'accountName': instance.accountName,
      'isActive': instance.isActive,
      'onboarded': instance.onboarded,
      'position': instance.position,
      'role': instance.role,
      'status': instance.status,
      'lab': instance.lab.toJson(),
      'user': instance.user.toJson(),
    };

AccountStoreLabDto _$AccountStoreLabDtoFromJson(Map<String, dynamic> json) =>
    AccountStoreLabDto(
      labId: (json['labId'] as num).toInt(),
      labUuid: json['labUuid'] as String,
      labName: json['labName'] as String,
    );

Map<String, dynamic> _$AccountStoreLabDtoToJson(AccountStoreLabDto instance) =>
    <String, dynamic>{
      'labId': instance.labId,
      'labUuid': instance.labUuid,
      'labName': instance.labName,
    };

AccountStoreUserDto _$AccountStoreUserDtoFromJson(Map<String, dynamic> json) =>
    AccountStoreUserDto(
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$AccountStoreUserDtoToJson(
  AccountStoreUserDto instance,
) => <String, dynamic>{
  'email': instance.email,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'isActive': instance.isActive,
};
