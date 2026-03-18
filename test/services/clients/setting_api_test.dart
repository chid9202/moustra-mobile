import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/setting_dto.dart';

import 'setting_api_test.mocks.dart';

class TestableSettingApi {
  final DioApiClient apiClient;

  TestableSettingApi(this.apiClient);

  Future<SettingDto> getSetting() async {
    final res = await apiClient.get('/store/Settings');
    if (res.statusCode != 200) {
      throw Exception('Failed to get setting: ${res.data}');
    }
    final Map<String, dynamic> data = res.data as Map<String, dynamic>;
    return SettingDto.fromJson(data);
  }

  Future<SettingDto> updateSetting(SettingDto setting) async {
    final res = await apiClient.put('/setting', body: setting.toJson());
    if (res.statusCode != 200) {
      throw Exception('Failed to update setting: ${res.data}');
    }
    final Map<String, dynamic> data = res.data as Map<String, dynamic>;
    return SettingDto.fromJson(data);
  }

  Future<SettingDto> updateAccountSetting(
    AccountSettingDto accountSetting,
  ) async {
    final res = await apiClient.put(
      '/setting/account',
      body: accountSetting.toJson(),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to update account setting: ${res.data}');
    }
    final Map<String, dynamic> data = res.data as Map<String, dynamic>;
    return SettingDto.fromJson(data);
  }

  Future<SettingDto> updateLabSetting(LabSettingStoreDto labSetting) async {
    final res = await apiClient.put('/setting/lab', body: labSetting.toJson());
    if (res.statusCode != 200) {
      throw Exception('Failed to update lab setting: ${res.data}');
    }
    final Map<String, dynamic> data = res.data as Map<String, dynamic>;
    return SettingDto.fromJson(data);
  }
}

Map<String, dynamic> _sampleSettingJson() => {
      'accountSetting': {
        'enableDailyReport': true,
        'onboardingTour': false,
        'animalCreationTour': false,
        'useComment': true,
        'enableCustomWeanDate': true,
        'enableItemUpdateNotifications': false,
      },
      'labSetting': {
        'defaultRackWidth': 18,
        'defaultRackHeight': 12,
        'defaultWeanDate': 21,
        'useEid': false,
      },
    };

@GenerateMocks([DioApiClient])
void main() {
  group('SettingApi Tests', () {
    late MockDioApiClient mockApiClient;
    late TestableSettingApi api;

    setUp(() {
      mockApiClient = MockDioApiClient();
      api = TestableSettingApi(mockApiClient);
    });

    group('getSetting', () {
      test('should return SettingDto on 200', () async {
        when(mockApiClient.get(any, query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: _sampleSettingJson(),
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.getSetting();

        expect(result.accountSetting.enableDailyReport, true);
        expect(result.labSetting.defaultWeanDate, 21);
        verify(mockApiClient.get('/store/Settings', query: anyNamed('query')))
            .called(1);
      });

      test('should throw on non-200 status', () async {
        when(mockApiClient.get(any, query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: 'Error',
                  statusCode: 404,
                  requestOptions: RequestOptions(),
                ));

        expect(() => api.getSetting(), throwsA(isA<Exception>()));
      });
    });

    group('updateSetting', () {
      test('should return updated SettingDto on 200', () async {
        when(mockApiClient.put(any, body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: _sampleSettingJson(),
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        final setting = SettingDto.fromJson(_sampleSettingJson());
        final result = await api.updateSetting(setting);

        expect(result, isA<SettingDto>());
        verify(mockApiClient.put('/setting',
                body: anyNamed('body'), query: anyNamed('query')))
            .called(1);
      });

      test('should throw on non-200 status', () async {
        when(mockApiClient.put(any, body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: 'Error',
                  statusCode: 400,
                  requestOptions: RequestOptions(),
                ));

        final setting = SettingDto.fromJson(_sampleSettingJson());
        expect(() => api.updateSetting(setting), throwsA(isA<Exception>()));
      });
    });

    group('updateAccountSetting', () {
      test('should return SettingDto on 200', () async {
        when(mockApiClient.put(any, body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: _sampleSettingJson(),
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        final accountSetting = AccountSettingDto(
          enableDailyReport: true,
          onboardingTour: false,
          animalCreationTour: false,
          useComment: true,
          enableCustomWeanDate: true,
        );

        final result = await api.updateAccountSetting(accountSetting);

        expect(result, isA<SettingDto>());
        verify(mockApiClient.put('/setting/account',
                body: anyNamed('body'), query: anyNamed('query')))
            .called(1);
      });
    });

    group('updateLabSetting', () {
      test('should return SettingDto on 200', () async {
        when(mockApiClient.put(any, body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: _sampleSettingJson(),
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        final labSetting = LabSettingStoreDto(
          defaultRackWidth: 18,
          defaultRackHeight: 12,
          defaultWeanDate: 21,
          useEid: false,
        );

        final result = await api.updateLabSetting(labSetting);

        expect(result, isA<SettingDto>());
        verify(mockApiClient.put('/setting/lab',
                body: anyNamed('body'), query: anyNamed('query')))
            .called(1);
      });
    });
  });
}
