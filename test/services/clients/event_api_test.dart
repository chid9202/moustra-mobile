import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:moustra/services/clients/dio_api_client.dart';

import 'event_api_test.mocks.dart';

class TestableEventApi {
  final DioApiClient apiClient;

  TestableEventApi(this.apiClient);

  Future<void> trackEvent(String eventName, String source) async {
    await apiClient.post(
      '/event',
      body: {
        'eventName': 'mobile_$eventName',
        'source': source,
      },
    );
  }
}

@GenerateMocks([DioApiClient])
void main() {
  group('EventApi Tests', () {
    late MockDioApiClient mockApiClient;
    late TestableEventApi api;

    setUp(() {
      mockApiClient = MockDioApiClient();
      api = TestableEventApi(mockApiClient);
    });

    group('trackEvent', () {
      test('should post event with mobile_ prefix', () async {
        when(mockApiClient.post(any,
                body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: null,
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        await api.trackEvent('screen_view', 'iOS');

        verify(mockApiClient.post(
          '/event',
          body: {
            'eventName': 'mobile_screen_view',
            'source': 'iOS',
          },
          query: anyNamed('query'),
        )).called(1);
      });

      test('should post with Android source', () async {
        when(mockApiClient.post(any,
                body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: null,
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        await api.trackEvent('button_tap', 'Android');

        verify(mockApiClient.post(
          '/event',
          body: {
            'eventName': 'mobile_button_tap',
            'source': 'Android',
          },
          query: anyNamed('query'),
        )).called(1);
      });
    });
  });
}
