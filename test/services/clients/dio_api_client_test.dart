import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:moustra/services/clients/api_exceptions.dart';
import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/profile_dto.dart';
import 'package:moustra/stores/profile_store.dart';

import 'dio_api_client_test.mocks.dart';

/// Testable subclass that injects a mock Dio instance.
class TestableDioApiClient extends DioApiClient {
  final Dio mockDio;
  TestableDioApiClient(this.mockDio);

  @override
  Dio get dio => mockDio;
}

@GenerateMocks([Dio])
void main() {
  late MockDio mockDio;
  late TestableDioApiClient client;

  const testAccountUuid = 'test-account-uuid';

  setUp(() {
    mockDio = MockDio();
    client = TestableDioApiClient(mockDio);

    // Set up profile state with a test account UUID.
    profileState.value = ProfileResponseDto(
      accountUuid: testAccountUuid,
      firstName: 'Test',
      lastName: 'User',
      email: 'test@example.com',
      labName: 'Test Lab',
      labUuid: 'lab-uuid',
      onboarded: true,
      onboardedDate: DateTime(2025, 1, 1),
      position: 'Researcher',
      role: 'admin',
      plan: 'pro',
    );
  });

  tearDown(() {
    profileState.value = null;
  });

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Response<dynamic> _mockResponse({
    dynamic data,
    int statusCode = 200,
  }) {
    return Response(
      data: data,
      statusCode: statusCode,
      requestOptions: RequestOptions(),
    );
  }

  DioException _dioException({
    required DioExceptionType type,
    Object? error,
  }) {
    return DioException(
      requestOptions: RequestOptions(),
      type: type,
      error: error,
    );
  }

  // ---------------------------------------------------------------------------
  // 1. Path building (_buildPath) — tested indirectly via HTTP methods
  // ---------------------------------------------------------------------------

  group('Path building', () {
    test('get() prefixes path with /account/{uuid} by default', () async {
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => _mockResponse(data: 'ok'));

      await client.get('/animals');

      verify(mockDio.get(
        '/account/$testAccountUuid/animals',
        queryParameters: anyNamed('queryParameters'),
      )).called(1);
    });

    test('get() skips account prefix when withoutAccountPrefix is true',
        () async {
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => _mockResponse(data: 'ok'));

      await client.get('/auth/login', withoutAccountPrefix: true);

      verify(mockDio.get(
        '/auth/login',
        queryParameters: anyNamed('queryParameters'),
      )).called(1);
    });

    test('get() adds leading slash when path does not start with /', () async {
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => _mockResponse(data: 'ok'));

      await client.get('animals');

      verify(mockDio.get(
        '/account/$testAccountUuid/animals',
        queryParameters: anyNamed('queryParameters'),
      )).called(1);
    });

    test('path without leading slash and withoutAccountPrefix', () async {
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => _mockResponse(data: 'ok'));

      await client.get('health', withoutAccountPrefix: true);

      verify(mockDio.get(
        '/health',
        queryParameters: anyNamed('queryParameters'),
      )).called(1);
    });
  });

  // ---------------------------------------------------------------------------
  // 2. Response processing (_processResponse)
  // ---------------------------------------------------------------------------

  group('Response processing', () {
    for (final statusCode in [200, 201, 204, 400, 404]) {
      test('returns response as-is for status $statusCode', () async {
        when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
            .thenAnswer(
                (_) async => _mockResponse(data: 'body', statusCode: statusCode));

        final response = await client.get('/test');

        expect(response.statusCode, equals(statusCode));
        expect(response.data, equals('body'));
      });
    }

    test('throws ApiUnauthorizedException for status 401', () async {
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer(
              (_) async => _mockResponse(data: 'unauthorized', statusCode: 401));

      expect(
        () => client.get('/test'),
        throwsA(isA<ApiUnauthorizedException>()),
      );
    });

    test('throws ApiException with statusCode and body for status >= 500',
        () async {
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async =>
              _mockResponse(data: 'internal error', statusCode: 500));

      expect(
        () => client.get('/test'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 500)
              .having((e) => e.body, 'body', 'internal error'),
        ),
      );
    });

    test('throws ApiException for status 502', () async {
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer(
              (_) async => _mockResponse(data: 'bad gateway', statusCode: 502));

      expect(
        () => client.get('/test'),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 502)),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // 3. Error wrapping (_wrap)
  // ---------------------------------------------------------------------------

  group('Error wrapping', () {
    test('DioException connectionTimeout throws ApiTimeoutException', () async {
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenThrow(
              _dioException(type: DioExceptionType.connectionTimeout));

      expect(
        () => client.get('/test'),
        throwsA(isA<ApiTimeoutException>()),
      );
    });

    test('DioException receiveTimeout throws ApiTimeoutException', () async {
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenThrow(
              _dioException(type: DioExceptionType.receiveTimeout));

      expect(
        () => client.get('/test'),
        throwsA(isA<ApiTimeoutException>()),
      );
    });

    test('DioException sendTimeout throws ApiTimeoutException', () async {
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenThrow(
              _dioException(type: DioExceptionType.sendTimeout));

      expect(
        () => client.get('/test'),
        throwsA(isA<ApiTimeoutException>()),
      );
    });

    test('DioException connectionError throws ApiNetworkException', () async {
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenThrow(
              _dioException(type: DioExceptionType.connectionError));

      expect(
        () => client.get('/test'),
        throwsA(isA<ApiNetworkException>()),
      );
    });

    test('DioException wrapping an ApiException re-throws the original',
        () async {
      final originalException = ApiException(
        statusCode: 422,
        body: 'Validation failed',
        message: 'Validation error',
      );

      when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenThrow(_dioException(
        type: DioExceptionType.badResponse,
        error: originalException,
      ));

      expect(
        () => client.get('/test'),
        throwsA(same(originalException)),
      );
    });

    test('Other DioException types throw ApiNetworkException', () async {
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenThrow(
              _dioException(type: DioExceptionType.badCertificate));

      expect(
        () => client.get('/test'),
        throwsA(isA<ApiNetworkException>()),
      );
    });

    test('DioException cancel type throws ApiNetworkException', () async {
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenThrow(_dioException(type: DioExceptionType.cancel));

      expect(
        () => client.get('/test'),
        throwsA(isA<ApiNetworkException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // 4. HTTP method delegation
  // ---------------------------------------------------------------------------

  group('HTTP method delegation', () {
    group('get()', () {
      test('calls dio.get with correct path and query params', () async {
        when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
            .thenAnswer((_) async => _mockResponse(data: 'ok'));

        await client.get('/animals', query: {'page': '1'});

        verify(mockDio.get(
          '/account/$testAccountUuid/animals',
          queryParameters: {'page': '1'},
        )).called(1);
      });
    });

    group('getWithQueryString()', () {
      test('appends raw query string to path', () async {
        when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
            .thenAnswer((_) async => _mockResponse(data: 'ok'));

        await client.getWithQueryString(
          '/animals',
          queryString: 'sex=M&sex=F&page=1',
        );

        verify(mockDio.get(
          '/account/$testAccountUuid/animals?sex=M&sex=F&page=1',
        )).called(1);
      });

      test('does not append ? when queryString is empty', () async {
        when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
            .thenAnswer((_) async => _mockResponse(data: 'ok'));

        await client.getWithQueryString(
          '/animals',
          queryString: '',
        );

        verify(mockDio.get(
          '/account/$testAccountUuid/animals',
        )).called(1);
      });

      test('respects withoutAccountPrefix', () async {
        when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
            .thenAnswer((_) async => _mockResponse(data: 'ok'));

        await client.getWithQueryString(
          '/public/data',
          queryString: 'limit=10',
          withoutAccountPrefix: true,
        );

        verify(mockDio.get('/public/data?limit=10')).called(1);
      });
    });

    group('post()', () {
      test('calls dio.post with JSON content type and body', () async {
        when(mockDio.post(
          any,
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => _mockResponse(data: 'created', statusCode: 201));

        await client.post('/animals', body: {'name': 'Test'});

        final captured = verify(mockDio.post(
          '/account/$testAccountUuid/animals',
          data: {'name': 'Test'},
          queryParameters: anyNamed('queryParameters'),
          options: captureAnyNamed('options'),
        )).captured;

        final options = captured.first as Options;
        expect(options.contentType, equals('application/json'));
      });

      test('passes query parameters', () async {
        when(mockDio.post(
          any,
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => _mockResponse(data: 'ok', statusCode: 201));

        await client.post(
          '/animals',
          body: {'name': 'Test'},
          query: {'notify': 'true'},
        );

        verify(mockDio.post(
          '/account/$testAccountUuid/animals',
          data: {'name': 'Test'},
          queryParameters: {'notify': 'true'},
          options: anyNamed('options'),
        )).called(1);
      });

      test('respects withoutAccountPrefix', () async {
        when(mockDio.post(
          any,
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => _mockResponse(data: 'ok', statusCode: 200));

        await client.post('/auth/signup',
            body: {'email': 'a@b.com'}, withoutAccountPrefix: true);

        verify(mockDio.post(
          '/auth/signup',
          data: {'email': 'a@b.com'},
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).called(1);
      });
    });

    group('postWithoutAuth()', () {
      test('sets Authorization header to null', () async {
        when(mockDio.post(
          any,
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => _mockResponse(data: 'ok'));

        await client.postWithoutAuth('/auth/public', body: {'key': 'value'});

        final captured = verify(mockDio.post(
          '/account/$testAccountUuid/auth/public',
          data: {'key': 'value'},
          options: captureAnyNamed('options'),
        )).captured;

        final options = captured.first as Options;
        expect(options.contentType, equals('application/json'));
        expect(options.headers?['Authorization'], isNull);
      });

      test('respects withoutAccountPrefix', () async {
        when(mockDio.post(
          any,
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => _mockResponse(data: 'ok'));

        await client.postWithoutAuth(
          '/public/register',
          body: {'email': 'test@test.com'},
          withoutAccountPrefix: true,
        );

        verify(mockDio.post(
          '/public/register',
          data: {'email': 'test@test.com'},
          options: anyNamed('options'),
        )).called(1);
      });
    });

    group('put()', () {
      test('calls dio.put with correct path, body, and content type',
          () async {
        when(mockDio.put(
          any,
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => _mockResponse(data: 'updated'));

        await client.put('/animals/uuid-1', body: {'name': 'Updated'});

        final captured = verify(mockDio.put(
          '/account/$testAccountUuid/animals/uuid-1',
          data: {'name': 'Updated'},
          queryParameters: anyNamed('queryParameters'),
          options: captureAnyNamed('options'),
        )).captured;

        final options = captured.first as Options;
        expect(options.contentType, equals('application/json'));
      });

      test('passes query parameters', () async {
        when(mockDio.put(
          any,
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => _mockResponse(data: 'ok'));

        await client.put(
          '/animals/uuid-1',
          body: {'name': 'Updated'},
          query: {'version': '2'},
        );

        verify(mockDio.put(
          '/account/$testAccountUuid/animals/uuid-1',
          data: {'name': 'Updated'},
          queryParameters: {'version': '2'},
          options: anyNamed('options'),
        )).called(1);
      });
    });

    group('patch()', () {
      test('calls dio.patch with correct path, body, and content type',
          () async {
        when(mockDio.patch(
          any,
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => _mockResponse(data: 'patched'));

        await client.patch('/animals/uuid-1', body: {'status': 'active'});

        final captured = verify(mockDio.patch(
          '/account/$testAccountUuid/animals/uuid-1',
          data: {'status': 'active'},
          queryParameters: anyNamed('queryParameters'),
          options: captureAnyNamed('options'),
        )).captured;

        final options = captured.first as Options;
        expect(options.contentType, equals('application/json'));
      });

      test('passes query parameters', () async {
        when(mockDio.patch(
          any,
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => _mockResponse(data: 'ok'));

        await client.patch(
          '/animals/uuid-1',
          body: {'status': 'active'},
          query: {'notify': 'true'},
        );

        verify(mockDio.patch(
          '/account/$testAccountUuid/animals/uuid-1',
          data: {'status': 'active'},
          queryParameters: {'notify': 'true'},
          options: anyNamed('options'),
        )).called(1);
      });
    });

    group('delete()', () {
      test('calls dio.delete with correct path', () async {
        when(mockDio.delete(
          any,
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => _mockResponse(statusCode: 204));

        final response = await client.delete('/animals/uuid-1');

        expect(response.statusCode, equals(204));
        verify(mockDio.delete(
          '/account/$testAccountUuid/animals/uuid-1',
        )).called(1);
      });
    });

    group('uploadFile()', () {
      test('builds correct path and calls dio.post with FormData', () async {
        // Create a temporary file so MultipartFile.fromFile succeeds.
        final tempDir = Directory.systemTemp;
        final tempFile = File('${tempDir.path}/test_upload_file.txt');
        tempFile.writeAsStringSync('test content');

        when(mockDio.post(
          any,
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => _mockResponse(data: 'uploaded'));

        try {
          await client.uploadFile(
            '/documents',
            file: tempFile,
            fileFieldName: 'attachment',
            fields: {'description': 'my file'},
          );

          final captured = verify(mockDio.post(
            '/account/$testAccountUuid/documents',
            data: captureAnyNamed('data'),
            options: captureAnyNamed('options'),
          )).captured;

          final formData = captured[0] as FormData;
          // FormData should contain the file field and extra fields.
          expect(formData.fields.any((f) => f.key == 'description'), isTrue);
          expect(formData.files.any((f) => f.key == 'attachment'), isTrue);

          final options = captured[1] as Options;
          expect(options.sendTimeout, equals(const Duration(seconds: 120)));
          expect(options.receiveTimeout, equals(const Duration(seconds: 120)));
        } finally {
          tempFile.deleteSync();
        }
      });
    });
  });
}
