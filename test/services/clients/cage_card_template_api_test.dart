import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/cage_card_template_dto.dart';

import 'cage_card_template_api_test.mocks.dart';

class TestableCageCardTemplateApi {
  final DioApiClient apiClient;
  static const String basePath = '/cage-card-template';

  TestableCageCardTemplateApi(this.apiClient);

  Future<List<CageCardTemplateDto>> getTemplates() async {
    final res = await apiClient.get(basePath);
    final List<dynamic> data = res.data as List<dynamic>;
    return data
        .map((j) => CageCardTemplateDto.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<CageCardTemplateDto> setDefaultTemplate(String templateUuid) async {
    final res = await apiClient.put(
      '$basePath/$templateUuid',
      body: {'isDefault': true},
    );
    return CageCardTemplateDto.fromJson(res.data as Map<String, dynamic>);
  }
}

Map<String, dynamic> _sampleTemplateJson({
  String uuid = 'tmpl-uuid-1',
  String name = 'Default Template',
  bool isDefault = false,
}) =>
    {
      'cageCardTemplateUuid': uuid,
      'name': name,
      'cardSize': '3x5',
      'enabledFields': ['cageTag', 'strain'],
      'fieldOrder': ['cageTag', 'strain'],
      'codeConfig': null,
      'style': null,
      'isDefault': isDefault,
      'owner': null,
      'createdDate': '2025-01-01T00:00:00Z',
      'updatedDate': null,
    };

@GenerateMocks([DioApiClient])
void main() {
  group('CageCardTemplateApi Tests', () {
    late MockDioApiClient mockApiClient;
    late TestableCageCardTemplateApi api;

    setUp(() {
      mockApiClient = MockDioApiClient();
      api = TestableCageCardTemplateApi(mockApiClient);
    });

    group('getTemplates', () {
      test('should return list of templates', () async {
        when(mockApiClient.get(any, query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: [
                    _sampleTemplateJson(uuid: 't1', isDefault: true),
                    _sampleTemplateJson(uuid: 't2', name: 'Custom'),
                  ],
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.getTemplates();

        expect(result.length, 2);
        expect(result.first.cageCardTemplateUuid, 't1');
        expect(result.first.isDefault, true);
        expect(result.last.name, 'Custom');
        verify(mockApiClient.get('/cage-card-template',
                query: anyNamed('query')))
            .called(1);
      });

      test('should return empty list when none exist', () async {
        when(mockApiClient.get(any, query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: [],
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.getTemplates();

        expect(result, isEmpty);
      });
    });

    group('setDefaultTemplate', () {
      test('should return updated template', () async {
        when(mockApiClient.put(any,
                body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: _sampleTemplateJson(uuid: 't1', isDefault: true),
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.setDefaultTemplate('t1');

        expect(result.isDefault, true);
        verify(mockApiClient.put(
          '/cage-card-template/t1',
          body: {'isDefault': true},
          query: anyNamed('query'),
        )).called(1);
      });
    });
  });
}
