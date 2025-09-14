// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountDto _$AccountDtoFromJson(Map<String, dynamic> json) => AccountDto(
  accountId: (json['accountId'] as num).toInt(),
  accountUuid: json['accountUuid'] as String,
  user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
  role: json['role'] as String?,
  isActive: json['isActive'] as bool?,
);

Map<String, dynamic> _$AccountDtoToJson(AccountDto instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'accountUuid': instance.accountUuid,
      'user': instance.user.toJson(),
      'role': instance.role,
      'isActive': instance.isActive,
    };

UserDto _$UserDtoFromJson(Map<String, dynamic> json) => UserDto(
  email: json['email'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  isActive: json['isActive'] as bool?,
);

Map<String, dynamic> _$UserDtoToJson(UserDto instance) => <String, dynamic>{
  'email': instance.email,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'isActive': instance.isActive,
};
