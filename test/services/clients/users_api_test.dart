import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/clients/users_api.dart';
import 'package:moustra/services/dtos/user_detail_dto.dart';

import 'users_api_test.mocks.dart';

Map<String, dynamic> _sampleUserListJson({
  String accountUuid = 'acc-uuid-1',
  String email = 'user@test.com',
}) => {
  'accountId': 1,
  'accountUuid': accountUuid,
  'user': {
    'email': email,
    'firstName': 'John',
    'lastName': 'Doe',
    'isActive': true,
  },
  'status': 'active',
  'role': 'admin',
  'isActive': true,
  'position': 'PI',
  'accountSetting': {
    'enableDailyReport': false,
    'onboardingTour': false,
    'animalCreationTour': false,
  },
  'onboarded': true,
  'lab': {'labId': 1, 'labUuid': 'lab-uuid-1', 'labName': 'Test Lab'},
};

Map<String, dynamic> _sampleUserDetailJson({
  String accountUuid = 'acc-uuid-1',
}) => {
  'accountId': 1,
  'accountUuid': accountUuid,
  'user': {
    'email': 'user@test.com',
    'firstName': 'John',
    'lastName': 'Doe',
    'isActive': true,
  },
  'status': 'active',
  'role': 'admin',
  'isActive': true,
  'position': 'PI',
  'accountSetting': {
    'enableDailyReport': false,
    'onboardingTour': false,
    'animalCreationTour': false,
  },
  'onboarded': true,
  'lab': {'labId': 1, 'labUuid': 'lab-uuid-1', 'labName': 'Test Lab'},
};

@GenerateMocks([DioApiClient])
void main() {
  group('UsersApi Tests', () {
    late MockDioApiClient mockApiClient;
    late UsersApi api;

    setUp(() {
      mockApiClient = MockDioApiClient();
      api = UsersApi(mockApiClient);
    });

    group('getUsers', () {
      test('should return list of users on 200', () async {
        when(mockApiClient.get(any, query: anyNamed('query'))).thenAnswer(
          (_) async => Response(
            data: [
              _sampleUserListJson(accountUuid: 'u1'),
              _sampleUserListJson(accountUuid: 'u2'),
            ],
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );

        final result = await api.getUsers();

        expect(result.length, 2);
        expect(result.first.accountUuid, 'u1');
        expect(result.first.user.firstName, 'John');
        verify(
          mockApiClient.get('/lab/user', query: anyNamed('query')),
        ).called(1);
      });

      test('should throw on non-200 status', () async {
        when(mockApiClient.get(any, query: anyNamed('query'))).thenAnswer(
          (_) async => Response(
            data: 'Error',
            statusCode: 500,
            requestOptions: RequestOptions(),
          ),
        );

        expect(() => api.getUsers(), throwsA(isA<Exception>()));
      });
    });

    group('getUser', () {
      test('should return user detail on 200', () async {
        when(mockApiClient.get(any, query: anyNamed('query'))).thenAnswer(
          (_) async => Response(
            data: _sampleUserDetailJson(),
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );

        final result = await api.getUser('acc-uuid-1');

        expect(result.accountUuid, 'acc-uuid-1');
        expect(result.role, 'admin');
        verify(
          mockApiClient.get('/lab/user/acc-uuid-1', query: anyNamed('query')),
        ).called(1);
      });

      test('should throw on non-200 status', () async {
        when(mockApiClient.get(any, query: anyNamed('query'))).thenAnswer(
          (_) async => Response(
            data: 'Not found',
            statusCode: 404,
            requestOptions: RequestOptions(),
          ),
        );

        expect(() => api.getUser('bad-uuid'), throwsA(isA<Exception>()));
      });
    });

    group('updateUser', () {
      test('should complete on 200', () async {
        when(
          mockApiClient.put(
            any,
            body: anyNamed('body'),
            query: anyNamed('query'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: null,
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );

        final userData = PutUserDetailDto(role: 'member', isActive: true);
        await api.updateUser('acc-uuid-1', userData);

        verify(
          mockApiClient.put(
            '/lab/user/acc-uuid-1',
            body: anyNamed('body'),
            query: anyNamed('query'),
          ),
        ).called(1);
      });

      test('should throw on non-200 status', () async {
        when(
          mockApiClient.put(
            any,
            body: anyNamed('body'),
            query: anyNamed('query'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: 'Error',
            statusCode: 400,
            requestOptions: RequestOptions(),
          ),
        );

        final userData = PutUserDetailDto(role: 'member', isActive: true);
        expect(
          () => api.updateUser('acc-uuid-1', userData),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('createUser', () {
      test('should complete on 201', () async {
        when(
          mockApiClient.post(
            any,
            body: anyNamed('body'),
            query: anyNamed('query'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: null,
            statusCode: 201,
            requestOptions: RequestOptions(),
          ),
        );

        final userData = PostUserDetailDto(
          accountUuid: 'new-uuid',
          email: 'new@test.com',
          firstName: 'Jane',
          lastName: 'Doe',
          role: 'member',
          isActive: true,
          lab: 'lab-uuid-1',
        );
        await api.createUser('new-uuid', userData);

        verify(
          mockApiClient.post(
            '/lab/user',
            body: anyNamed('body'),
            query: anyNamed('query'),
          ),
        ).called(1);
      });

      test('should throw on non-201 status', () async {
        when(
          mockApiClient.post(
            any,
            body: anyNamed('body'),
            query: anyNamed('query'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: 'Error',
            statusCode: 400,
            requestOptions: RequestOptions(),
          ),
        );

        final userData = PostUserDetailDto(
          accountUuid: 'uuid',
          email: 'e@e.com',
          firstName: 'A',
          lastName: 'B',
          role: 'member',
          isActive: true,
          lab: 'lab',
        );
        expect(
          () => api.createUser('uuid', userData),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
