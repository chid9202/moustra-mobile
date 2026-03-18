import 'dart:io';

import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/animal_protocol_dto.dart';
import 'package:moustra/services/dtos/compliance_summary_dto.dart';
import 'package:moustra/services/dtos/paginated_response_dto.dart';
import 'package:moustra/services/dtos/protocol_alert_dto.dart';
import 'package:moustra/services/dtos/protocol_amendment_dto.dart';
import 'package:moustra/services/dtos/protocol_document_dto.dart';
import 'package:moustra/services/dtos/protocol_dto.dart';

class ProtocolApi {
  static const String basePath = '/protocol';

  /// List protocols with optional filtering
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
    final res = await dioApiClient.get(basePath, query: mergedQuery);
    final Map<String, dynamic> data = res.data as Map<String, dynamic>;
    return PaginatedResponseDto<ProtocolDto>.fromJson(
      data,
      (j) => ProtocolDto.fromJson(j),
    );
  }

  /// Get a single protocol by UUID
  Future<ProtocolDto> getProtocol(String protocolUuid) async {
    // Detail endpoint (/protocol/{uuid}) is not available on backend,
    // so fetch from list and find the matching protocol.
    final res = await dioApiClient.get(basePath, query: {
      'page_size': '100',
    });
    if (res.statusCode != null && res.statusCode! >= 400) {
      throw Exception(
        'Failed to load protocol ($protocolUuid): ${res.statusCode} ${res.data}',
      );
    }
    final data = res.data as Map<String, dynamic>;
    final paginated = PaginatedResponseDto<ProtocolDto>.fromJson(
      data,
      (j) => ProtocolDto.fromJson(j),
    );
    final match = paginated.results.where(
      (p) => p.protocolUuid == protocolUuid,
    );
    if (match.isEmpty) {
      throw Exception('Protocol not found: $protocolUuid');
    }
    return match.first;
  }

  /// Create a new protocol
  Future<ProtocolDto> createProtocol(Map<String, dynamic> data) async {
    final res = await dioApiClient.post(basePath, body: data);
    if (res.statusCode != 201) {
      throw Exception('Failed to create protocol: ${res.data}');
    }
    return ProtocolDto.fromJson(res.data as Map<String, dynamic>);
  }

  /// Update an existing protocol
  Future<ProtocolDto> updateProtocol(
    String protocolUuid,
    Map<String, dynamic> data,
  ) async {
    final res = await dioApiClient.put('$basePath/$protocolUuid', body: data);
    if (res.statusCode != 200) {
      throw Exception('Failed to update protocol: ${res.data}');
    }
    return ProtocolDto.fromJson(res.data as Map<String, dynamic>);
  }

  /// Delete (archive) a protocol
  Future<void> deleteProtocol(String protocolUuid) async {
    final res = await dioApiClient.delete('$basePath/$protocolUuid');
    if (res.statusCode != 204) {
      throw Exception('Failed to delete protocol: ${res.data}');
    }
  }

  /// Get animals assigned to a protocol
  Future<List<AnimalProtocolDto>> getProtocolAnimals(
    String protocolUuid,
  ) async {
    final res = await dioApiClient.get('$basePath/$protocolUuid/animal');
    if (res.statusCode != null && res.statusCode! >= 400) {
      throw Exception('Failed to load protocol animals: ${res.statusCode}');
    }
    final List<dynamic> data = res.data as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .map((j) => AnimalProtocolDto.fromJson(j))
        .toList();
  }

  /// Assign a single animal to a protocol
  Future<AnimalProtocolDto> assignAnimal(
    String protocolUuid,
    Map<String, dynamic> data,
  ) async {
    final res = await dioApiClient.post(
      '$basePath/$protocolUuid/animal',
      body: data,
    );
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('Failed to assign animal: ${res.data}');
    }
    return AnimalProtocolDto.fromJson(res.data as Map<String, dynamic>);
  }

  /// Bulk assign animals to a protocol
  Future<List<AnimalProtocolDto>> bulkAssignAnimals(
    String protocolUuid,
    Map<String, dynamic> data,
  ) async {
    final res = await dioApiClient.post(
      '$basePath/$protocolUuid/animal/bulk',
      body: data,
    );
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('Failed to bulk assign animals: ${res.data}');
    }
    final List<dynamic> list = res.data as List<dynamic>;
    return list
        .whereType<Map<String, dynamic>>()
        .map((j) => AnimalProtocolDto.fromJson(j))
        .toList();
  }

  /// Remove an animal from a protocol
  Future<void> removeAnimal(String protocolUuid, String animalUuid) async {
    final res = await dioApiClient.delete(
      '$basePath/$protocolUuid/animal/$animalUuid',
    );
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception('Failed to remove animal: ${res.data}');
    }
  }

  /// Assign all animals in a cage to a protocol
  Future<List<AnimalProtocolDto>> assignCage(
    String protocolUuid,
    String cageUuid,
  ) async {
    final res = await dioApiClient.post(
      '$basePath/$protocolUuid/cages/$cageUuid/assign',
    );
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('Failed to assign cage: ${res.data}');
    }
    final List<dynamic> list = res.data as List<dynamic>;
    return list
        .whereType<Map<String, dynamic>>()
        .map((j) => AnimalProtocolDto.fromJson(j))
        .toList();
  }

  /// Get compliance summary
  Future<ComplianceSummaryDto> getComplianceSummary() async {
    final res = await dioApiClient.get('$basePath/compliance/summary');
    return ComplianceSummaryDto.fromJson(res.data as Map<String, dynamic>);
  }

  /// Get active alerts
  Future<List<ProtocolAlertDto>> getAlerts() async {
    final res = await dioApiClient.get('$basePath/alerts');
    final List<dynamic> data = res.data as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .map((j) => ProtocolAlertDto.fromJson(j))
        .toList();
  }

  /// Acknowledge an alert
  Future<void> acknowledgeAlert(String alertUuid) async {
    final res = await dioApiClient.post(
      '$basePath/alerts/$alertUuid/acknowledge',
    );
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Failed to acknowledge alert: ${res.data}');
    }
  }
  /// Get amendments for a protocol
  Future<List<ProtocolAmendmentDto>> getProtocolAmendments(
    String protocolUuid,
  ) async {
    final res = await dioApiClient.get('$basePath/$protocolUuid/amendment');
    if (res.statusCode != null && res.statusCode! >= 400) {
      throw Exception('Failed to load protocol amendments: ${res.statusCode}');
    }
    final List<dynamic> data = res.data as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .map((j) => ProtocolAmendmentDto.fromJson(j))
        .toList();
  }
  /// Create an amendment for a protocol
  Future<ProtocolAmendmentDto> createAmendment(
    String protocolUuid,
    Map<String, dynamic> data,
  ) async {
    final res = await dioApiClient.post(
      '$basePath/$protocolUuid/amendment',
      body: data,
    );
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('Failed to create amendment: ${res.data}');
    }
    return ProtocolAmendmentDto.fromJson(res.data as Map<String, dynamic>);
  }

  /// Apply a recorded amendment
  Future<void> applyAmendment(
    String protocolUuid,
    String amendmentUuid,
  ) async {
    final res = await dioApiClient.post(
      '$basePath/$protocolUuid/amendment/$amendmentUuid/apply',
    );
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Failed to apply amendment: ${res.data}');
    }
  }

  /// Get documents for a protocol
  Future<List<ProtocolDocumentDto>> getDocuments(
    String protocolUuid,
  ) async {
    final res = await dioApiClient.get('$basePath/$protocolUuid/document');
    if (res.statusCode != null && res.statusCode! >= 400) {
      throw Exception('Failed to load documents: ${res.statusCode}');
    }
    final List<dynamic> data = res.data as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .map((j) => ProtocolDocumentDto.fromJson(j))
        .toList();
  }

  /// Upload a document to a protocol
  Future<ProtocolDocumentDto> uploadDocument(
    String protocolUuid, {
    required File file,
    required String documentType,
    String? description,
  }) async {
    final fields = <String, String>{
      'document_type': documentType,
    };
    if (description != null && description.trim().isNotEmpty) {
      fields['description'] = description.trim();
    }
    final res = await dioApiClient.uploadFile(
      '$basePath/$protocolUuid/document',
      file: file,
      fields: fields,
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Failed to upload document: ${res.data}');
    }
    return ProtocolDocumentDto.fromJson(res.data as Map<String, dynamic>);
  }

  /// Delete a document from a protocol
  Future<void> deleteDocument(
    String protocolUuid,
    String documentUuid,
  ) async {
    final res = await dioApiClient.delete(
      '$basePath/$protocolUuid/document/$documentUuid',
    );
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception('Failed to delete document: ${res.data}');
    }
  }
}

final ProtocolApi protocolApi = ProtocolApi();
