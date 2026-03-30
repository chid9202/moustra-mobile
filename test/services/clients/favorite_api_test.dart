import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/clients/favorite_api.dart';

import 'favorite_api_test.mocks.dart';

@GenerateMocks([DioApiClient])
void main() {
  group('FavoriteApi', () {
    late MockDioApiClient mockClient;
    late FavoriteApi api;

    setUp(() {
      mockClient = MockDioApiClient();
      api = FavoriteApi(mockClient);
    });

    group('getAll', () {
      test('parses list on 200', () async {
        when(mockClient.get(any, query: anyNamed('query'))).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/favorites'),
            statusCode: 200,
            data: [
              {
                'favoriteUuid': 'f1',
                'objectType': 'cage',
                'objectUuid': 'c1',
                'createdDate': '2024-01-01T00:00:00.000Z',
              },
            ],
          ),
        );

        final list = await api.getAll();
        expect(list.length, 1);
        expect(list.first.objectUuid, 'c1');
        verify(mockClient.get('/favorites', query: {})).called(1);
      });

      test('passes type query when set', () async {
        when(mockClient.get(any, query: anyNamed('query'))).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/favorites'),
            statusCode: 200,
            data: <dynamic>[],
          ),
        );

        await api.getAll(type: 'animal');
        verify(mockClient.get('/favorites', query: {'type': 'animal'}))
            .called(1);
      });

      test('throws on non-200', () async {
        when(mockClient.get(any, query: anyNamed('query'))).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/favorites'),
            statusCode: 500,
            data: 'err',
          ),
        );

        expect(() => api.getAll(), throwsA(isA<Exception>()));
      });
    });

    group('toggle', () {
      test('returns body on 200', () async {
        when(mockClient.post(any,
                body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/favorites/toggle/'),
            statusCode: 200,
            data: {'ok': true},
          ),
        );

        final out = await api.toggle('cage', 'uuid-1');
        expect(out['ok'], true);
        verify(mockClient.post(
          '/favorites/toggle/',
          body: {
            'object_type': 'cage',
            'object_uuid': 'uuid-1',
          },
          query: anyNamed('query'),
        )).called(1);
      });

      test('accepts 201', () async {
        when(mockClient.post(any,
                body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/favorites/toggle/'),
            statusCode: 201,
            data: <String, dynamic>{},
          ),
        );

        await api.toggle('animal', 'a1');
        verify(mockClient.post(any,
                body: anyNamed('body'), query: anyNamed('query')))
            .called(1);
      });

      test('throws on error status', () async {
        when(mockClient.post(any,
                body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/favorites/toggle/'),
            statusCode: 400,
            data: 'bad',
          ),
        );

        expect(
          () => api.toggle('x', 'y'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
