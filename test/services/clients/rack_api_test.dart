import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/rack_dto.dart';

import 'rack_api_test.mocks.dart';

class TestableRackApi {
  final DioApiClient apiClient;
  static const String basePath = '/rack';

  TestableRackApi(this.apiClient);

  Future<RackDto> getRack({String? rackUuid}) async {
    final path =
        rackUuid != null ? '$basePath/$rackUuid' : '$basePath/default';
    final res = await apiClient.get(path);
    if (res.statusCode != 200) {
      throw Exception('Failed to get rack: ${res.data}');
    }
    return RackDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<RackDto> createRack(Map<String, dynamic> payload) async {
    final res = await apiClient.post('$basePath/new', body: payload);
    if (res.statusCode != 201) {
      throw Exception('Failed to create rack: ${res.data}');
    }
    return RackDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<RackDto> updateRack(
      String rackUuid, Map<String, dynamic> payload) async {
    final res = await apiClient.put('$basePath/$rackUuid', body: payload);
    if (res.statusCode != 200) {
      throw Exception('Failed to update rack: ${res.data}');
    }
    return RackDto.fromJson(res.data as Map<String, dynamic>);
  }
}

Map<String, dynamic> _sampleRackJson({
  String uuid = 'rack-uuid-1',
  String name = 'Rack A',
}) =>
    {
      'rackId': 1,
      'rackUuid': uuid,
      'rackName': name,
      'rackWidth': 18,
      'rackHeight': 12,
      'cages': [],
      'racks': [],
    };

@GenerateMocks([DioApiClient])
void main() {
  group('RackApi Tests', () {
    late MockDioApiClient mockApiClient;
    late TestableRackApi api;

    setUp(() {
      mockApiClient = MockDioApiClient();
      api = TestableRackApi(mockApiClient);
    });

    group('getRack', () {
      test('should return rack by UUID', () async {
        when(mockApiClient.get(any, query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: _sampleRackJson(),
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.getRack(rackUuid: 'rack-uuid-1');

        expect(result.rackName, 'Rack A');
        verify(mockApiClient.get('/rack/rack-uuid-1',
                query: anyNamed('query')))
            .called(1);
      });

      test('should use default path when no UUID', () async {
        when(mockApiClient.get(any, query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: _sampleRackJson(),
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        await api.getRack();

        verify(mockApiClient.get('/rack/default',
                query: anyNamed('query')))
            .called(1);
      });

      test('should throw on non-200 status', () async {
        when(mockApiClient.get(any, query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: 'Error',
                  statusCode: 404,
                  requestOptions: RequestOptions(),
                ));

        expect(() => api.getRack(rackUuid: 'bad'), throwsA(isA<Exception>()));
      });
    });

    group('createRack', () {
      test('should return created rack on 201', () async {
        when(mockApiClient.post(any,
                body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: _sampleRackJson(name: 'New Rack'),
                  statusCode: 201,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.createRack({
          'rackName': 'New Rack',
          'rackWidth': 18,
          'rackHeight': 12,
        });

        expect(result.rackName, 'New Rack');
        verify(mockApiClient.post('/rack/new',
                body: anyNamed('body'), query: anyNamed('query')))
            .called(1);
      });

      test('should throw on non-201 status', () async {
        when(mockApiClient.post(any,
                body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: 'Error',
                  statusCode: 400,
                  requestOptions: RequestOptions(),
                ));

        expect(() => api.createRack({}), throwsA(isA<Exception>()));
      });
    });

    group('updateRack', () {
      test('should return updated rack on 200', () async {
        when(mockApiClient.put(any,
                body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: _sampleRackJson(name: 'Updated'),
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.updateRack('rack-uuid-1', {
          'rackName': 'Updated',
          'rackWidth': 20,
          'rackHeight': 14,
        });

        expect(result.rackName, 'Updated');
      });

      test('should throw on non-200 status', () async {
        when(mockApiClient.put(any,
                body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: 'Error',
                  statusCode: 400,
                  requestOptions: RequestOptions(),
                ));

        expect(
          () => api.updateRack('rack-uuid-1', {}),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
