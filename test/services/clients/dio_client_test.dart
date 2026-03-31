import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/clients/api_exceptions.dart';
import 'package:moustra/services/clients/dio_client.dart';
import 'package:moustra/services/connectivity_service.dart';

/// A mock HTTP client adapter that returns controlled responses.
class MockHttpClientAdapter implements HttpClientAdapter {
  late MockHttpResponse handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

typedef MockHttpResponse =
    Future<ResponseBody> Function(RequestOptions options);

void main() {
  late Dio dio;
  late MockHttpClientAdapter mockAdapter;

  setUpAll(() {
    dotenv.loadFromString(
      envString: 'API_BASE_URL=http://localhost:8000/api/v1',
    );
  });

  setUp(() {
    // Ensure connectivity is online by default
    connectivityService.isOnline.value = true;

    dio = createDio();

    // Replace the real HTTP adapter with the mock
    mockAdapter = MockHttpClientAdapter();
    dio.httpClientAdapter = mockAdapter;
  });

  group('Base configuration', () {
    test('baseUrl is set to ApiConfig.baseUrl', () {
      expect(dio.options.baseUrl, equals('http://localhost:8000/api/v1'));
    });

    test('connectTimeout is 30 seconds', () {
      expect(dio.options.connectTimeout, equals(const Duration(seconds: 30)));
    });

    test('receiveTimeout is 30 seconds', () {
      expect(dio.options.receiveTimeout, equals(const Duration(seconds: 30)));
    });

    test('Accept header is application/json', () {
      expect(dio.options.headers['Accept'], equals('application/json'));
    });
  });

  group('Request interceptor - connectivity check', () {
    test('rejects with ApiNetworkException when offline', () async {
      connectivityService.isOnline.value = false;

      mockAdapter.handler = (_) async => ResponseBody.fromString('', 200);

      try {
        await dio.get('/test');
        fail('Expected DioException to be thrown');
      } on DioException catch (e) {
        expect(e.error, isA<ApiNetworkException>());
        expect(e.type, equals(DioExceptionType.connectionError));
      }
    });

    test('allows requests when online', () async {
      connectivityService.isOnline.value = true;

      mockAdapter.handler = (_) async => ResponseBody.fromString(
        '{"ok": true}',
        200,
        headers: {
          'content-type': ['application/json'],
        },
      );

      final response = await dio.get('/test');
      expect(response.statusCode, equals(200));
    });
  });

  group('Request interceptor - auth token', () {
    test('no Authorization header when accessToken is null', () async {
      // Default state: authService.accessToken is null (no credentials set)
      RequestOptions? capturedOptions;
      mockAdapter.handler = (options) async {
        capturedOptions = options;
        return ResponseBody.fromString(
          '{"ok": true}',
          200,
          headers: {
            'content-type': ['application/json'],
          },
        );
      };

      await dio.get('/test');
      expect(capturedOptions, isNotNull);
      expect(capturedOptions!.headers['Authorization'], isNull);
    });
  });

  group('Error interceptor - timeout mapping', () {
    test('connectionTimeout is mapped to ApiTimeoutException', () async {
      mockAdapter.handler = (options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
        );
      };

      try {
        await dio.get('/test');
        fail('Expected DioException to be thrown');
      } on DioException catch (e) {
        expect(e.error, isA<ApiTimeoutException>());
        expect(e.type, equals(DioExceptionType.connectionTimeout));
      }
    });

    test('receiveTimeout is mapped to ApiTimeoutException', () async {
      mockAdapter.handler = (options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.receiveTimeout,
        );
      };

      try {
        await dio.get('/test');
        fail('Expected DioException to be thrown');
      } on DioException catch (e) {
        expect(e.error, isA<ApiTimeoutException>());
        expect(e.type, equals(DioExceptionType.receiveTimeout));
      }
    });

    test('sendTimeout is mapped to ApiTimeoutException', () async {
      mockAdapter.handler = (options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.sendTimeout,
        );
      };

      try {
        await dio.get('/test');
        fail('Expected DioException to be thrown');
      } on DioException catch (e) {
        expect(e.error, isA<ApiTimeoutException>());
        expect(e.type, equals(DioExceptionType.sendTimeout));
      }
    });
  });

  group('Error interceptor - connection error mapping', () {
    test('connectionError is mapped to ApiNetworkException', () async {
      mockAdapter.handler = (options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      };

      try {
        await dio.get('/test');
        fail('Expected DioException to be thrown');
      } on DioException catch (e) {
        expect(e.error, isA<ApiNetworkException>());
        expect(e.type, equals(DioExceptionType.connectionError));
        expect(
          (e.error as ApiNetworkException).message,
          equals('Network error: unable to connect'),
        );
      }
    });
  });

  group('Error interceptor - HTTP status mapping', () {
    test('401 response is mapped to ApiUnauthorizedException', () async {
      mockAdapter.handler = (options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: options,
            statusCode: 401,
            data: 'Unauthorized',
          ),
        );
      };

      try {
        await dio.get('/test');
        fail('Expected DioException to be thrown');
      } on DioException catch (e) {
        expect(e.error, isA<ApiUnauthorizedException>());
        expect(e.response?.statusCode, equals(401));
      }
    });

    test(
      '500 response is mapped to ApiException with status code and body',
      () async {
        mockAdapter.handler = (options) async {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: options,
              statusCode: 500,
              data: 'Internal Server Error',
            ),
          );
        };

        try {
          await dio.get('/test');
          fail('Expected DioException to be thrown');
        } on DioException catch (e) {
          expect(e.error, isA<ApiException>());
          final apiError = e.error as ApiException;
          expect(apiError.statusCode, equals(500));
          expect(apiError.body, equals('Internal Server Error'));
          expect(apiError.message, equals('Server error (500)'));
        }
      },
    );

    test('503 response is mapped to ApiException', () async {
      mockAdapter.handler = (options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: options,
            statusCode: 503,
            data: 'Service Unavailable',
          ),
        );
      };

      try {
        await dio.get('/test');
        fail('Expected DioException to be thrown');
      } on DioException catch (e) {
        expect(e.error, isA<ApiException>());
        final apiError = e.error as ApiException;
        expect(apiError.statusCode, equals(503));
        expect(apiError.message, equals('Server error (503)'));
      }
    });

    test('400 response passes through without interception', () async {
      mockAdapter.handler = (options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: options,
            statusCode: 400,
            data: 'Bad Request',
          ),
        );
      };

      try {
        await dio.get('/test');
        fail('Expected DioException to be thrown');
      } on DioException catch (e) {
        // 400 should pass through: the error field should NOT be
        // one of our custom API exceptions.
        expect(e.error, isNot(isA<ApiNetworkException>()));
        expect(e.error, isNot(isA<ApiTimeoutException>()));
        expect(e.error, isNot(isA<ApiUnauthorizedException>()));
        // The original DioException type is preserved
        expect(e.type, equals(DioExceptionType.badResponse));
        expect(e.response?.statusCode, equals(400));
      }
    });
  });
}
