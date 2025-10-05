import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/services/dtos/mating_dto.dart';
import 'package:moustra/services/dtos/paginated_response_dto.dart';
import 'package:moustra/services/dtos/post_mating_dto.dart';
import 'package:moustra/services/dtos/put_mating_dto.dart';
import 'package:moustra/services/dtos/stores/account_store_dto.dart';
import 'package:moustra/services/dtos/stores/cage_store_dto.dart';
import 'package:moustra/services/dtos/stores/strain_store_dto.dart';
import 'package:moustra/services/dtos/account_dto.dart';

import 'mating_api_test.mocks.dart';

// Testable version of MatingApi that accepts a client
class TestableMatingApi {
  final ApiClient apiClient;
  static const String basePath = '/mating';

  TestableMatingApi(this.apiClient);

  Future<PaginatedResponseDto<MatingDto>> getMatingsPage({
    int page = 1,
    int pageSize = 25,
    Map<String, String>? query,
  }) async {
    final mergedQuery = {
      'page': page.toString(),
      'page_size': pageSize.toString(),
      if (query != null) ...query,
    };
    final res = await apiClient.get(basePath, query: mergedQuery);
    final Map<String, dynamic> data = jsonDecode(res.body);
    return PaginatedResponseDto<MatingDto>.fromJson(
      data,
      (j) => MatingDto.fromJson(j),
    );
  }

  Future<MatingDto> getMating(String matingUuid) async {
    final res = await apiClient.get('$basePath/$matingUuid');
    return MatingDto.fromJson(jsonDecode(res.body));
  }

  Future<MatingDto> createMating(PostMatingDto payload) async {
    final res = await apiClient.post(basePath, body: payload);
    if (res.statusCode != 201) {
      throw Exception('Failed to create mating ${res.body}');
    }
    return MatingDto.fromJson(jsonDecode(res.body));
  }

  Future<MatingDto> putMating(String matingUuid, PutMatingDto payload) async {
    final res = await apiClient.put('$basePath/$matingUuid', body: payload);
    if (res.statusCode != 200) {
      throw Exception('Failed to update mating ${res.body}');
    }
    return MatingDto.fromJson(jsonDecode(res.body));
  }
}

