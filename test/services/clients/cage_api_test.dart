import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/services/dtos/cage_dto.dart';
import 'package:moustra/services/dtos/paginated_response_dto.dart';
import 'package:moustra/services/dtos/rack_dto.dart';

import 'cage_api_test.mocks.dart';

// Testable version of CageApi that accepts a client
class TestableCageApi {
  final ApiClient apiClient;
  static const String basePath = '/cage';

  TestableCageApi(this.apiClient);

  Future<PaginatedResponseDto<CageDto>> getCagesPage({
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
    return PaginatedResponseDto<CageDto>.fromJson(
      data,
      (j) => CageDto.fromJson(j),
    );
  }

  Future<CageDto> getCage(String cageUuid) async {
    final res = await apiClient.get('$basePath/$cageUuid');
    return CageDto.fromJson(jsonDecode(res.body));
  }

  Future<RackDto> createCageInRack({
    required String cageTag,
    required String rackUuid,
    int? xPosition,
    int? yPosition,
  }) async {
    final body = <String, dynamic>{
      'cageTag': cageTag,
      'rack': rackUuid,
    };
    if (xPosition != null) body['xPosition'] = xPosition;
    if (yPosition != null) body['yPosition'] = yPosition;

    final res = await apiClient.post(basePath, body: body);
    if (res.statusCode != 201) {
      throw Exception('Failed to create cage in rack: ${res.body}');
    }
    return RackDto.fromJson(jsonDecode(res.body));
  }

  Future<void> endCage(String cageUuid) async {
    final res = await apiClient.post('$basePath/$cageUuid/end');
    if (res.statusCode != 204) {
      throw Exception('Failed to end cage ${res.body}');
    }
  }

  Future<RackDto> moveCage(
    String cageUuid, {
    required int x,
    required int y,
  }) async {
    final res = await apiClient.put(
      '$basePath/$cageUuid/order',
      body: {'x': x, 'y': y},
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to move cage: ${res.body}');
    }
    return RackDto.fromJson(jsonDecode(res.body));
  }
}

@GenerateMocks([ApiClient])
void main() {
  group('CageApi Tests', () {
    late MockApiClient mockApiClient;
    late TestableCageApi cageApi;

    setUp(() {
      mockApiClient = MockApiClient();
      cageApi = TestableCageApi(mockApiClient);
    });

    group('getCagesPage', () {
      test('should return paginated cages response', () async {
        // Arrange
        final mockResponse = http.Response(
          jsonEncode({
            'results': [
              {
                'cageId': 1,
                'cageUuid': 'uuid-1',
                'cageTag': 'C001',
                'status': 'active',
                'owner': {
                  'accountId': 1,
                  'accountUuid': 'owner-uuid-1',
                  'user': {
                    'firstName': 'Test',
                    'lastName': 'User',
                    'email': 'test@example.com',
                  },
                },
                'animals': [],
              },
              {
                'cageId': 2,
                'cageUuid': 'uuid-2',
                'cageTag': 'C002',
                'status': 'active',
                'owner': {
                  'accountId': 1,
                  'accountUuid': 'owner-uuid-1',
                  'user': {
                    'firstName': 'Test',
                    'lastName': 'User',
                    'email': 'test@example.com',
                  },
                },
                'animals': [],
              },
            ],
            'count': 2,
            'next': null,
            'previous': null,
          }),
          200,
        );

        when(
          mockApiClient.get(any, query: anyNamed('query')),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await cageApi.getCagesPage(page: 1, pageSize: 25);

        // Assert
        expect(result.results.length, equals(2));
        expect(result.count, equals(2));
        expect(result.results.first.cageId, equals(1));
        expect(result.results.first.cageTag, equals('C001'));
        expect(result.results.last.cageId, equals(2));
        expect(result.results.last.cageTag, equals('C002'));
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
        await cageApi.getCagesPage(
          page: 2,
          pageSize: 10,
          query: {'rack': 'rack-uuid'},
        );

        // Assert
        verify(
          mockApiClient.get(
            any,
            query: argThat(
              isA<Map<String, String>>()
                  .having((q) => q['page'], 'page', '2')
                  .having((q) => q['page_size'], 'page_size', '10')
                  .having((q) => q['rack'], 'rack', 'rack-uuid'),
              named: 'query',
            ),
          ),
        ).called(1);
      });
    });

    group('getCage', () {
      test('should return single cage', () async {
        // Arrange
        const cageUuid = 'test-uuid';
        final mockResponse = http.Response(
          jsonEncode({
            'cageId': 1,
            'cageUuid': cageUuid,
            'cageTag': 'C001',
            'status': 'active',
            'owner': {
              'accountId': 1,
              'accountUuid': 'owner-uuid-1',
              'user': {
                'firstName': 'Test',
                'lastName': 'User',
                'email': 'test@example.com',
              },
            },
            'animals': [],
          }),
          200,
        );

        when(mockApiClient.get(any)).thenAnswer((_) async => mockResponse);

        // Act
        final result = await cageApi.getCage(cageUuid);

        // Assert
        expect(result.cageUuid, equals(cageUuid));
        expect(result.cageTag, equals('C001'));
        verify(mockApiClient.get('/cage/$cageUuid')).called(1);
      });
    });

    group('createCageInRack', () {
      test('should create cage in rack without position', () async {
        // Arrange
        const cageTag = 'New Cage';
        const rackUuid = 'rack-uuid';

        final mockResponse = http.Response(
          jsonEncode({
            'rackId': 1,
            'rackUuid': rackUuid,
            'rackName': 'Rack A',
            'rackWidth': 5,
            'rackHeight': 2,
            'cages': [
              {
                'cageUuid': 'new-cage-uuid',
                'cageTag': cageTag,
              }
            ],
          }),
          201,
        );

        when(
          mockApiClient.post(any, body: anyNamed('body')),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await cageApi.createCageInRack(
          cageTag: cageTag,
          rackUuid: rackUuid,
        );

        // Assert
        expect(result.rackUuid, equals(rackUuid));
        expect(result.rackName, equals('Rack A'));
        verify(
          mockApiClient.post(
            '/cage',
            body: {'cageTag': cageTag, 'rack': rackUuid},
          ),
        ).called(1);
      });

      test('should create cage in rack with x and y positions', () async {
        // Arrange
        const cageTag = 'New Cage';
        const rackUuid = 'rack-uuid';
        const xPosition = 2;
        const yPosition = 1;

        final mockResponse = http.Response(
          jsonEncode({
            'rackId': 1,
            'rackUuid': rackUuid,
            'rackName': 'Rack A',
            'rackWidth': 5,
            'rackHeight': 2,
            'cages': [
              {
                'cageUuid': 'new-cage-uuid',
                'cageTag': cageTag,
                'xPosition': xPosition,
                'yPosition': yPosition,
              }
            ],
          }),
          201,
        );

        when(
          mockApiClient.post(any, body: anyNamed('body')),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await cageApi.createCageInRack(
          cageTag: cageTag,
          rackUuid: rackUuid,
          xPosition: xPosition,
          yPosition: yPosition,
        );

        // Assert
        expect(result.rackUuid, equals(rackUuid));
        verify(
          mockApiClient.post(
            '/cage',
            body: {
              'cageTag': cageTag,
              'rack': rackUuid,
              'xPosition': xPosition,
              'yPosition': yPosition,
            },
          ),
        ).called(1);
      });

      test('should create cage with only xPosition', () async {
        // Arrange
        const cageTag = 'New Cage';
        const rackUuid = 'rack-uuid';
        const xPosition = 3;

        final mockResponse = http.Response(
          jsonEncode({
            'rackId': 1,
            'rackUuid': rackUuid,
            'rackName': 'Rack A',
            'cages': [],
          }),
          201,
        );

        when(
          mockApiClient.post(any, body: anyNamed('body')),
        ).thenAnswer((_) async => mockResponse);

        // Act
        await cageApi.createCageInRack(
          cageTag: cageTag,
          rackUuid: rackUuid,
          xPosition: xPosition,
        );

        // Assert
        verify(
          mockApiClient.post(
            '/cage',
            body: {
              'cageTag': cageTag,
              'rack': rackUuid,
              'xPosition': xPosition,
            },
          ),
        ).called(1);
      });

      test('should create cage with only yPosition', () async {
        // Arrange
        const cageTag = 'New Cage';
        const rackUuid = 'rack-uuid';
        const yPosition = 2;

        final mockResponse = http.Response(
          jsonEncode({
            'rackId': 1,
            'rackUuid': rackUuid,
            'rackName': 'Rack A',
            'cages': [],
          }),
          201,
        );

        when(
          mockApiClient.post(any, body: anyNamed('body')),
        ).thenAnswer((_) async => mockResponse);

        // Act
        await cageApi.createCageInRack(
          cageTag: cageTag,
          rackUuid: rackUuid,
          yPosition: yPosition,
        );

        // Assert
        verify(
          mockApiClient.post(
            '/cage',
            body: {
              'cageTag': cageTag,
              'rack': rackUuid,
              'yPosition': yPosition,
            },
          ),
        ).called(1);
      });

      test('should throw exception on non-201 status', () async {
        // Arrange
        final mockResponse = http.Response('Bad Request', 400);

        when(
          mockApiClient.post(any, body: anyNamed('body')),
        ).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => cageApi.createCageInRack(cageTag: 'New', rackUuid: 'uuid'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('moveCage', () {
      test('should move cage to new position and return rack data', () async {
        // Arrange
        const cageUuid = 'cage-uuid';
        const x = 3;
        const y = 1;

        final mockResponse = http.Response(
          jsonEncode({
            'rackId': 1,
            'rackUuid': 'rack-uuid',
            'rackName': 'Rack A',
            'rackWidth': 5,
            'rackHeight': 2,
            'cages': [
              {
                'cageUuid': cageUuid,
                'cageTag': 'C001',
                'xPosition': x,
                'yPosition': y,
              }
            ],
          }),
          200,
        );

        when(
          mockApiClient.put(any, body: anyNamed('body')),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await cageApi.moveCage(cageUuid, x: x, y: y);

        // Assert
        expect(result.rackUuid, equals('rack-uuid'));
        expect(result.rackName, equals('Rack A'));
        verify(
          mockApiClient.put(
            '/cage/$cageUuid/order',
            body: {'x': x, 'y': y},
          ),
        ).called(1);
      });

      test('should move cage to position (0, 0)', () async {
        // Arrange
        const cageUuid = 'cage-uuid';
        const x = 0;
        const y = 0;

        final mockResponse = http.Response(
          jsonEncode({
            'rackId': 1,
            'rackUuid': 'rack-uuid',
            'rackName': 'Rack A',
            'cages': [],
          }),
          200,
        );

        when(
          mockApiClient.put(any, body: anyNamed('body')),
        ).thenAnswer((_) async => mockResponse);

        // Act
        await cageApi.moveCage(cageUuid, x: x, y: y);

        // Assert
        verify(
          mockApiClient.put(
            '/cage/$cageUuid/order',
            body: {'x': 0, 'y': 0},
          ),
        ).called(1);
      });

      test('should throw exception on non-200 status', () async {
        // Arrange
        const cageUuid = 'cage-uuid';
        final mockResponse = http.Response('Bad Request', 400);

        when(
          mockApiClient.put(any, body: anyNamed('body')),
        ).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => cageApi.moveCage(cageUuid, x: 1, y: 1),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception on 404 status', () async {
        // Arrange
        const cageUuid = 'nonexistent-cage';
        final mockResponse = http.Response('Not Found', 404);

        when(
          mockApiClient.put(any, body: anyNamed('body')),
        ).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => cageApi.moveCage(cageUuid, x: 0, y: 0),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception on 409 conflict status', () async {
        // Arrange
        const cageUuid = 'cage-uuid';
        final mockResponse = http.Response('Position already occupied', 409);

        when(
          mockApiClient.put(any, body: anyNamed('body')),
        ).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => cageApi.moveCage(cageUuid, x: 2, y: 1),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('endCage', () {
      test('should end cage successfully', () async {
        // Arrange
        const cageUuid = 'cage-uuid';
        final mockResponse = http.Response('', 204);

        when(
          mockApiClient.post(any),
        ).thenAnswer((_) async => mockResponse);

        // Act
        await cageApi.endCage(cageUuid);

        // Assert
        verify(mockApiClient.post('/cage/$cageUuid/end')).called(1);
      });

      test('should throw exception on non-204 status', () async {
        // Arrange
        const cageUuid = 'cage-uuid';
        final mockResponse = http.Response('Cage has animals', 400);

        when(
          mockApiClient.post(any),
        ).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => cageApi.endCage(cageUuid),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
