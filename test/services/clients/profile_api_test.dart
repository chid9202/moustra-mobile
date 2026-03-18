import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/profile_dto.dart';

import 'profile_api_test.mocks.dart';

class TestableProfileApi {
  final DioApiClient apiClient;

  TestableProfileApi(this.apiClient);

  Future<ProfileResponseDto> getProfile(ProfileRequestDto body) async {
    final res = await apiClient.post(
      'auth/callback',
      body: body,
      withoutAccountPrefix: true,
    );
    if (res.statusCode != 200) {
      throw Exception(
        'Login failed. The server returned an error (${res.statusCode}). Please try again.',
      );
    }
    final Map<String, dynamic> data = res.data as Map<String, dynamic>;
    return ProfileResponseDto.fromJson(data);
  }
}

Map<String, dynamic> _sampleProfileJson() => {
      'accountUuid': 'acc-uuid-1',
      'firstName': 'John',
      'lastName': 'Doe',
      'email': 'john@example.com',
      'labName': 'Test Lab',
      'labUuid': 'lab-uuid-1',
      'onboarded': true,
      'onboardedDate': '2025-01-01T00:00:00Z',
      'position': 'PI',
      'role': 'admin',
      'plan': 'pro',
    };

@GenerateMocks([DioApiClient])
void main() {
  group('ProfileApi Tests', () {
    late MockDioApiClient mockApiClient;
    late TestableProfileApi api;

    setUp(() {
      mockApiClient = MockDioApiClient();
      api = TestableProfileApi(mockApiClient);
    });

    group('getProfile', () {
      test('should return ProfileResponseDto on 200', () async {
        when(mockApiClient.post(any,
                body: anyNamed('body'),
                query: anyNamed('query'),
                withoutAccountPrefix:
                    anyNamed('withoutAccountPrefix')))
            .thenAnswer((_) async => Response(
                  data: _sampleProfileJson(),
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        final request = ProfileRequestDto(
          email: 'john@example.com',
          firstName: 'John',
          lastName: 'Doe',
        );

        final result = await api.getProfile(request);

        expect(result.accountUuid, 'acc-uuid-1');
        expect(result.firstName, 'John');
        expect(result.labName, 'Test Lab');
        expect(result.role, 'admin');
        expect(result.onboarded, true);
      });

      test('should throw on non-200 status', () async {
        when(mockApiClient.post(any,
                body: anyNamed('body'),
                query: anyNamed('query'),
                withoutAccountPrefix:
                    anyNamed('withoutAccountPrefix')))
            .thenAnswer((_) async => Response(
                  data: 'Unauthorized',
                  statusCode: 401,
                  requestOptions: RequestOptions(),
                ));

        final request = ProfileRequestDto(
          email: 'test@example.com',
          firstName: 'Test',
          lastName: 'User',
        );

        expect(() => api.getProfile(request), throwsA(isA<Exception>()));
      });

      test('should send correct path with withoutAccountPrefix', () async {
        when(mockApiClient.post(any,
                body: anyNamed('body'),
                query: anyNamed('query'),
                withoutAccountPrefix:
                    anyNamed('withoutAccountPrefix')))
            .thenAnswer((_) async => Response(
                  data: _sampleProfileJson(),
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        final request = ProfileRequestDto(
          email: 'john@example.com',
          firstName: 'John',
          lastName: 'Doe',
        );

        await api.getProfile(request);

        verify(mockApiClient.post(
          'auth/callback',
          body: anyNamed('body'),
          query: anyNamed('query'),
          withoutAccountPrefix: true,
        )).called(1);
      });
    });
  });
}
