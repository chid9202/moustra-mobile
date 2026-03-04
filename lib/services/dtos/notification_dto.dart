import 'package:json_annotation/json_annotation.dart';
import 'package:moustra/services/dtos/field_change_dto.dart';

part 'notification_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class NotificationDto {
  final String notificationUuid;
  final String notificationType;
  final String title;
  final String message;
  final String? link;
  final Map<String, dynamic>? metadata;
  final bool isRead;
  final DateTime createdAt;

  NotificationDto({
    required this.notificationUuid,
    required this.notificationType,
    required this.title,
    required this.message,
    this.link,
    this.metadata,
    required this.isRead,
    required this.createdAt,
  });

  List<FieldChangeDto> get changes {
    final changesData = metadata?['changes'];
    if (changesData == null || changesData is! List) return [];
    return changesData
        .map((c) => FieldChangeDto.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  factory NotificationDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationDtoFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationDtoToJson(this);
}