@GenerateMocks([ApiClient])
void main() {
  group('MatingApi Tests', () {
    late MockApiClient mockApiClient;
    late TestableMatingApi matingApi;

    setUp(() {
      mockApiClient = MockApiClient();
      matingApi = TestableMatingApi(mockApiClient);
    });

    group('getMatingsPage', () {
      test('should return paginated matings response', () async {
        // Arrange
        final mockResponse = http.Response(
          jsonEncode({
            'results': [
              {
                'matingId': 1,
                'matingUuid': 'mating-uuid-1',
                'matingTag': 'M001',
                'animals': [
                  {
                    'animalId': 1,
                    'animalUuid': 'animal-uuid-1',
                    'physicalTag': 'A001',
                  },
                  {
                    'animalId': 2,
                    'animalUuid': 'animal-uuid-2',
                    'physicalTag': 'A002',
                  },
                ],
              },
            ],
            'count': 1,
            'next': null,
            'previous': null,
          }),
          200,
        );

        when(
          mockApiClient.get(any, query: anyNamed('query')),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await matingApi.getMatingsPage(page: 1, pageSize: 25);

        // Assert
        expect(result.results.length, 1);
        expect(result.count, 1);
        expect(result.results.first.matingTag, 'M001');
        verify(mockApiClient.get(any, query: anyNamed('query'))).called(1);
      });

      test('should include query parameters in request', () async {
        // Arrange
        final mockResponse = http.Response(
          jsonEncode({
            'results': [],
            'count': 0,
            'next': null,
            'previous': null,
          }),
          200,
        );

        when(
          mockApiClient.get(any, query: anyNamed('query')),
        ).thenAnswer((_) async => mockResponse);

        // Act
        await matingApi.getMatingsPage(
          page: 2,
          pageSize: 10,
          query: {'status': 'active'},
        );

        // Assert
        verify(
          mockApiClient.get(
            any,
            query: argThat(
              allOf([
                containsPair('page', '2'),
                containsPair('page_size', '10'),
                containsPair('status', 'active'),
              ]),
              named: 'query',
            ),
          ),
        ).called(1);
      });
    });

    group('getMating', () {
      test('should return single mating', () async {
        // Arrange
        const matingUuid = 'test-mating-uuid';
        final mockResponse = http.Response(
          jsonEncode({
            'matingId': 1,
            'matingUuid': matingUuid,
            'matingTag': 'M001',
            'animals': [
              {
                'animalId': 1,
                'animalUuid': 'animal-uuid-1',
                'physicalTag': 'A001',
              },
            ],
          }),
          200,
        );

        when(mockApiClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act
        final result = await matingApi.getMating(matingUuid);

        // Assert
        expect(result.matingUuid, matingUuid);
        expect(result.matingTag, 'M001');
        verify(mockApiClient.get('/mating/$matingUuid')).called(1);
      });
    });

    group('createMating', () {
      test('should create mating and return created data', () async {
        // Arrange
        final postMatingDto = PostMatingDto(
          matingTag: 'M001',
          maleAnimal: 'animal-uuid-1',
          femaleAnimals: ['animal-uuid-2'],
          setUpDate: DateTime(2023, 1, 1),
          owner: AccountStoreDto(
            accountId: 1,
            accountUuid: 'account-uuid',
            user: UserDto(
              firstName: 'Test',
              lastName: 'User',
              email: 'test@example.com',
            ),
          ),
        );

        final mockResponse = http.Response(
          jsonEncode({
            'matingId': 1,
            'matingUuid': 'new-mating-uuid',
            'matingTag': 'M001',
            'animals': [
              {
                'animalId': 1,
                'animalUuid': 'animal-uuid-1',
                'physicalTag': 'A001',
              },
              {
                'animalId': 2,
                'animalUuid': 'animal-uuid-2',
                'physicalTag': 'A002',
              },
            ],
          }),
          201,
        );

        when(
          mockApiClient.post(any, body: anyNamed('body')),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await matingApi.createMating(postMatingDto);

        // Assert
        expect(result.matingTag, 'M001');
        expect(result.animals?.length, 2);
        verify(mockApiClient.post('/mating', body: postMatingDto)).called(1);
      });

      test('should throw exception on non-201 status', () async {
        // Arrange
        final postMatingDto = PostMatingDto(
          matingTag: 'M001',
          maleAnimal: 'animal-uuid-1',
          femaleAnimals: [],
          setUpDate: DateTime(2023, 1, 1),
          owner: AccountStoreDto(
            accountId: 1,
            accountUuid: 'account-uuid',
            user: UserDto(
              firstName: 'Test',
              lastName: 'User',
              email: 'test@example.com',
            ),
          ),
        );

        final mockResponse = http.Response('Bad Request', 400);

        when(
          mockApiClient.post(any, body: anyNamed('body')),
        ).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => matingApi.createMating(postMatingDto),
          throwsA(isA<Exception>()),
        );
        verify(mockApiClient.post('/mating', body: postMatingDto)).called(1);
      });
    });

    group('putMating', () {
      test('should update mating and return updated data', () async {
        // Arrange
        const matingUuid = 'test-mating-uuid';
        final putMatingDto = PutMatingDto(
          matingId: 1,
          matingUuid: matingUuid,
          matingTag: 'M001-UPDATED',
          setUpDate: DateTime(2023, 1, 1),
          owner: AccountStoreDto(
            accountId: 1,
            accountUuid: 'account-uuid',
            user: UserDto(
              firstName: 'Test',
              lastName: 'User',
              email: 'test@example.com',
            ),
          ),
        );

        final mockResponse = http.Response(
          jsonEncode({
            'matingId': 1,
            'matingUuid': matingUuid,
            'matingTag': 'M001-UPDATED',
            'animals': [
              {
                'animalId': 1,
                'animalUuid': 'animal-uuid-1',
                'physicalTag': 'A001',
              },
            ],
          }),
          200,
        );

        when(
          mockApiClient.put(any, body: anyNamed('body')),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await matingApi.putMating(matingUuid, putMatingDto);

        // Assert
        expect(result.matingTag, 'M001-UPDATED');
        verify(
          mockApiClient.put('/mating/$matingUuid', body: putMatingDto),
        ).called(1);
      });

      test('should throw exception on non-200 status', () async {
        // Arrange
        const matingUuid = 'test-mating-uuid';
        final putMatingDto = PutMatingDto(
          matingId: 1,
          matingUuid: matingUuid,
          matingTag: 'M001',
          setUpDate: DateTime(2023, 1, 1),
          owner: AccountStoreDto(
            accountId: 1,
            accountUuid: 'account-uuid',
            user: UserDto(
              firstName: 'Test',
              lastName: 'User',
              email: 'test@example.com',
            ),
          ),
        );

        final mockResponse = http.Response('Not Found', 404);

        when(
          mockApiClient.put(any, body: anyNamed('body')),
        ).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => matingApi.putMating(matingUuid, putMatingDto),
          throwsA(isA<Exception>()),
        );
        verify(
          mockApiClient.put('/mating/$matingUuid', body: putMatingDto),
        ).called(1);
      });
    });
  });
}
