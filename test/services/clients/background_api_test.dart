import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/stores/background_store_dto.dart';

import 'background_api_test.mocks.dart';

class TestableBackgroundApi {
  final DioApiClient apiClient;
  static const String basePath = '/background';

  TestableBackgroundApi(this.apiClient);

  Future<BackgroundStoreDto> postBackground(String backgroundName) async {
    final res =
        await apiClient.post(basePath, body: {'name': backgroundName});
    if (res.statusCode != 201) {
      throw Exception('Failed to post background: ${res.data}');
    }
    return BackgroundStoreDto.fromJson(res.data as Map<String, dynamic>);
  }
}

Map<String, dynamic> _sampleBackgroundJson() => {
      'id': 1,
      'uuid': 'bg-uuid-1',
      'name': 'C57BL/6J',
      'createdDate': '2025-01-01T00:00:00Z',
      'lab': null,
      'owner': null,
    };

@GenerateMocks([DioApiClient])
void main() {
  group('BackgroundApi Tests', () {
    late MockDioApiClient mockApiClient;
    late TestableBackgroundApi api;

    setUp(() {
      mockApiClient = MockDioApiClient();
      api = TestableBackgroundApi(mockApiClient);
    });

    group('postBackground', () {
      test('should return BackgroundStoreDto on 201', () async {
        when(mockApiClient.post(any,
                body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: _sampleBackgroundJson(),
                  statusCode: 201,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.postBackground('C57BL/6J');

        expect(result.name, 'C57BL/6J');
        expect(result.uuid, 'bg-uuid-1');
        verify(mockApiClient.post('/background',
                body: {'name': 'C57BL/6J'}, query: anyNamed('query')))
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

        expect(
            () => api.postBackground('Bad'), throwsA(isA<Exception>()));
      });
    });
  });
}
