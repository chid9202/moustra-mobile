import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/report_dto.dart';

import 'report_api_test.mocks.dart';

class TestableReportApi {
  final DioApiClient apiClient;
  static const String basePath = '/reports';

  TestableReportApi(this.apiClient);

  Future<List<WeeklyReportSummaryDto>> getWeeklyReports() async {
    final res = await apiClient.get(basePath);
    final List<dynamic> data = res.data as List<dynamic>;
    return data
        .map((e) =>
            WeeklyReportSummaryDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

Map<String, dynamic> _sampleReportJson({
  String uuid = 'report-uuid-1',
  String date = '2025-06-01',
}) =>
    {
      'reportUuid': uuid,
      'date': date,
      'createdAt': '2025-06-01T10:00:00Z',
    };

@GenerateMocks([DioApiClient])
void main() {
  group('ReportApi Tests', () {
    late MockDioApiClient mockApiClient;
    late TestableReportApi api;

    setUp(() {
      mockApiClient = MockDioApiClient();
      api = TestableReportApi(mockApiClient);
    });

    group('getWeeklyReports', () {
      test('should return list of reports', () async {
        when(mockApiClient.get(any, query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: [
                    _sampleReportJson(uuid: 'r1', date: '2025-06-01'),
                    _sampleReportJson(uuid: 'r2', date: '2025-06-08'),
                  ],
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.getWeeklyReports();

        expect(result.length, 2);
        expect(result.first.reportUuid, 'r1');
        expect(result.last.date, '2025-06-08');
        verify(mockApiClient.get('/reports', query: anyNamed('query')))
            .called(1);
      });

      test('should return empty list when no reports', () async {
        when(mockApiClient.get(any, query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: [],
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.getWeeklyReports();

        expect(result, isEmpty);
      });
    });
  });
}
