import 'dart:convert';

import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/services/dtos/notification_list_response_dto.dart';

class NotificationApi {
  final ApiClient _apiClient;
  static const String _path = '/notification';

  NotificationApi({ApiClient? client}) : _apiClient = client ?? apiClient;

  Future<NotificationListResponseDto> getNotifications({
    bool? isRead,
    String? type,
    int limit = 20,
    int offset = 0,
  }) async {
    final query = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    if (isRead != null) {
      query['is_read'] = isRead.toString();
    }
    if (type != null) {
      query['type'] = type;
    }

    final res = await _apiClient.get(_path, query: query);
    if (res.statusCode >= 400) {
      throw Exception('Failed to fetch notifications: ${res.body}');
    }
    final Map<String, dynamic> data = jsonDecode(res.body);
    return NotificationListResponseDto.fromJson(data);
  }

  Future<int> getUnreadCount() async {
    final res = await _apiClient.get('$_path/unread-count');
    if (res.statusCode >= 400) {
      throw Exception('Failed to fetch unread count: ${res.body}');
    }
    final data = jsonDecode(res.body);
    return data['count'] as int? ?? 0;
  }

  Future<void> markAsRead(String notificationUuid) async {
    final res = await _apiClient.patch('$_path/$notificationUuid/read');
    if (res.statusCode >= 400) {
      throw Exception('Failed to mark notification as read: ${res.body}');
    }
  }

  Future<void> markAllAsRead() async {
    final res = await _apiClient.post('$_path/read-all');
    if (res.statusCode >= 400) {
      throw Exception('Failed to mark all notifications as read: ${res.body}');
    }
  }
}

final NotificationApi notificationService = NotificationApi();
