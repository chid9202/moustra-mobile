import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/stores/allele_store_dto.dart';

import 'allele_api_test.mocks.dart';

class TestableAlleleApi {
  final DioApiClient apiClient;
  static const String basePath = '/allele';

  TestableAlleleApi(this.apiClient);

  Future<AlleleStoreDto> postAllele(String alleleName) async {
    final res =
        await apiClient.post(basePath, body: {'alleleName': alleleName});
    if (res.statusCode != 201) {
      throw Exception('Failed to post allele: ${res.data}');
    }
    return AlleleStoreDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteAllele(String alleleUuid) async {
    final res = await apiClient.delete('$basePath/$alleleUuid');
    if (res.statusCode != 204) {
      throw Exception('Failed to delete allele: ${res.data}');
    }
  }
}

Map<String, dynamic> _sampleAlleleJson() => {
      'alleleId': 1,
      'alleleUuid': 'allele-uuid-1',
      'alleleName': 'tm1a',
      'isActive': true,
    };

@GenerateMocks([DioApiClient])
void main() {
  group('AlleleApi Tests', () {
    late MockDioApiClient mockApiClient;
    late TestableAlleleApi api;

    setUp(() {
      mockApiClient = MockDioApiClient();
      api = TestableAlleleApi(mockApiClient);
    });

    group('postAllele', () {
      test('should return AlleleStoreDto on 201', () async {
        when(mockApiClient.post(any,
                body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: _sampleAlleleJson(),
                  statusCode: 201,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.postAllele('tm1a');

        expect(result.alleleName, 'tm1a');
        expect(result.alleleUuid, 'allele-uuid-1');
        verify(mockApiClient.post('/allele',
                body: {'alleleName': 'tm1a'}, query: anyNamed('query')))
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

        expect(() => api.postAllele('Bad'), throwsA(isA<Exception>()));
      });
    });

    group('deleteAllele', () {
      test('should complete on 204', () async {
        when(mockApiClient.delete(any)).thenAnswer((_) async => Response(
              data: null,
              statusCode: 204,
              requestOptions: RequestOptions(),
            ));

        await api.deleteAllele('allele-uuid-1');

        verify(mockApiClient.delete('/allele/allele-uuid-1')).called(1);
      });

      test('should throw on non-204 status', () async {
        when(mockApiClient.delete(any)).thenAnswer((_) async => Response(
              data: 'Error',
              statusCode: 404,
              requestOptions: RequestOptions(),
            ));

        expect(
            () => api.deleteAllele('bad-uuid'), throwsA(isA<Exception>()));
      });
    });
  });
}
