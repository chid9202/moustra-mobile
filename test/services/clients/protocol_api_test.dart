import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/animal_protocol_dto.dart';
import 'package:moustra/services/dtos/compliance_summary_dto.dart';
import 'package:moustra/services/dtos/paginated_response_dto.dart';
import 'package:moustra/services/dtos/protocol_alert_dto.dart';
import 'package:moustra/services/dtos/protocol_amendment_dto.dart';
import 'package:moustra/services/dtos/protocol_document_dto.dart';
import 'package:moustra/services/dtos/protocol_dto.dart';

import 'protocol_api_test.mocks.dart';

class TestableProtocolApi {
  final DioApiClient apiClient;
  static const String basePath = '/protocol';

  TestableProtocolApi(this.apiClient);

  Future<PaginatedResponseDto<ProtocolDto>> getProtocols({
    int page = 1,
    int pageSize = 25,
    Map<String, String>? query,
  }) async {
    final mergedQuery = {
      'page': page.toString(),
      'page_size': pageSize.toString(),
      if (query != null) ...query,
    };
    final res = await apiClient.get(basePath, query: mergedQuery);
    final Map<String, dynamic> data = res.data as Map<String, dynamic>;
    return PaginatedResponseDto<ProtocolDto>.fromJson(
      data,
      (j) => ProtocolDto.fromJson(j),
    );
  }

  Future<ProtocolDto> createProtocol(Map<String, dynamic> data) async {
    final res = await apiClient.post(basePath, body: data);
    if (res.statusCode != 201) {
      throw Exception('Failed to create protocol: ${res.data}');
    }
    return ProtocolDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<ProtocolDto> updateProtocol(
    String protocolUuid,
    Map<String, dynamic> data,
  ) async {
    final res = await apiClient.put('$basePath/$protocolUuid', body: data);
    if (res.statusCode != 200) {
      throw Exception('Failed to update protocol: ${res.data}');
    }
    return ProtocolDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteProtocol(String protocolUuid) async {
    final res = await apiClient.delete('$basePath/$protocolUuid');
    if (res.statusCode != 204) {
      throw Exception('Failed to delete protocol: ${res.data}');
    }
  }

  Future<List<AnimalProtocolDto>> getProtocolAnimals(
    String protocolUuid,
  ) async {
    final res = await apiClient.get('$basePath/$protocolUuid/animal');
    if (res.statusCode != null && res.statusCode! >= 400) {
      throw Exception('Failed to load protocol animals: ${res.statusCode}');
    }
    final List<dynamic> data = res.data as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .map((j) => AnimalProtocolDto.fromJson(j))
        .toList();
  }

  Future<AnimalProtocolDto> assignAnimal(
    String protocolUuid,
    Map<String, dynamic> data,
  ) async {
    final res = await apiClient.post(
      '$basePath/$protocolUuid/animal',
      body: data,
    );
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('Failed to assign animal: ${res.data}');
    }
    return AnimalProtocolDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> removeAnimal(String protocolUuid, String animalUuid) async {
    final res = await apiClient.delete(
      '$basePath/$protocolUuid/animal/$animalUuid',
    );
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception('Failed to remove animal: ${res.data}');
    }
  }

  Future<ComplianceSummaryDto> getComplianceSummary() async {
    final res = await apiClient.get('$basePath/compliance/summary');
    if (res.statusCode != null && res.statusCode! >= 400) {
      throw Exception(
        'Failed to load compliance summary: ${res.statusCode} ${res.data}',
      );
    }
    return ComplianceSummaryDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<ProtocolAlertDto>> getAlerts() async {
    final res = await apiClient.get('$basePath/alert');
    if (res.statusCode != null && res.statusCode! >= 400) {
      throw Exception(
        'Failed to load alerts: ${res.statusCode} ${res.data}',
      );
    }
    final List<dynamic> data = res.data as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .map((j) => ProtocolAlertDto.fromJson(j))
        .toList();
  }

  Future<void> acknowledgeAlert(String alertUuid) async {
    final res = await apiClient.post(
      '$basePath/alert/$alertUuid/acknowledge',
    );
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Failed to acknowledge alert: ${res.data}');
    }
  }

  Future<List<ProtocolAmendmentDto>> getProtocolAmendments(
    String protocolUuid,
  ) async {
    final res = await apiClient.get('$basePath/$protocolUuid/amendment');
    if (res.statusCode != null && res.statusCode! >= 400) {
      throw Exception('Failed to load protocol amendments: ${res.statusCode}');
    }
    final List<dynamic> data = res.data as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .map((j) => ProtocolAmendmentDto.fromJson(j))
        .toList();
  }

  Future<ProtocolAmendmentDto> createAmendment(
    String protocolUuid,
    Map<String, dynamic> data,
  ) async {
    final res = await apiClient.post(
      '$basePath/$protocolUuid/amendment',
      body: data,
    );
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('Failed to create amendment: ${res.data}');
    }
    return ProtocolAmendmentDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<ProtocolDocumentDto>> getDocuments(
    String protocolUuid,
  ) async {
    final res = await apiClient.get('$basePath/$protocolUuid/document');
    if (res.statusCode != null && res.statusCode! >= 400) {
      throw Exception('Failed to load documents: ${res.statusCode}');
    }
    final List<dynamic> data = res.data as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .map((j) => ProtocolDocumentDto.fromJson(j))
        .toList();
  }

  Future<void> deleteDocument(
    String protocolUuid,
    String documentUuid,
  ) async {
    final res = await apiClient.delete(
      '$basePath/$protocolUuid/document/$documentUuid',
    );
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception('Failed to delete document: ${res.data}');
    }
  }
}

