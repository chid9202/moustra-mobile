// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationDto _$NotificationDtoFromJson(Map<String, dynamic> json) =>
    NotificationDto(
      notificationUuid: json['notificationUuid'] as String,
      notificationType: json['notificationType'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      link: json['link'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isRead: json['isRead'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$NotificationDtoToJson(NotificationDto instance) =>
    <String, dynamic>{
      'notificationUuid': instance.notificationUuid,
      'notificationType': instance.notificationType,
      'title': instance.title,
      'message': instance.message,
      'link': instance.link,
      'metadata': instance.metadata,
      'isRead': instance.isRead,
      'createdAt': instance.createdAt.toIso8601String(),
    };
