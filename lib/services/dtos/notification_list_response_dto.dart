import 'package:moustra/services/dtos/notification_dto.dart';

class NotificationListResponseDto {
  final List<NotificationDto> notifications;
  final int count;
  final int unreadCount;

  NotificationListResponseDto({
    required this.notifications,
    required this.count,
    required this.unreadCount,
  });

  factory NotificationListResponseDto.fromJson(Map<String, dynamic> json) {
    final list = (json['notifications'] as List<dynamic>?)
            ?.map((e) => NotificationDto.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return NotificationListResponseDto(
      notifications: list,
      count: json['count'] as int? ?? 0,
      unreadCount: json['unreadCount'] as int? ?? 0,
    );
  }
}
