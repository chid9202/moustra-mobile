import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/paginated_response_dto.dart';
import 'package:moustra/services/dtos/strain_dto.dart';

import 'strain_api_test.mocks.dart';

class TestableStrainApi {
  final DioApiClient apiClient;
  static const String basePath = '/strain';

  TestableStrainApi(this.apiClient);

  Future<PaginatedResponseDto<StrainDto>> getStrainsPage({
    int page = 1,
    int pageSize = 25,
    Map<String, String>? query,
  }) async {
    final mergedQuery = <String, String>{
      'page': page.toString(),
      'page_size': pageSize.toString(),
      if (query != null) ...query,
    };
    final res = await apiClient.get(basePath, query: mergedQuery);
    final Map<String, dynamic> data = res.data as Map<String, dynamic>;
    return PaginatedResponseDto<StrainDto>.fromJson(
      data,
      (j) => StrainDto.fromJson(j),
    );
  }

  Future<PaginatedResponseDto<StrainDto>> getStrainsPageWithParams({
    required String queryString,
  }) async {
    final res = await apiClient.getWithQueryString(
      basePath,
      queryString: queryString,
    );
    final Map<String, dynamic> data = res.data as Map<String, dynamic>;
    return PaginatedResponseDto<StrainDto>.fromJson(
      data,
      (j) => StrainDto.fromJson(j),
    );
  }

  Future<StrainDto> getStrain(String uuid) async {
    final res = await apiClient.get('$basePath/$uuid');
    if (res.statusCode != 200) {
      throw Exception('Failed to get strain ${res.data}');
    }
    return StrainDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<StrainDto> createStrain(Map<String, dynamic> payload) async {
    final res = await apiClient.post(basePath, body: payload);
    return StrainDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<StrainDto> putStrain(String uuid, Map<String, dynamic> payload) async {
    final res = await apiClient.put('$basePath/$uuid', body: payload);
    return StrainDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteStrain(String id) async {
    await apiClient.delete('$basePath/$id');
  }

  Future<void> mergeStrains(List<String> strainUuids) async {
    await apiClient.post(
      '$basePath/merge',
      body: <String, dynamic>{'strains': strainUuids},
    );
  }
}

Map<String, dynamic> _sampleStrainJson({
  String uuid = 'strain-uuid-1',
  String name = 'C57BL/6',
}) =>
    {
      'strainId': 1,
      'strainUuid': uuid,
      'strainName': name,
      'owner': {
        'accountId': 1,
        'accountUuid': 'owner-uuid',
        'firstName': 'John',
        'lastName': 'Doe',
      },
      'weanAge': 21,
      'tagPrefix': 'C57',
      'comment': null,
      'createdDate': '2025-01-01T00:00:00Z',
      'genotypes': [],
      'color': '#FF0000',
      'numberOfAnimals': 10,
      'backgrounds': [],
      'isActive': true,
    };

@GenerateMocks([DioApiClient])
void main() {
  group('StrainApi Tests', () {
    late MockDioApiClient mockApiClient;
    late TestableStrainApi api;

    setUp(() {
      mockApiClient = MockDioApiClient();
      api = TestableStrainApi(mockApiClient);
    });

    group('getStrainsPage', () {
      test('should return paginated strains', () async {
        when(mockApiClient.get(any, query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: {
                    'results': [
                      _sampleStrainJson(uuid: 'u1', name: 'Strain A'),
                      _sampleStrainJson(uuid: 'u2', name: 'Strain B'),
                    ],
                    'count': 2,
                    'next': null,
                    'previous': null,
                  },
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.getStrainsPage();

        expect(result.results.length, 2);
        expect(result.count, 2);
        expect(result.results.first.strainName, 'Strain A');
      });

      test('should pass correct query params', () async {
        when(mockApiClient.get(any, query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: {
                    'results': [],
                    'count': 0,
                    'next': null,
                    'previous': null,
                  },
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        await api.getStrainsPage(page: 3, pageSize: 10);

        verify(mockApiClient.get('/strain', query: {
          'page': '3',
          'page_size': '10',
        })).called(1);
      });
    });

    group('getStrainsPageWithParams', () {
      test('should call getWithQueryString', () async {
        when(mockApiClient.getWithQueryString(any, queryString: anyNamed('queryString')))
            .thenAnswer((_) async => Response(
                  data: {
                    'results': [_sampleStrainJson()],
                    'count': 1,
                    'next': null,
                    'previous': null,
                  },
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.getStrainsPageWithParams(
          queryString: 'page=1&page_size=25',
        );

        expect(result.results.length, 1);
        verify(mockApiClient.getWithQueryString(
          '/strain',
          queryString: 'page=1&page_size=25',
        )).called(1);
      });
    });

    group('getStrain', () {
      test('should return a single strain', () async {
        when(mockApiClient.get(any, query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: _sampleStrainJson(),
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.getStrain('strain-uuid-1');

        expect(result.strainUuid, 'strain-uuid-1');
        expect(result.strainName, 'C57BL/6');
        verify(mockApiClient.get('/strain/strain-uuid-1',
                query: anyNamed('query')))
            .called(1);
      });

      test('should throw on non-200 status', () async {
        when(mockApiClient.get(any, query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: 'Not found',
                  statusCode: 404,
                  requestOptions: RequestOptions(),
                ));

        expect(
          () => api.getStrain('bad-uuid'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('createStrain', () {
      test('should return created strain', () async {
        when(mockApiClient.post(any, body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: _sampleStrainJson(),
                  statusCode: 201,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.createStrain({'strainName': 'New Strain'});

        expect(result, isA<StrainDto>());
        verify(mockApiClient.post('/strain',
                body: anyNamed('body'), query: anyNamed('query')))
            .called(1);
      });
    });

    group('deleteStrain', () {
      test('should call delete with correct path', () async {
        when(mockApiClient.delete(any)).thenAnswer((_) async => Response(
              data: null,
              statusCode: 204,
              requestOptions: RequestOptions(),
            ));

        await api.deleteStrain('strain-uuid-1');

        verify(mockApiClient.delete('/strain/strain-uuid-1')).called(1);
      });
    });

    group('mergeStrains', () {
      test('should post merge request', () async {
        when(mockApiClient.post(any, body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: null,
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        await api.mergeStrains(['uuid-1', 'uuid-2']);

        verify(mockApiClient.post(
          '/strain/merge',
          body: {'strains': ['uuid-1', 'uuid-2']},
          query: anyNamed('query'),
        )).called(1);
      });
    });
  });
}
