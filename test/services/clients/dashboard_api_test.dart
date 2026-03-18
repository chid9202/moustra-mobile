import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/dashboard_dto.dart';

import 'dashboard_api_test.mocks.dart';

class TestableDashboardApi {
  final DioApiClient apiClient;
  static const String basePath = '/dashboard';

  TestableDashboardApi(this.apiClient);

  Future<Map<String, dynamic>> getDashboard({
    Map<String, String>? query,
  }) async {
    final res = await apiClient.get(basePath, query: query);
    return res.data as Map<String, dynamic>;
  }

  Future<DashboardResponseDto> getDashboardDto({
    Map<String, String>? query,
  }) async {
    final res = await apiClient.get(basePath, query: query);
    final Map<String, dynamic> data = res.data as Map<String, dynamic>;
    return DashboardResponseDto.fromJson(data);
  }
}

Map<String, dynamic> _sampleDashboardJson() => {
      'accounts': {
        'acc-1': {
          'animalsCount': 10,
          'cagesCount': 5,
          'matingsCount': 2,
          'littersCount': 3,
          'name': 'Lab A',
        },
      },
      'animalByAge': [
        {
          'strainUuid': 'strain-1',
          'strainName': 'C57BL/6',
          'ageData': [
            {'ageInWeeks': 4, 'count': 5},
          ],
        },
      ],
      'animalsSexRatio': [
        {'sex': 'M', 'count': 6},
        {'sex': 'F', 'count': 4},
      ],
      'animalsToWean': [
        {
          'physicalTag': 'P001',
          'weanDate': '2025-07-01',
          'cage': {'cageTag': 'C001'},
        },
      ],
    };

@GenerateMocks([DioApiClient])
void main() {
  group('DashboardApi Tests', () {
    late MockDioApiClient mockApiClient;
    late TestableDashboardApi api;

    setUp(() {
      mockApiClient = MockDioApiClient();
      api = TestableDashboardApi(mockApiClient);
    });

    group('getDashboard', () {
      test('should return raw map on success', () async {
        final json = _sampleDashboardJson();
        when(mockApiClient.get(any, query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: json,
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.getDashboard();

        expect(result, isA<Map<String, dynamic>>());
        expect(result['accounts'], isNotNull);
        verify(mockApiClient.get('/dashboard', query: anyNamed('query')))
            .called(1);
      });

      test('should forward query parameters', () async {
        when(mockApiClient.get(any, query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: _sampleDashboardJson(),
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        await api.getDashboard(query: {'range': '7d'});

        verify(mockApiClient.get('/dashboard', query: {'range': '7d'}))
            .called(1);
      });
    });

    group('getDashboardDto', () {
      test('should parse DashboardResponseDto correctly', () async {
        when(mockApiClient.get(any, query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: _sampleDashboardJson(),
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.getDashboardDto();

        expect(result, isA<DashboardResponseDto>());
        expect(result.accounts.length, 1);
        expect(result.accounts['acc-1']!.animalsCount, 10);
        expect(result.animalByAge.first.strainName, 'C57BL/6');
        expect(result.animalsSexRatio.length, 2);
        expect(result.animalsToWean.first.physicalTag, 'P001');
      });
    });
  });
}
