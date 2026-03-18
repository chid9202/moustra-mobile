import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/stores/gene_store_dto.dart';

import 'gene_api_test.mocks.dart';

class TestableGeneApi {
  final DioApiClient apiClient;
  static const String basePath = '/gene';

  TestableGeneApi(this.apiClient);

  Future<GeneStoreDto> postGene(String geneName) async {
    final res = await apiClient.post(basePath, body: {'geneName': geneName});
    if (res.statusCode != 201) {
      throw Exception('Failed to post gene: ${res.data}');
    }
    return GeneStoreDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteGene(String geneUuid) async {
    final res = await apiClient.delete('$basePath/$geneUuid');
    if (res.statusCode != 204) {
      throw Exception('Failed to delete gene: ${res.data}');
    }
  }
}

Map<String, dynamic> _sampleGeneJson() => {
      'geneId': 1,
      'geneUuid': 'gene-uuid-1',
      'geneName': 'Brca1',
      'isActive': true,
    };

@GenerateMocks([DioApiClient])
void main() {
  group('GeneApi Tests', () {
    late MockDioApiClient mockApiClient;
    late TestableGeneApi api;

    setUp(() {
      mockApiClient = MockDioApiClient();
      api = TestableGeneApi(mockApiClient);
    });

    group('postGene', () {
      test('should return GeneStoreDto on 201', () async {
        when(mockApiClient.post(any, body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: _sampleGeneJson(),
                  statusCode: 201,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.postGene('Brca1');

        expect(result.geneName, 'Brca1');
        expect(result.geneUuid, 'gene-uuid-1');
        verify(mockApiClient.post('/gene',
                body: {'geneName': 'Brca1'}, query: anyNamed('query')))
            .called(1);
      });

      test('should throw on non-201 status', () async {
        when(mockApiClient.post(any, body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: 'Error',
                  statusCode: 400,
                  requestOptions: RequestOptions(),
                ));

        expect(() => api.postGene('Bad'), throwsA(isA<Exception>()));
      });
    });

    group('deleteGene', () {
      test('should complete on 204', () async {
        when(mockApiClient.delete(any)).thenAnswer((_) async => Response(
              data: null,
              statusCode: 204,
              requestOptions: RequestOptions(),
            ));

        await api.deleteGene('gene-uuid-1');

        verify(mockApiClient.delete('/gene/gene-uuid-1')).called(1);
      });

      test('should throw on non-204 status', () async {
        when(mockApiClient.delete(any)).thenAnswer((_) async => Response(
              data: 'Error',
              statusCode: 404,
              requestOptions: RequestOptions(),
            ));

        expect(() => api.deleteGene('bad-uuid'), throwsA(isA<Exception>()));
      });
    });
  });
}
