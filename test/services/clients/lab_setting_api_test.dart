import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/lab_setting_dto.dart';

import 'lab_setting_api_test.mocks.dart';

class TestableLabSettingApi {
  final DioApiClient apiClient;

  TestableLabSettingApi(this.apiClient);

  Future<LabSettingDto> getLabSetting() async {
    final res = await apiClient.get('/lab/setting');
    if (res.statusCode != 200) {
      throw Exception('Failed to get lab setting: ${res.data}');
    }
    final Map<String, dynamic> data = res.data as Map<String, dynamic>;
    return LabSettingDto.fromJson(data);
  }

  Future<void> updateLabSetting(LabSettingDto setting) async {
    final res = await apiClient.put('/lab/setting', body: setting.toJson());
    if (res.statusCode != 200) {
      throw Exception('Failed to update lab setting: ${res.data}');
    }
  }

  Future<void> postErrorReport({
    String? subject,
    required String message,
  }) async {
    final res = await apiClient.post('/error-report', body: {
      'subject': subject ?? '',
      'message': message,
    });
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Failed to submit feedback: ${res.data}');
    }
  }
}

Map<String, dynamic> _sampleLabSettingJson() => {
      'defaultRackWidth': 18,
      'defaultRackHeight': 12,
      'defaultWeanDate': 21,
      'useEid': false,
      'labName': 'Test Lab',
      'owner': null,
    };

@GenerateMocks([DioApiClient])
void main() {
  group('LabSettingApi Tests', () {
    late MockDioApiClient mockApiClient;
    late TestableLabSettingApi api;

    setUp(() {
      mockApiClient = MockDioApiClient();
      api = TestableLabSettingApi(mockApiClient);
    });

    group('getLabSetting', () {
      test('should return LabSettingDto on 200', () async {
        when(mockApiClient.get(any, query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: _sampleLabSettingJson(),
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.getLabSetting();

        expect(result.labName, 'Test Lab');
        expect(result.defaultRackWidth, 18);
        expect(result.useEid, false);
        verify(mockApiClient.get('/lab/setting', query: anyNamed('query')))
            .called(1);
      });

      test('should throw on non-200 status', () async {
        when(mockApiClient.get(any, query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: 'Error',
                  statusCode: 500,
                  requestOptions: RequestOptions(),
                ));

        expect(() => api.getLabSetting(), throwsA(isA<Exception>()));
      });
    });

    group('updateLabSetting', () {
      test('should complete on 200', () async {
        when(mockApiClient.put(any, body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: {},
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        final setting = LabSettingDto(
          useEid: true,
          labName: 'Updated Lab',
        );

        await api.updateLabSetting(setting);

        verify(mockApiClient.put('/lab/setting',
                body: setting.toJson(), query: anyNamed('query')))
            .called(1);
      });

      test('should throw on non-200 status', () async {
        when(mockApiClient.put(any, body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: 'Error',
                  statusCode: 400,
                  requestOptions: RequestOptions(),
                ));

        final setting = LabSettingDto(useEid: false, labName: 'Lab');
        expect(() => api.updateLabSetting(setting), throwsA(isA<Exception>()));
      });
    });

    group('postErrorReport', () {
      test('should complete on 200', () async {
        when(mockApiClient.post(any, body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: {},
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        await api.postErrorReport(
          subject: 'Bug',
          message: 'Something broke',
        );

        verify(mockApiClient.post(
          '/error-report',
          body: {'subject': 'Bug', 'message': 'Something broke'},
          query: anyNamed('query'),
        )).called(1);
      });

      test('should throw on non-200/201 status', () async {
        when(mockApiClient.post(any, body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: 'Error',
                  statusCode: 500,
                  requestOptions: RequestOptions(),
                ));

        expect(
          () => api.postErrorReport(message: 'err'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
