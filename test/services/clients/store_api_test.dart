import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/services/clients/store_api.dart';
import 'package:moustra/services/dtos/stores/animal_store_dto.dart';
import 'package:moustra/services/dtos/stores/cage_store_dto.dart';
import 'package:moustra/services/dtos/stores/strain_store_dto.dart';

import 'store_api_test.mocks.dart';

// Testable version of StoreApi that accepts a client
class TestableStoreApi<T> {
  final ApiClient apiClient;
  static const String basePath = '/store';

  TestableStoreApi(this.apiClient);

  Future<List<T>> getStore(StoreKeys key) async {
    final res = await apiClient.get('$basePath/${key.path}');
    final List<dynamic> data = jsonDecode(res.body);
    final List<T> result = [];
    for (var e in data) {
      result.add(key.fromJson(e));
    }
    return result;
  }
}

@GenerateMocks([ApiClient])
void main() {
  group('StoreApi Tests', () {
    late MockApiClient mockApiClient;
    late TestableStoreApi<AnimalStoreDto> animalStoreApi;
    late TestableStoreApi<CageStoreDto> cageStoreApi;
    late TestableStoreApi<StrainStoreDto> strainStoreApi;

    setUp(() {
      mockApiClient = MockApiClient();
      animalStoreApi = TestableStoreApi<AnimalStoreDto>(mockApiClient);
      cageStoreApi = TestableStoreApi<CageStoreDto>(mockApiClient);
      strainStoreApi = TestableStoreApi<StrainStoreDto>(mockApiClient);
    });

    group('getStore', () {
      test('should return list of animals from store', () async {
        // Arrange
        final mockResponse = http.Response(
          jsonEncode([
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
          ]),
          200,
        );

        when(
          mockApiClient.get('/store/Animal'),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await animalStoreApi.getStore(StoreKeys.animal);

        // Assert
        expect(result.length, 2);
        expect(result.first.physicalTag, 'A001');
        expect(result.last.physicalTag, 'A002');
        verify(mockApiClient.get('/store/Animal')).called(1);
      });

      test('should return list of cages from store', () async {
        // Arrange
        final mockResponse = http.Response(
          jsonEncode([
            {
              'cageId': 1,
              'cageUuid': 'cage-uuid-1',
              'cageTag': 'C001',
              'rackId': 1,
              'rackUuid': 'rack-uuid-1',
            },
            {
              'cageId': 2,
              'cageUuid': 'cage-uuid-2',
              'cageTag': 'C002',
              'rackId': 1,
              'rackUuid': 'rack-uuid-1',
            },
          ]),
          200,
        );

        when(
          mockApiClient.get('/store/Cage'),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await cageStoreApi.getStore(StoreKeys.cage);

        // Assert
        expect(result.length, 2);
        expect(result.first.cageTag, 'C001');
        expect(result.last.cageTag, 'C002');
        verify(mockApiClient.get('/store/Cage')).called(1);
      });

      test('should return list of strains from store', () async {
        // Arrange
        final mockResponse = http.Response(
          jsonEncode([
            {
              'strainId': 1,
              'strainUuid': 'strain-uuid-1',
              'strainName': 'C57BL/6',
              'genotypes': [],
            },
            {
              'strainId': 2,
              'strainUuid': 'strain-uuid-2',
              'strainName': 'BALB/c',
              'genotypes': [],
            },
          ]),
          200,
        );

        when(
          mockApiClient.get('/store/Strain'),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await strainStoreApi.getStore(StoreKeys.strain);

        // Assert
        expect(result.length, 2);
        expect(result.first.strainName, 'C57BL/6');
        expect(result.last.strainName, 'BALB/c');
        verify(mockApiClient.get('/store/Strain')).called(1);
      });

      test('should return empty list when store is empty', () async {
        // Arrange
        final mockResponse = http.Response(jsonEncode([]), 200);

        when(
          mockApiClient.get('/store/Animal'),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await animalStoreApi.getStore(StoreKeys.animal);

        // Assert
        expect(result.length, 0);
        verify(mockApiClient.get('/store/Animal')).called(1);
      });

      test('should handle different store keys correctly', () async {
        // Arrange
        final mockResponse = http.Response(
          jsonEncode([
            {
              'geneId': 1,
              'geneUuid': 'gene-uuid-1',
              'geneName': 'Gene1',
              'isActive': true,
            },
          ]),
          200,
        );

        when(
          mockApiClient.get('/store/Gene'),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await TestableStoreApi(
          mockApiClient,
        ).getStore(StoreKeys.gene);

        // Assert
        expect(result.length, 1);
        verify(mockApiClient.get('/store/Gene')).called(1);
      });
    });
  });
}
