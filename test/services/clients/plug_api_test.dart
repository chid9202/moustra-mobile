import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/services/dtos/paginated_response_dto.dart';
import 'package:moustra/services/dtos/plug_check_dto.dart';
import 'package:moustra/services/dtos/plug_event_dto.dart';
import 'package:moustra/services/dtos/post_plug_check_dto.dart';
import 'package:moustra/services/dtos/post_plug_event_dto.dart';
import 'package:moustra/services/dtos/put_plug_event_dto.dart';
import 'package:moustra/services/dtos/record_outcome_dto.dart';
import 'package:moustra/services/models/list_query_params.dart';

import 'plug_api_test.mocks.dart';

// Testable version of PlugApi that accepts a client
class TestablePlugApi {
  final ApiClient apiClient;
  static const String plugEventPath = '/plug-event';
  static const String plugCheckPath = '/plug-check';

  TestablePlugApi(this.apiClient);

  Future<PaginatedResponseDto<PlugEventDto>> getPlugEventsPage({
    required ListQueryParams params,
  }) async {
    final queryString = params.buildQueryString();
    final res = await apiClient.getWithQueryString(
      plugEventPath,
      queryString: queryString,
    );
    final Map<String, dynamic> data = jsonDecode(res.body);
    return PaginatedResponseDto<PlugEventDto>.fromJson(
      data,
      (j) => PlugEventDto.fromJson(j),
    );
  }

  Future<PlugEventDto> getPlugEvent(String uuid) async {
    final res = await apiClient.get('$plugEventPath/$uuid');
    return PlugEventDto.fromJson(jsonDecode(res.body));
  }

  Future<PaginatedResponseDto<PlugEventDto>> getActivePlugEvents({
    int page = 1,
    int pageSize = 25,
  }) async {
    final res = await apiClient.get(plugEventPath, query: {
      'page': page.toString(),
      'page_size': pageSize.toString(),
      'filter': 'is_active',
      'op': 'equals',
      'value': 'true',
    });
    final Map<String, dynamic> data = jsonDecode(res.body);
    return PaginatedResponseDto<PlugEventDto>.fromJson(
      data,
      (j) => PlugEventDto.fromJson(j),
    );
  }

  Future<PaginatedResponseDto<PlugEventDto>> getDueSoonPlugEvents({
    int days = 3,
    int page = 1,
    int pageSize = 25,
  }) async {
    final res = await apiClient.get(plugEventPath, query: {
      'page': page.toString(),
      'page_size': pageSize.toString(),
      'filter': 'due_soon',
      'op': 'equals',
      'value': days.toString(),
    });
    final Map<String, dynamic> data = jsonDecode(res.body);
    return PaginatedResponseDto<PlugEventDto>.fromJson(
      data,
      (j) => PlugEventDto.fromJson(j),
    );
  }

  Future<PlugEventDto> createPlugEvent(PostPlugEventDto dto) async {
    final res = await apiClient.post(plugEventPath, body: dto.toJson());
    if (res.statusCode != 201) {
      throw Exception('Failed to create plug event: ${res.body}');
    }
    return PlugEventDto.fromJson(jsonDecode(res.body));
  }

  Future<PlugEventDto> updatePlugEvent(
    String uuid,
    PutPlugEventDto dto,
  ) async {
    final res =
        await apiClient.put('$plugEventPath/$uuid', body: dto.toJson());
    if (res.statusCode >= 400) {
      throw Exception('Failed to update plug event: ${res.body}');
    }
    return PlugEventDto.fromJson(jsonDecode(res.body));
  }

  Future<void> deletePlugEvent(String uuid) async {
    final res = await apiClient.delete('$plugEventPath/$uuid');
    if (res.statusCode >= 400) {
      throw Exception('Failed to delete plug event: ${res.body}');
    }
  }

  Future<PlugEventDto> recordOutcome(
    String uuid,
    RecordOutcomeDto dto,
  ) async {
    final res = await apiClient.post(
      '$plugEventPath/$uuid/outcome',
      body: dto.toJson(),
    );
    if (res.statusCode >= 400) {
      throw Exception('Failed to record outcome: ${res.body}');
    }
    return PlugEventDto.fromJson(jsonDecode(res.body));
  }

