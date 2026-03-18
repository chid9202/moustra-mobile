import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/services/dtos/paginated_response_dto.dart';
import 'package:moustra/services/dtos/rack_dto.dart';

import 'animal_api_test.mocks.dart';

// Testable version of AnimalApi that accepts a client
class TestableAnimalApi {
  final DioApiClient apiClient;
  static const String basePath = '/animal';

  TestableAnimalApi(this.apiClient);

  Future<PaginatedResponseDto<AnimalDto>> getAnimalsPage({
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
    final Map<String, dynamic> data = res.data;
    return PaginatedResponseDto<AnimalDto>.fromJson(
      data,
      (j) => AnimalDto.fromJson(j),
    );
  }

  Future<AnimalDto> getAnimal(String animalUuid) async {
    final res = await apiClient.get('$basePath/$animalUuid');
    return AnimalDto.fromJson(res.data);
  }

  Future<AnimalDto> putAnimal(String animalUuid, AnimalDto payload) async {
    final res = await apiClient.put('$basePath/$animalUuid', body: payload);

    if (res.statusCode != 200) {
      throw Exception('Failed to update animal ${res.data}');
    }
    return AnimalDto.fromJson(res.data);
  }

  Future<List<AnimalDto>> postAnimal(PostAnimalDto payload) async {
    final res = await apiClient.post(basePath, body: payload);
    if (res.statusCode != 201) {
      throw Exception('Failed to create animal ${res.data}');
    }

    final animalsData = res.data['animals'] as List<dynamic>;
    return animalsData.map((e) => AnimalDto.fromDynamicJson(e)).toList();
  }

  Future endAnimals(List<String> animalUuids) async {
    final res = await apiClient.put(
      '$basePath/end',
      query: {'animals': animalUuids.join(',')},
      body: {
        'endCage': false,
        'endComment': '',
        'endDate': DateTime.now().toIso8601String().split('T')[0],
      },
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to end animals ${res.data}');
    }
  }

  Future<RackDto> moveAnimal(String animalUuid, String cageUuid) async {
    final res = await apiClient.post(
      '$basePath/$animalUuid/move',
      body: {'animal': animalUuid, 'cage': cageUuid},
    );
    return RackDto.fromJson(res.data);
  }

  Future<void> patchAnimals(List<Map<String, dynamic>> updates) async {
    final res = await apiClient.patch(basePath, body: updates);
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Failed to patch animals: ${res.data}');
    }
  }
}

