import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/notification_list_response_dto.dart';

class NotificationApi {
  final DioApiClient _apiClient;
  static const String _path = '/notification';

  NotificationApi({DioApiClient? client}) : _apiClient = client ?? dioApiClient;

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
    if (res.statusCode != null && res.statusCode! >= 400) {
      throw Exception('Failed to fetch notifications: ${res.data}');
    }
    final Map<String, dynamic> data = res.data as Map<String, dynamic>;
    return NotificationListResponseDto.fromJson(data);
  }

  Future<int> getUnreadCount() async {
    final res = await _apiClient.get('$_path/unread-count');
    if (res.statusCode != null && res.statusCode! >= 400) {
      throw Exception('Failed to fetch unread count: ${res.data}');
    }
    final data = res.data;
    return data['count'] as int? ?? 0;
  }

  Future<void> markAsRead(String notificationUuid) async {
    final res = await _apiClient.patch('$_path/$notificationUuid/read');
    if (res.statusCode != null && res.statusCode! >= 400) {
      throw Exception('Failed to mark notification as read: ${res.data}');
    }
  }

  Future<void> markAllAsRead() async {
    final res = await _apiClient.post('$_path/read-all');
    if (res.statusCode != null && res.statusCode! >= 400) {
      throw Exception('Failed to mark all notifications as read: ${res.data}');
    }
  }
}

final NotificationApi notificationService = NotificationApi();
