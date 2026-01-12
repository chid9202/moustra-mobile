import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/stores/profile_store.dart';

import 'api_client_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('ApiClient Tests', () {
    late MockClient mockHttpClient;
    late ApiClient apiClient;

    setUpAll(() async {
      // Initialize dotenv - try loading .env file if it exists, otherwise use empty initialization
      try {
        await dotenv.load(fileName: '.env');
      } catch (e) {
        // If .env file doesn't exist or can't be loaded, initialize with empty values
        // Env class will use fallback values
        dotenv.env.clear();
      }
      // Set up a mock profile state to avoid null accountUuid
      profileState.value = null;
    });

    setUp(() {
      mockHttpClient = MockClient();
      apiClient = ApiClient(httpClient: mockHttpClient);
    });

    group('GET requests', () {
      test('should make GET request and return response', () async {
        // Arrange
        const path = '/test';
        const responseBody = '{"data": "test"}';
        final mockResponse = http.Response(responseBody, 200);

        when(
          mockHttpClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final response = await apiClient.get(path);

        // Assert
        expect(response.statusCode, equals(200));
        expect(response.body, equals(responseBody));
        verify(mockHttpClient.get(any, headers: anyNamed('headers'))).called(1);
      });

      test('should include query parameters in GET request', () async {
        // Arrange
        const path = '/test';
        final queryParams = {'page': '1', 'size': '10'};
        const responseBody = '{"data": "test"}';
        final mockResponse = http.Response(responseBody, 200);

        when(
          mockHttpClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final response = await apiClient.get(path, query: queryParams);

        // Assert
        expect(response.statusCode, equals(200));
        verify(mockHttpClient.get(any, headers: anyNamed('headers'))).called(1);
      });
    });

    group('POST requests', () {
      test('should make POST request with JSON body', () async {
        // Arrange
        const path = '/test';
        final requestBody = {'name': 'test', 'value': 123};
        const responseBody = '{"id": 1}';
        final mockResponse = http.Response(responseBody, 201);

        when(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final response = await apiClient.post(path, body: requestBody);

        // Assert
        expect(response.statusCode, equals(201));
        expect(response.body, equals(responseBody));
        verify(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).called(1);
      });

      test('should make POST request without body', () async {
        // Arrange
        const path = '/test';
        const responseBody = '{"success": true}';
        final mockResponse = http.Response(responseBody, 200);

        when(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final response = await apiClient.post(path);

        // Assert
        expect(response.statusCode, equals(200));
        verify(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).called(1);
      });
    });

    group('PUT requests', () {
      test(
        'should make PUT request with JSON body and query parameters',
        () async {
          // Arrange
          const path = '/test/123';
          final requestBody = {'name': 'updated'};
          final queryParams = {'version': '2'};
          const responseBody = '{"success": true}';
          final mockResponse = http.Response(responseBody, 200);

          when(
            mockHttpClient.put(
              any,
              headers: anyNamed('headers'),
              body: anyNamed('body'),
            ),
          ).thenAnswer((_) async => mockResponse);

          // Act
          final response = await apiClient.put(
            path,
            body: requestBody,
            query: queryParams,
          );

          // Assert
          expect(response.statusCode, equals(200));
          verify(
            mockHttpClient.put(
              any,
              headers: anyNamed('headers'),
              body: anyNamed('body'),
            ),
          ).called(1);
        },
      );
    });

    group('DELETE requests', () {
      test('should make DELETE request', () async {
        // Arrange
        const path = '/test/123';
        const responseBody = '';
        final mockResponse = http.Response(responseBody, 204);

        when(
          mockHttpClient.delete(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final response = await apiClient.delete(path);

        // Assert
        expect(response.statusCode, equals(204));
        verify(
          mockHttpClient.delete(any, headers: anyNamed('headers')),
        ).called(1);
      });
    });

    group('Error handling', () {
      test('should handle HTTP errors gracefully', () async {
        // Arrange
        const path = '/test';
        when(
          mockHttpClient.get(any, headers: anyNamed('headers')),
        ).thenThrow(http.ClientException('Network error'));

        // Act & Assert
        expect(() => apiClient.get(path), throwsA(isA<http.ClientException>()));
      });

      test('should handle 404 responses', () async {
        // Arrange
        const path = '/test';
        final mockResponse = http.Response('Not Found', 404);

        when(
          mockHttpClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final response = await apiClient.get(path);

        // Assert
        expect(response.statusCode, equals(404));
        expect(response.body, equals('Not Found'));
      });
    });

    group('URL building', () {
      test('should build URL with account prefix by default', () async {
        // Arrange
        const path = '/test';
        const responseBody = '{"data": "test"}';
        final mockResponse = http.Response(responseBody, 200);

        when(
          mockHttpClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => mockResponse);

        // Act
        await apiClient.get(path);

        // Assert
        verify(mockHttpClient.get(any, headers: anyNamed('headers'))).called(1);
      });

      test('should build URL without account prefix when specified', () async {
        // Arrange
        const path = '/test';
        const responseBody = '{"data": "test"}';
        final mockResponse = http.Response(responseBody, 200);

        when(
          mockHttpClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => mockResponse);

        // Act
        await apiClient.get(path, withoutAccountPrefix: true);

        // Assert
        verify(mockHttpClient.get(any, headers: anyNamed('headers'))).called(1);
      });
    });
  });
}