  Future<List<PlugCheckDto>> batchCreatePlugChecks(
    List<PostPlugCheckDto> checks,
  ) async {
    final res = await apiClient.post(
      '$plugCheckPath/batch',
      body: checks.map((c) => c.toJson()).toList(),
    );
    if (res.statusCode != 201) {
      throw Exception('Failed to create plug checks ${res.body}');
    }
    final List<dynamic> data = jsonDecode(res.body);
    return data
        .whereType<Map<String, dynamic>>()
        .map((j) => PlugCheckDto.fromJson(j))
        .toList();
  }
}

@GenerateMocks([ApiClient])
void main() {
  group('PlugApi Tests', () {
    late MockApiClient mockApiClient;
    late TestablePlugApi plugApi;

    final samplePlugEventJson = {
      'plugEventId': 1,
      'plugEventUuid': 'test-plug-event-uuid',
      'plugDate': '2023-06-15T00:00:00.000Z',
      'female': {
        'animalId': 1,
        'animalUuid': 'female-uuid',
        'physicalTag': 'F001',
      },
      'male': {
        'animalId': 2,
        'animalUuid': 'male-uuid',
        'physicalTag': 'M001',
      },
    };

    final samplePaginatedResponse = {
      'results': [samplePlugEventJson],
      'count': 1,
      'next': null,
      'previous': null,
    };

    final emptyPaginatedResponse = {
      'results': [],
      'count': 0,
      'next': null,
      'previous': null,
    };

    setUp(() {
      mockApiClient = MockApiClient();
      plugApi = TestablePlugApi(mockApiClient);
    });

    group('getPlugEventsPage', () {
      test('should return paginated plug events response', () async {
        // Arrange
        final mockResponse = http.Response(
          jsonEncode(samplePaginatedResponse),
          200,
        );

        when(
          mockApiClient.getWithQueryString(any,
              queryString: anyNamed('queryString')),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final params = const ListQueryParams(page: 1, pageSize: 25);
        final result = await plugApi.getPlugEventsPage(params: params);

        // Assert
        expect(result.results.length, 1);
        expect(result.count, 1);
        expect(result.results.first.plugEventUuid, 'test-plug-event-uuid');
        verify(
          mockApiClient.getWithQueryString(any,
              queryString: anyNamed('queryString')),
        ).called(1);
      });

      test('should pass query string with filters', () async {
        // Arrange
        final mockResponse = http.Response(
          jsonEncode(emptyPaginatedResponse),
          200,
        );

        when(
          mockApiClient.getWithQueryString(any,
              queryString: anyNamed('queryString')),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final params = ListQueryParams(
          page: 2,
          pageSize: 10,
          filters: [
            const FilterParam(field: 'status', operator: 'equals', value: 'active'),
          ],
        );
        await plugApi.getPlugEventsPage(params: params);

        // Assert
        verify(
          mockApiClient.getWithQueryString(
            '/plug-event',
            queryString: argThat(
              allOf([
                contains('page=2'),
                contains('page_size=10'),
                contains('filter=status'),
                contains('op=equals'),
                contains('value=active'),
              ]),
              named: 'queryString',
            ),
          ),
        ).called(1);
      });
    });

    group('getPlugEvent', () {
      test('should return single plug event', () async {
        // Arrange
        const uuid = 'test-plug-event-uuid';
        final mockResponse = http.Response(
          jsonEncode(samplePlugEventJson),
          200,
        );

        when(mockApiClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act
        final result = await plugApi.getPlugEvent(uuid);

        // Assert
        expect(result.plugEventUuid, uuid);
        expect(result.plugEventId, 1);
        verify(mockApiClient.get('/plug-event/$uuid')).called(1);
      });
    });

    group('getActivePlugEvents', () {
      test('should return paginated active plug events', () async {
        // Arrange
        final mockResponse = http.Response(
          jsonEncode(samplePaginatedResponse),
          200,
        );

        when(
          mockApiClient.get(any, query: anyNamed('query')),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await plugApi.getActivePlugEvents(page: 1, pageSize: 10);

        // Assert
        expect(result.results.length, 1);
        expect(result.count, 1);
        verify(
          mockApiClient.get(
            '/plug-event',
            query: argThat(
              allOf([
                containsPair('page', '1'),
                containsPair('page_size', '10'),
                containsPair('filter', 'is_active'),
                containsPair('op', 'equals'),
                containsPair('value', 'true'),
              ]),
              named: 'query',
            ),
          ),
        ).called(1);
      });
    });

    group('getDueSoonPlugEvents', () {
      test('should return paginated due-soon plug events', () async {
        // Arrange
        final mockResponse = http.Response(
          jsonEncode(samplePaginatedResponse),
          200,
        );

        when(
          mockApiClient.get(any, query: anyNamed('query')),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await plugApi.getDueSoonPlugEvents(
          days: 5,
          page: 1,
          pageSize: 10,
        );

        // Assert
        expect(result.results.length, 1);
        verify(
          mockApiClient.get(
            '/plug-event',
            query: argThat(
              allOf([
                containsPair('page', '1'),
                containsPair('page_size', '10'),
                containsPair('filter', 'due_soon'),
                containsPair('op', 'equals'),
                containsPair('value', '5'),
              ]),
              named: 'query',
            ),
          ),
        ).called(1);
      });
    });

    group('createPlugEvent', () {
      test('should create plug event and return created data', () async {
        // Arrange
        final postDto = PostPlugEventDto(
          female: 'female-uuid',
          male: 'male-uuid',
          plugDate: '2023-06-15',
          targetEday: 14,
        );

        final mockResponse = http.Response(
          jsonEncode(samplePlugEventJson),
          201,
        );

        when(
          mockApiClient.post(any, body: anyNamed('body')),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await plugApi.createPlugEvent(postDto);

        // Assert
        expect(result.plugEventUuid, 'test-plug-event-uuid');
        expect(result.plugEventId, 1);
        verify(
          mockApiClient.post('/plug-event', body: anyNamed('body')),
        ).called(1);
      });

      test('should throw exception on non-201 status', () async {
        // Arrange
        final postDto = PostPlugEventDto(
          female: 'female-uuid',
          plugDate: '2023-06-15',
        );

        final mockResponse = http.Response('Bad Request', 400);

        when(
          mockApiClient.post(any, body: anyNamed('body')),
        ).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => plugApi.createPlugEvent(postDto),
          throwsA(isA<Exception>()),
        );
        verify(
          mockApiClient.post('/plug-event', body: anyNamed('body')),
        ).called(1);
      });
    });

    group('updatePlugEvent', () {
      test('should update plug event and return updated data', () async {
        // Arrange
        const uuid = 'test-plug-event-uuid';
        final putDto = PutPlugEventDto(
          plugDate: '2023-07-01',
          targetEday: 18,
          comment: 'Updated comment',
        );

        final updatedJson = {
          ...samplePlugEventJson,
          'plugDate': '2023-07-01T00:00:00.000Z',
        };

        final mockResponse = http.Response(jsonEncode(updatedJson), 200);

        when(
          mockApiClient.put(any, body: anyNamed('body')),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await plugApi.updatePlugEvent(uuid, putDto);

        // Assert
        expect(result.plugEventUuid, uuid);
        verify(
          mockApiClient.put('/plug-event/$uuid', body: anyNamed('body')),
        ).called(1);
      });

      test('should throw exception on error status', () async {
        // Arrange
        const uuid = 'test-plug-event-uuid';
        final putDto = PutPlugEventDto(plugDate: '2023-07-01');

        final mockResponse = http.Response('Not Found', 404);

        when(
          mockApiClient.put(any, body: anyNamed('body')),
        ).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => plugApi.updatePlugEvent(uuid, putDto),
          throwsA(isA<Exception>()),
        );
        verify(
          mockApiClient.put('/plug-event/$uuid', body: anyNamed('body')),
        ).called(1);
      });
    });

    group('deletePlugEvent', () {
      test('should delete plug event successfully', () async {
        // Arrange
        const uuid = 'test-plug-event-uuid';
        final mockResponse = http.Response('', 204);

        when(mockApiClient.delete(any)).thenAnswer((_) async => mockResponse);

        // Act
        await plugApi.deletePlugEvent(uuid);

        // Assert
        verify(mockApiClient.delete('/plug-event/$uuid')).called(1);
      });

      test('should throw exception on error status', () async {
        // Arrange
        const uuid = 'test-plug-event-uuid';
        final mockResponse = http.Response('Not Found', 404);

        when(mockApiClient.delete(any)).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => plugApi.deletePlugEvent(uuid),
          throwsA(isA<Exception>()),
        );
        verify(mockApiClient.delete('/plug-event/$uuid')).called(1);
      });
    });

    group('recordOutcome', () {
      test('should record outcome and return updated plug event', () async {
        // Arrange
        const uuid = 'test-plug-event-uuid';
        final outcomeDto = RecordOutcomeDto(
          outcome: 'delivery',
          outcomeDate: '2023-07-05',
          embryosCollected: 8,
        );

        final responseJson = {
          ...samplePlugEventJson,
          'outcome': 'delivery',
          'outcomeDate': '2023-07-05T00:00:00.000Z',
          'embryosCollected': 8,
        };

        final mockResponse = http.Response(jsonEncode(responseJson), 200);

        when(
          mockApiClient.post(any, body: anyNamed('body')),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await plugApi.recordOutcome(uuid, outcomeDto);

        // Assert
        expect(result.plugEventUuid, uuid);
        expect(result.outcome, 'delivery');
        expect(result.embryosCollected, 8);
        verify(
          mockApiClient.post('/plug-event/$uuid/outcome',
              body: anyNamed('body')),
        ).called(1);
      });

      test('should throw exception on error status', () async {
        // Arrange
        const uuid = 'test-plug-event-uuid';
        final outcomeDto = RecordOutcomeDto(
          outcome: 'delivery',
          outcomeDate: '2023-07-05',
        );

        final mockResponse = http.Response('Bad Request', 400);

        when(
          mockApiClient.post(any, body: anyNamed('body')),
        ).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => plugApi.recordOutcome(uuid, outcomeDto),
          throwsA(isA<Exception>()),
        );
        verify(
          mockApiClient.post('/plug-event/$uuid/outcome',
              body: anyNamed('body')),
        ).called(1);
      });
    });

    group('batchCreatePlugChecks', () {
      test('should batch create plug checks and return list', () async {
        // Arrange
        final checks = [
          PostPlugCheckDto(
            female: 'female-uuid-1',
            checkDate: DateTime(2023, 6, 16),
            result: 'positive',
            notes: 'Good plug',
          ),
          PostPlugCheckDto(
            female: 'female-uuid-2',
            checkDate: DateTime(2023, 6, 16),
            result: 'negative',
          ),
        ];

        final responseJson = [
          {
            'plugCheckId': 1,
            'plugCheckUuid': 'check-uuid-1',
            'checkDate': '2023-06-16T00:00:00.000Z',
            'result': 'positive',
            'notes': 'Good plug',
          },
          {
            'plugCheckId': 2,
            'plugCheckUuid': 'check-uuid-2',
            'checkDate': '2023-06-16T00:00:00.000Z',
            'result': 'negative',
          },
        ];

        final mockResponse = http.Response(jsonEncode(responseJson), 201);

        when(
          mockApiClient.post(any, body: anyNamed('body')),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await plugApi.batchCreatePlugChecks(checks);

        // Assert
        expect(result.length, 2);
        expect(result[0].plugCheckUuid, 'check-uuid-1');
        expect(result[0].result, 'positive');
        expect(result[1].plugCheckUuid, 'check-uuid-2');
        expect(result[1].result, 'negative');
        verify(
          mockApiClient.post('/plug-check/batch', body: anyNamed('body')),
        ).called(1);
      });

      test('should throw exception on non-201 status', () async {
        // Arrange
        final checks = [
          PostPlugCheckDto(
            female: 'female-uuid-1',
            checkDate: DateTime(2023, 6, 16),
            result: 'positive',
          ),
        ];

        final mockResponse = http.Response('Server Error', 500);

        when(
          mockApiClient.post(any, body: anyNamed('body')),
        ).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => plugApi.batchCreatePlugChecks(checks),
          throwsA(isA<Exception>()),
        );
        verify(
          mockApiClient.post('/plug-check/batch', body: anyNamed('body')),
        ).called(1);
      });
    });
  });
}
