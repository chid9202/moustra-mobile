import 'package:dio/dio.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/clients/notification_api.dart';

import 'notification_api_test.mocks.dart';

class TestableNotificationApi extends NotificationApi {
  TestableNotificationApi(DioApiClient apiClient) : super(client: apiClient);
}

@GenerateMocks([DioApiClient])
void main() {
  group('NotificationApi Tests', () {
    late MockDioApiClient mockApiClient;
    late TestableNotificationApi notificationApi;

    final sampleNotificationsResponse = {
      'notifications': [
        {
          'notificationUuid': 'uuid-1',
          'notificationType': 'item_update',
          'title': 'Animal Updated',
          'message': 'Animal A001 was updated',
          'isRead': false,
          'createdAt': '2026-03-04T10:00:00.000Z',
        },
        {
          'notificationUuid': 'uuid-2',
          'notificationType': 'system',
          'title': 'System Notice',
          'message': 'Maintenance',
          'isRead': true,
          'createdAt': '2026-03-03T10:00:00.000Z',
        },
      ],
      'count': 2,
      'unreadCount': 1,
    };

    final emptyResponse = {
      'notifications': [],
      'count': 0,
      'unreadCount': 0,
    };

    setUp(() {
      mockApiClient = MockDioApiClient();
      notificationApi = TestableNotificationApi(mockApiClient);
    });

    group('getNotifications', () {
      test('should return notifications on success', () async {
        when(
          mockApiClient.get(any, query: anyNamed('query')),
        ).thenAnswer(
          (_) async => Response(data: sampleNotificationsResponse, statusCode: 200, requestOptions: RequestOptions()),
        );

        final result = await notificationApi.getNotifications();

        expect(result.notifications.length, 2);
        expect(result.count, 2);
        expect(result.unreadCount, 1);
        expect(result.notifications[0].title, 'Animal Updated');
      });

      test('should pass query params correctly', () async {
        when(
          mockApiClient.get(any, query: anyNamed('query')),
        ).thenAnswer(
          (_) async => Response(data: emptyResponse, statusCode: 200, requestOptions: RequestOptions()),
        );

        await notificationApi.getNotifications(
          isRead: false,
          type: 'system',
          limit: 10,
          offset: 5,
        );

        verify(
          mockApiClient.get(
            '/notification',
            query: argThat(
              allOf([
                containsPair('limit', '10'),
                containsPair('offset', '5'),
                containsPair('is_read', 'false'),
                containsPair('type', 'system'),
              ]),
              named: 'query',
            ),
          ),
        ).called(1);
      });

      test('should handle empty response', () async {
        when(
          mockApiClient.get(any, query: anyNamed('query')),
        ).thenAnswer(
          (_) async => Response(data: emptyResponse, statusCode: 200, requestOptions: RequestOptions()),
        );

        final result = await notificationApi.getNotifications();

        expect(result.notifications, isEmpty);
        expect(result.count, 0);
      });
    });

    group('getUnreadCount', () {
      test('should return count on success', () async {
        when(
          mockApiClient.get(any),
        ).thenAnswer(
          (_) async => Response(data: {'count': 5}, statusCode: 200, requestOptions: RequestOptions()),
        );

        final count = await notificationApi.getUnreadCount();

        expect(count, 5);
        verify(mockApiClient.get('/notification/unread-count')).called(1);
      });

      test('should return 0 when count is null', () async {
        when(
          mockApiClient.get(any),
        ).thenAnswer(
          (_) async => Response(data: {}, statusCode: 200, requestOptions: RequestOptions()),
        );

        final count = await notificationApi.getUnreadCount();

        expect(count, 0);
      });
    });

    group('markAsRead', () {
      test('should call patch on success', () async {
        when(
          mockApiClient.patch(any),
        ).thenAnswer(
          (_) async => Response(data: '', statusCode: 200, requestOptions: RequestOptions()),
        );

        await notificationApi.markAsRead('uuid-1');

        verify(mockApiClient.patch('/notification/uuid-1/read')).called(1);
      });

      test('should throw on error', () async {
        when(
          mockApiClient.patch(any),
        ).thenAnswer(
          (_) async => Response(data: 'Not Found', statusCode: 404, requestOptions: RequestOptions()),
        );

        expect(
          () => notificationApi.markAsRead('bad-uuid'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('markAllAsRead', () {
      test('should call post on success', () async {
        when(
          mockApiClient.post(any),
        ).thenAnswer(
          (_) async => Response(data: '', statusCode: 200, requestOptions: RequestOptions()),
        );

        await notificationApi.markAllAsRead();

        verify(mockApiClient.post('/notification/read-all')).called(1);
      });

      test('should throw on error', () async {
        when(
          mockApiClient.post(any),
        ).thenAnswer(
          (_) async => Response(data: 'Server Error', statusCode: 500, requestOptions: RequestOptions()),
        );

        expect(
          () => notificationApi.markAllAsRead(),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