@GenerateMocks([DioApiClient])
void main() {
  group('AnimalApi Tests', () {
    late MockDioApiClient mockApiClient;
    late TestableAnimalApi animalApi;

    setUp(() {
      mockApiClient = MockDioApiClient();
      animalApi = TestableAnimalApi(mockApiClient);

      // Replace the global apiClient with our mock
      // Note: This is a simplified approach for testing
    });

    group('getAnimalsPage', () {
      test('should return paginated animals response', () async {
        // Arrange
        final mockResponse = Response(
          data: {
            'results': [
              {
                'eid': 1,
                'animalId': 1,
                'animalUuid': 'uuid-1',
                'physicalTag': 'A001',
                'dateOfBirth': '2023-01-01',
                'sex': 'male',
              },
              {
                'eid': 2,
                'animalId': 2,
                'animalUuid': 'uuid-2',
                'physicalTag': 'A002',
                'dateOfBirth': '2023-01-02',
                'sex': 'female',
              },
            ],
            'count': 2,
            'next': null,
            'previous': null,
          },
          statusCode: 200,
          requestOptions: RequestOptions(),
        );

        when(
          mockApiClient.get(any, query: anyNamed('query')),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await animalApi.getAnimalsPage(page: 1, pageSize: 25);

        // Assert
        expect(result.results.length, equals(2));
        expect(result.count, equals(2));
        expect(result.results.first.animalId, equals(1));
        expect(result.results.first.physicalTag, equals('A001'));
        expect(result.results.last.animalId, equals(2));
        expect(result.results.last.physicalTag, equals('A002'));
      });

      test('should include query parameters in request', () async {
        // Arrange
        final mockResponse = Response(
          data: {
            'results': [],
            'count': 0,
            'next': null,
            'previous': null,
          },
          statusCode: 200,
          requestOptions: RequestOptions(),
        );

        when(
          mockApiClient.get(any, query: anyNamed('query')),
        ).thenAnswer((_) async => mockResponse);

        // Act
        await animalApi.getAnimalsPage(
          page: 2,
          pageSize: 10,
          query: {'strain': 'C57BL/6'},
        );

        // Assert
        verify(
          mockApiClient.get(
            any,
            query: argThat(
              isA<Map<String, String>>()
                  .having((q) => q['page'], 'page', '2')
                  .having((q) => q['page_size'], 'page_size', '10')
                  .having((q) => q['strain'], 'strain', 'C57BL/6'),
              named: 'query',
            ),
          ),
        ).called(1);
      });
    });

    group('getAnimal', () {
      test('should return single animal', () async {
        // Arrange
        const animalUuid = 'test-uuid';
        final mockResponse = Response(
          data: {
            'eid': 1,
            'animalId': 1,
            'animalUuid': animalUuid,
            'physicalTag': 'A001',
            'dateOfBirth': '2023-01-01',
            'sex': 'male',
          },
          statusCode: 200,
          requestOptions: RequestOptions(),
        );

        when(mockApiClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act
        final result = await animalApi.getAnimal(animalUuid);

        // Assert
        expect(result.animalUuid, equals(animalUuid));
        expect(result.physicalTag, equals('A001'));
        verify(mockApiClient.get('/animal/$animalUuid')).called(1);
      });
    });

    group('putAnimal', () {
      test('should update animal and return updated data', () async {
        // Arrange
        const animalUuid = 'test-uuid';
        final animalDto = AnimalDto(
          eid: 1,
          animalId: 1,
          animalUuid: animalUuid,
          physicalTag: 'A001',
          dateOfBirth: DateTime(2023, 1, 1),
          sex: 'male',
        );

        final mockResponse = Response(
          data: {
            'eid': 1,
            'animalId': 1,
            'animalUuid': animalUuid,
            'physicalTag': 'A001-UPDATED',
            'dateOfBirth': '2023-01-01',
            'sex': 'male',
          },
          statusCode: 200,
          requestOptions: RequestOptions(),
        );

        when(
          mockApiClient.put(any, body: anyNamed('body')),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await animalApi.putAnimal(animalUuid, animalDto);

        // Assert
        expect(result.animalUuid, equals(animalUuid));
        verify(
          mockApiClient.put('/animal/$animalUuid', body: animalDto),
        ).called(1);
      });

      test('should throw exception on non-200 status', () async {
        // Arrange
        const animalUuid = 'test-uuid';
        final animalDto = AnimalDto(
          eid: 1,
          animalId: 1,
          animalUuid: animalUuid,
          physicalTag: 'A001',
          dateOfBirth: DateTime(2023, 1, 1),
          sex: 'male',
        );

        final mockResponse = Response(data: 'Bad Request', statusCode: 400, requestOptions: RequestOptions());

        when(
          mockApiClient.put(any, body: anyNamed('body')),
        ).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => animalApi.putAnimal(animalUuid, animalDto),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('postAnimal', () {
      test('should create animal and return list of created animals', () async {
        // Arrange
        final postAnimalDto = PostAnimalDto(
          animals: [
            PostAnimalData(
              idx: '0',
              dateOfBirth: DateTime(2023, 1, 1),
              genotypes: [],
              physicalTag: 'A001',
            ),
          ],
        );

        final mockResponse = Response(
          data: {
            'animals': [
              {
                'eid': 1,
                'animalId': 1,
                'animalUuid': 'uuid-1',
                'physicalTag': 'A001',
                'dateOfBirth': '2023-01-01',
                'sex': 'male',
              },
            ],
          },
          statusCode: 201,
          requestOptions: RequestOptions(),
        );

        when(
          mockApiClient.post(any, body: anyNamed('body')),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await animalApi.postAnimal(postAnimalDto);

        // Assert
        expect(result.length, equals(1));
        expect(result.first.physicalTag, equals('A001'));
        verify(mockApiClient.post('/animal', body: postAnimalDto)).called(1);
      });

      test('should throw exception on non-201 status', () async {
        // Arrange
        final postAnimalDto = PostAnimalDto(
          animals: [
            PostAnimalData(
              idx: '0',
              dateOfBirth: DateTime(2023, 1, 1),
              genotypes: [],
              physicalTag: 'A001',
            ),
          ],
        );

        final mockResponse = Response(data: 'Bad Request', statusCode: 400, requestOptions: RequestOptions());

        when(
          mockApiClient.post(any, body: anyNamed('body')),
        ).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => animalApi.postAnimal(postAnimalDto),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('endAnimals', () {
      test('should end animals successfully', () async {
        // Arrange
        final animalUuids = ['uuid-1', 'uuid-2'];
        final mockResponse = Response(data: '', statusCode: 200, requestOptions: RequestOptions());

        when(
          mockApiClient.put(
            any,
            query: anyNamed('query'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act
        await animalApi.endAnimals(animalUuids);

        // Assert
        verify(
          mockApiClient.put(
            '/animal/end',
            query: argThat(
              isA<Map<String, String>>().having(
                (q) => q['animals'],
                'animals',
                'uuid-1,uuid-2',
              ),
              named: 'query',
            ),
            body: anyNamed('body'),
          ),
        ).called(1);
      });

      test('should throw exception on non-200 status', () async {
        // Arrange
        final animalUuids = ['uuid-1'];
        final mockResponse = Response(data: 'Bad Request', statusCode: 400, requestOptions: RequestOptions());

        when(
          mockApiClient.put(
            any,
            query: anyNamed('query'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => animalApi.endAnimals(animalUuids),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('moveAnimal', () {
      test('should move animal to new cage and return rack data', () async {
        // Arrange
        const animalUuid = 'animal-uuid';
        const cageUuid = 'cage-uuid';

        final mockResponse = Response(
          data: {
            'rackId': 1,
            'rackUuid': 'rack-uuid',
            'rackName': 'Rack A',
            'cages': [],
          },
          statusCode: 200,
          requestOptions: RequestOptions(),
        );

        when(
          mockApiClient.post(any, body: anyNamed('body')),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await animalApi.moveAnimal(animalUuid, cageUuid);

        // Assert
        expect(result.rackUuid, equals('rack-uuid'));
        expect(result.rackName, equals('Rack A'));
        verify(
          mockApiClient.post(
            '/animal/$animalUuid/move',
            body: {'animal': animalUuid, 'cage': cageUuid},
          ),
        ).called(1);
      });
    });

    group('patchAnimals', () {
      test('should patch animals successfully with 200 status', () async {
        // Arrange
        final updates = [
          {
            'animalUuid': 'uuid-1',
            'strain': {
              'strainId': 123,
              'strainUuid': 'strain-uuid',
              'strainName': 'C57BL/6',
              'weanAge': 21,
              'genotypes': [],
            },
          },
          {
            'animalUuid': 'uuid-2',
            'strain': {
              'strainId': 123,
              'strainUuid': 'strain-uuid',
              'strainName': 'C57BL/6',
              'weanAge': 21,
              'genotypes': [],
            },
          },
        ];

        final mockResponse = Response(data: '', statusCode: 200, requestOptions: RequestOptions());

        when(
          mockApiClient.patch(any, body: anyNamed('body')),
        ).thenAnswer((_) async => mockResponse);

        // Act & Assert - should not throw
        await animalApi.patchAnimals(updates);

        verify(
          mockApiClient.patch('/animal', body: updates),
        ).called(1);
      });

      test('should patch animals successfully with 204 status', () async {
        // Arrange
        final updates = [
          {
            'animalUuid': 'uuid-1',
            'strain': {
              'strainId': 123,
              'strainUuid': 'strain-uuid',
              'strainName': 'C57BL/6',
              'weanAge': 21,
              'genotypes': [],
            },
          },
        ];

        final mockResponse = Response(data: '', statusCode: 204, requestOptions: RequestOptions());

        when(
          mockApiClient.patch(any, body: anyNamed('body')),
        ).thenAnswer((_) async => mockResponse);

        // Act & Assert - should not throw
        await animalApi.patchAnimals(updates);

        verify(
          mockApiClient.patch('/animal', body: updates),
        ).called(1);
      });

      test('should throw exception on non-200/204 status', () async {
        // Arrange
        final updates = [
          {'animalUuid': 'uuid-1', 'strain': {}},
        ];

        final mockResponse = Response(data: 'Bad Request', statusCode: 400, requestOptions: RequestOptions());

        when(
          mockApiClient.patch(any, body: anyNamed('body')),
        ).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => animalApi.patchAnimals(updates),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