Map<String, dynamic> _sampleProtocolJson({
  String uuid = 'proto-uuid-1',
  String number = 'IACUC-001',
  String title = 'Test Protocol',
}) =>
    {
      'protocolId': 1,
      'protocolUuid': uuid,
      'protocolNumber': number,
      'title': title,
      'pi': null,
      'status': 'active',
      'approvalDate': '2025-01-01',
      'effectiveDate': '2025-01-01',
      'expirationDate': '2026-01-01',
      'painCategory': 'C',
      'maxAnimalCount': 100,
      'currentAnimalCount': 25,
      'animalCountPct': 0.25,
      'daysUntilExpiry': 180,
      'alertStatus': null,
      'species': 'Mouse',
      'description': 'Test protocol description',
      'fundingSource': null,
      'alertThresholdPct': 80,
      'alertDays': [30, 60, 90],
      'eid': null,
    };

Map<String, dynamic> _sampleAnimalProtocolJson({
  String uuid = 'ap-uuid-1',
}) =>
    {
      'id': 1,
      'animalProtocolUuid': uuid,
      'animal': null,
      'animalUuid': 'animal-uuid-1',
      'physicalTag': 'P001',
      'role': 'experimental',
      'assignedDate': '2025-06-01',
      'removedDate': null,
      'removalReason': null,
      'assignedBy': null,
      'notes': null,
    };

