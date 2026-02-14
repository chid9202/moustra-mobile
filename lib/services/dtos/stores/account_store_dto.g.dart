// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_store_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountStoreDto _$AccountStoreDtoFromJson(Map<String, dynamic> json) =>
    AccountStoreDto(
      accountId: (json['accountId'] as num).toInt(),
      accountUuid: json['accountUuid'] as String,
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
      isActive: json['isActive'] as bool?,
    );

Map<String, dynamic> _$AccountStoreDtoToJson(AccountStoreDto instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'accountUuid': instance.accountUuid,
      'isActive': ?instance.isActive,
      'user': instance.user.toJson(),
    };
