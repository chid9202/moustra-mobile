import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/litter_dto.dart';
import 'package:moustra/services/dtos/paginated_response_dto.dart';

import 'litter_api_test.mocks.dart';

// Testable version of LitterApi that accepts a client
class TestableLitterApi {
  final DioApiClient apiClient;
  static const String basePath = '/litter';

  TestableLitterApi(this.apiClient);

  Future<PaginatedResponseDto<LitterDto>> getLittersPage({
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
    return PaginatedResponseDto<LitterDto>.fromJson(
      data,
      (j) => LitterDto.fromJson(j),
    );
  }

  Future<LitterDto> getLitter(String litterUuid) async {
    final res = await apiClient.get('$basePath/$litterUuid');
    if (res.statusCode != 200) {
      throw Exception('Failed to get litter: ${res.data}');
    }
    return LitterDto.fromJson(res.data);
  }

  Future<LitterDto> addPubsToLitter(
    String litterUuid, {
    int numberOfMale = 0,
    int numberOfFemale = 0,
    int numberOfUnknown = 0,
  }) async {
    final res = await apiClient.post(
      '$basePath/$litterUuid/pub',
      body: {
        'number_of_male': numberOfMale,
        'number_of_female': numberOfFemale,
        'number_of_unknown': numberOfUnknown,
      },
    );
    if (res.statusCode != 201) {
      throw Exception('Failed to add pups: ${res.data}');
    }
    return LitterDto.fromJson(res.data);
  }
}

Map<String, dynamic> _sampleLitterJson({
  String uuid = 'litter-uuid-1',
  String tag = 'LTR-001',
  List<Map<String, dynamic>>? animals,
}) =>
    {
      'litterUuid': uuid,
      'litterTag': tag,
      'dateOfBirth': '2025-06-01',
      'weanDate': '2025-06-22',
      'animals': animals ?? [],
      'createdDate': '2025-06-01T10:00:00Z',
    };

Map<String, dynamic> _sampleAnimalJson({
  int id = 1,
  String uuid = 'animal-uuid-1',
  String tag = 'P001',
  String sex = 'M',
}) =>
    {
      'animalId': id,
      'animalUuid': uuid,
      'physicalTag': tag,
      'sex': sex,
    };

@GenerateMocks([DioApiClient])
void main() {
  group('LitterApi Tests', () {
    late MockDioApiClient mockApiClient;
    late TestableLitterApi litterApi;

    setUp(() {
      mockApiClient = MockDioApiClient();
      litterApi = TestableLitterApi(mockApiClient);
    });

    group('getLittersPage', () {
      test('should return paginated litters response', () async {
        final mockResponse = Response(
          data: {
            'results': [
              _sampleLitterJson(uuid: 'uuid-1', tag: 'LTR-001'),
              _sampleLitterJson(uuid: 'uuid-2', tag: 'LTR-002'),
            ],
            'count': 2,
            'next': null,
            'previous': null,
          },
          statusCode: 200,
          requestOptions: RequestOptions(),
        );

        when(mockApiClient.get(any, query: anyNamed('query')))
            .thenAnswer((_) async => mockResponse);

        final result = await litterApi.getLittersPage(page: 1, pageSize: 25);

        expect(result.results.length, equals(2));
        expect(result.count, equals(2));
        expect(result.results.first.litterTag, equals('LTR-001'));
        expect(result.results.last.litterTag, equals('LTR-002'));
      });

      test('should include query parameters in request', () async {
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

        when(mockApiClient.get(any, query: anyNamed('query')))
            .thenAnswer((_) async => mockResponse);

        await litterApi.getLittersPage(
          page: 2,
          pageSize: 10,
          query: {'sort': 'litter_tag', 'order': 'desc'},
        );

        verify(mockApiClient.get(
          '/litter',
          query: {
            'page': '2',
            'page_size': '10',
            'sort': 'litter_tag',
            'order': 'desc',
          },
        )).called(1);
      });
    });

    group('getLitter', () {
      test('should return a single litter by UUID', () async {
        final mockResponse = Response(
          data: _sampleLitterJson(
            uuid: 'uuid-1',
            tag: 'LTR-001',
            animals: [
              _sampleAnimalJson(id: 1, uuid: 'a1', tag: 'P001', sex: 'M'),
              _sampleAnimalJson(id: 2, uuid: 'a2', tag: 'P002', sex: 'F'),
            ],
          ),
          statusCode: 200,
          requestOptions: RequestOptions(),
        );

        when(mockApiClient.get(any, query: anyNamed('query')))
            .thenAnswer((_) async => mockResponse);

        final result = await litterApi.getLitter('uuid-1');

        expect(result.litterUuid, equals('uuid-1'));
        expect(result.litterTag, equals('LTR-001'));
        expect(result.animals.length, equals(2));
        expect(result.animals.first.sex, equals('M'));
        expect(result.animals.last.sex, equals('F'));

        verify(mockApiClient.get('/litter/uuid-1', query: anyNamed('query')))
            .called(1);
      });

      test('should throw on non-200 status', () async {
        when(mockApiClient.get(any, query: anyNamed('query')))
            .thenAnswer((_) async => Response(data: 'Not found', statusCode: 404, requestOptions: RequestOptions()));

        expect(
          () => litterApi.getLitter('bad-uuid'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('addPubsToLitter', () {
      test('should post pup counts and return updated litter', () async {
        final mockResponse = Response(
          data: _sampleLitterJson(
            uuid: 'uuid-1',
            animals: [
              _sampleAnimalJson(id: 1, uuid: 'a1', sex: 'M'),
              _sampleAnimalJson(id: 2, uuid: 'a2', sex: 'F'),
              _sampleAnimalJson(id: 3, uuid: 'a3', sex: 'F'),
            ],
          ),
          statusCode: 201,
          requestOptions: RequestOptions(),
        );

        when(mockApiClient.post(any, body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => mockResponse);

        final result = await litterApi.addPubsToLitter(
          'uuid-1',
          numberOfMale: 1,
          numberOfFemale: 2,
        );

        expect(result.animals.length, equals(3));

        verify(mockApiClient.post(
          '/litter/uuid-1/pub',
          body: {
            'number_of_male': 1,
            'number_of_female': 2,
            'number_of_unknown': 0,
          },
          query: anyNamed('query'),
        )).called(1);
      });

      test('should default all counts to zero', () async {
        final mockResponse = Response(
          data: _sampleLitterJson(uuid: 'uuid-1'),
          statusCode: 201,
          requestOptions: RequestOptions(),
        );

        when(mockApiClient.post(any, body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => mockResponse);

        await litterApi.addPubsToLitter('uuid-1');

        verify(mockApiClient.post(
          '/litter/uuid-1/pub',
          body: {
            'number_of_male': 0,
            'number_of_female': 0,
            'number_of_unknown': 0,
          },
          query: anyNamed('query'),
        )).called(1);
      });

      test('should throw on non-201 status', () async {
        when(mockApiClient.post(any, body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(data: 'Bad request', statusCode: 400, requestOptions: RequestOptions()));

        expect(
          () => litterApi.addPubsToLitter('uuid-1', numberOfMale: 1),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