@GenerateMocks([DioApiClient])
void main() {
  group('ProtocolApi Tests', () {
    late MockDioApiClient mockApiClient;
    late TestableProtocolApi api;

    setUp(() {
      mockApiClient = MockDioApiClient();
      api = TestableProtocolApi(mockApiClient);
    });

    group('getProtocols', () {
      test('should return paginated protocols', () async {
        when(mockApiClient.get(any, query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: {
                    'results': [
                      _sampleProtocolJson(uuid: 'p1'),
                      _sampleProtocolJson(uuid: 'p2'),
                    ],
                    'count': 2,
                    'next': null,
                    'previous': null,
                  },
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.getProtocols();

        expect(result.results.length, 2);
        expect(result.count, 2);
        expect(result.results.first.protocolUuid, 'p1');
      });

      test('should pass query params', () async {
        when(mockApiClient.get(any, query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: {
                    'results': [],
                    'count': 0,
                    'next': null,
                    'previous': null,
                  },
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        await api.getProtocols(page: 2, pageSize: 10);

        verify(mockApiClient.get('/protocol', query: {
          'page': '2',
          'page_size': '10',
        })).called(1);
      });
    });

    group('createProtocol', () {
      test('should return created protocol on 201', () async {
        when(mockApiClient.post(any,
                body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: _sampleProtocolJson(),
                  statusCode: 201,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.createProtocol({
          'protocolNumber': 'IACUC-001',
          'title': 'New Protocol',
        });

        expect(result, isA<ProtocolDto>());
        expect(result.protocolNumber, 'IACUC-001');
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
          () => api.createProtocol({}),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('updateProtocol', () {
      test('should return updated protocol on 200', () async {
        when(mockApiClient.put(any,
                body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: _sampleProtocolJson(title: 'Updated'),
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.updateProtocol('proto-uuid-1', {
          'title': 'Updated',
        });

        expect(result.title, 'Updated');
        verify(mockApiClient.put('/protocol/proto-uuid-1',
                body: anyNamed('body'), query: anyNamed('query')))
            .called(1);
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
          () => api.updateProtocol('uuid', {}),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('deleteProtocol', () {
      test('should complete on 204', () async {
        when(mockApiClient.delete(any)).thenAnswer((_) async => Response(
              data: null,
              statusCode: 204,
              requestOptions: RequestOptions(),
            ));

        await api.deleteProtocol('proto-uuid-1');

        verify(mockApiClient.delete('/protocol/proto-uuid-1')).called(1);
      });

      test('should throw on non-204 status', () async {
        when(mockApiClient.delete(any)).thenAnswer((_) async => Response(
              data: 'Error',
              statusCode: 400,
              requestOptions: RequestOptions(),
            ));

        expect(
          () => api.deleteProtocol('uuid'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getProtocolAnimals', () {
      test('should return list of animal protocols', () async {
        when(mockApiClient.get(any, query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: [
                    _sampleAnimalProtocolJson(uuid: 'ap1'),
                    _sampleAnimalProtocolJson(uuid: 'ap2'),
                  ],
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.getProtocolAnimals('proto-uuid-1');

        expect(result.length, 2);
        expect(result.first.animalProtocolUuid, 'ap1');
        verify(mockApiClient.get('/protocol/proto-uuid-1/animal',
                query: anyNamed('query')))
            .called(1);
      });

      test('should throw on 4xx status', () async {
        when(mockApiClient.get(any, query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: 'Error',
                  statusCode: 404,
                  requestOptions: RequestOptions(),
                ));

        expect(
          () => api.getProtocolAnimals('bad-uuid'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('assignAnimal', () {
      test('should return assigned animal on 201', () async {
        when(mockApiClient.post(any,
                body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: _sampleAnimalProtocolJson(),
                  statusCode: 201,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.assignAnimal('proto-uuid-1', {
          'animalUuid': 'animal-uuid-1',
          'role': 'experimental',
        });

        expect(result.physicalTag, 'P001');
      });
    });

    group('removeAnimal', () {
      test('should complete on 204', () async {
        when(mockApiClient.delete(any)).thenAnswer((_) async => Response(
              data: null,
              statusCode: 204,
              requestOptions: RequestOptions(),
            ));

        await api.removeAnimal('proto-uuid-1', 'animal-uuid-1');

        verify(mockApiClient.delete(
                '/protocol/proto-uuid-1/animal/animal-uuid-1'))
            .called(1);
      });
    });

    group('getComplianceSummary', () {
      test('should return compliance summary', () async {
        when(mockApiClient.get(any, query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: {
                    'totalActive': 5,
                    'expiring30d': 1,
                    'expiring60d': 2,
                    'expiring90d': 3,
                    'expiredUnresolved': 0,
                    'overAnimalLimit': 0,
                    'nearAnimalLimit': 1,
                    'animalsWithoutProtocol': 10,
                    'unacknowledgedAlerts': 2,
                  },
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.getComplianceSummary();

        expect(result.totalActive, 5);
        expect(result.animalsWithoutProtocol, 10);
        verify(mockApiClient.get('/protocol/compliance/summary',
                query: anyNamed('query')))
            .called(1);
      });
    });

    group('getAlerts', () {
      test('should return list of alerts', () async {
        when(mockApiClient.get(any, query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: [
                    {
                      'id': 1,
                      'alertUuid': 'alert-1',
                      'alertType': 'expiration',
                      'message': 'Protocol expiring soon',
                      'triggeredAt': '2025-06-01T00:00:00Z',
                      'acknowledgedAt': null,
                      'isResolved': false,
                    },
                  ],
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.getAlerts();

        expect(result.length, 1);
        expect(result.first.alertType, 'expiration');
      });
    });

    group('acknowledgeAlert', () {
      test('should complete on 200', () async {
        when(mockApiClient.post(any,
                body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: null,
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        await api.acknowledgeAlert('alert-1');

        verify(mockApiClient.post('/protocol/alert/alert-1/acknowledge',
                body: anyNamed('body'), query: anyNamed('query')))
            .called(1);
      });
    });

    group('getProtocolAmendments', () {
      test('should return list of amendments', () async {
        when(mockApiClient.get(any, query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: [
                    {
                      'amendmentUuid': 'amend-1',
                      'amendmentNumber': 'A-001',
                      'amendmentType': 'modification',
                      'description': 'Updated animal count',
                      'approvedDate': '2025-06-01',
                      'effectiveDate': '2025-06-15',
                      'status': 'approved',
                    },
                  ],
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.getProtocolAmendments('proto-uuid-1');

        expect(result.length, 1);
        expect(result.first.amendmentNumber, 'A-001');
      });
    });

    group('createAmendment', () {
      test('should return created amendment', () async {
        when(mockApiClient.post(any,
                body: anyNamed('body'), query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: {
                    'amendmentUuid': 'amend-new',
                    'amendmentNumber': 'A-002',
                    'amendmentType': 'modification',
                    'description': 'New amendment',
                    'approvedDate': null,
                    'effectiveDate': null,
                    'status': 'pending',
                  },
                  statusCode: 201,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.createAmendment('proto-uuid-1', {
          'amendmentType': 'modification',
          'description': 'New amendment',
        });

        expect(result.amendmentUuid, 'amend-new');
        expect(result.status, 'pending');
      });
    });

    group('getDocuments', () {
      test('should return list of documents', () async {
        when(mockApiClient.get(any, query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  data: [
                    {
                      'documentUuid': 'doc-1',
                      'documentType': 'approval_letter',
                      'fileLink': 'https://example.com/doc.pdf',
                      'filename': 'approval.pdf',
                      'uploadedBy': null,
                      'uploadedAt': '2025-06-01T00:00:00Z',
                      'description': 'Approval letter',
                    },
                  ],
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        final result = await api.getDocuments('proto-uuid-1');

        expect(result.length, 1);
        expect(result.first.documentUuid, 'doc-1');
      });
    });

    group('deleteDocument', () {
      test('should complete on 204', () async {
        when(mockApiClient.delete(any)).thenAnswer((_) async => Response(
              data: null,
              statusCode: 204,
              requestOptions: RequestOptions(),
            ));

        await api.deleteDocument('proto-uuid-1', 'doc-1');

        verify(mockApiClient.delete('/protocol/proto-uuid-1/document/doc-1'))
            .called(1);
      });
    });
  });
}
