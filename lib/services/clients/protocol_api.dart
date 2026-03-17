import 'dart:convert';
import 'dart:io';

import 'package:moustra/services/clients/api_client.dart';
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
    final res = await apiClient.get(basePath, query: mergedQuery);
    final Map<String, dynamic> data = jsonDecode(res.body);
    return PaginatedResponseDto<ProtocolDto>.fromJson(
      data,
      (j) => ProtocolDto.fromJson(j),
    );
  }

  /// Get a single protocol by UUID
  Future<ProtocolDto> getProtocol(String protocolUuid) async {
    // Detail endpoint (/protocol/{uuid}) is not available on backend,
    // so fetch from list and find the matching protocol.
    final res = await apiClient.get(basePath, query: {
      'page_size': '100',
    });
    if (res.statusCode >= 400) {
      throw Exception(
        'Failed to load protocol ($protocolUuid): ${res.statusCode} ${res.body}',
      );
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
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
    final res = await apiClient.post(basePath, body: data);
    if (res.statusCode != 201) {
      throw Exception('Failed to create protocol: ${res.body}');
    }
    return ProtocolDto.fromJson(jsonDecode(res.body));
  }

  /// Update an existing protocol
  Future<ProtocolDto> updateProtocol(
    String protocolUuid,
    Map<String, dynamic> data,
  ) async {
    final res = await apiClient.put('$basePath/$protocolUuid', body: data);
    if (res.statusCode != 200) {
      throw Exception('Failed to update protocol: ${res.body}');
    }
    return ProtocolDto.fromJson(jsonDecode(res.body));
  }

  /// Delete (archive) a protocol
  Future<void> deleteProtocol(String protocolUuid) async {
    final res = await apiClient.delete('$basePath/$protocolUuid');
    if (res.statusCode != 204) {
      throw Exception('Failed to delete protocol: ${res.body}');
    }
  }

  /// Get animals assigned to a protocol
  Future<List<AnimalProtocolDto>> getProtocolAnimals(
    String protocolUuid,
  ) async {
    final res = await apiClient.get('$basePath/$protocolUuid/animal');
    if (res.statusCode >= 400) {
      throw Exception('Failed to load protocol animals: ${res.statusCode}');
    }
    final List<dynamic> data = jsonDecode(res.body);
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
    final res = await apiClient.post(
      '$basePath/$protocolUuid/animal',
      body: data,
    );
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('Failed to assign animal: ${res.body}');
    }
    return AnimalProtocolDto.fromJson(jsonDecode(res.body));
  }

  /// Bulk assign animals to a protocol
  Future<List<AnimalProtocolDto>> bulkAssignAnimals(
    String protocolUuid,
    Map<String, dynamic> data,
  ) async {
    final res = await apiClient.post(
      '$basePath/$protocolUuid/animal/bulk',
      body: data,
    );
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('Failed to bulk assign animals: ${res.body}');
    }
    final List<dynamic> list = jsonDecode(res.body);
    return list
        .whereType<Map<String, dynamic>>()
        .map((j) => AnimalProtocolDto.fromJson(j))
        .toList();
  }

  /// Remove an animal from a protocol
  Future<void> removeAnimal(String protocolUuid, String animalUuid) async {
    final res = await apiClient.delete(
      '$basePath/$protocolUuid/animal/$animalUuid',
    );
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception('Failed to remove animal: ${res.body}');
    }
  }

  /// Assign all animals in a cage to a protocol
  Future<List<AnimalProtocolDto>> assignCage(
    String protocolUuid,
    String cageUuid,
  ) async {
    final res = await apiClient.post(
      '$basePath/$protocolUuid/cages/$cageUuid/assign',
    );
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('Failed to assign cage: ${res.body}');
    }
    final List<dynamic> list = jsonDecode(res.body);
    return list
        .whereType<Map<String, dynamic>>()
        .map((j) => AnimalProtocolDto.fromJson(j))
        .toList();
  }

  /// Get compliance summary
  Future<ComplianceSummaryDto> getComplianceSummary() async {
    final res = await apiClient.get('$basePath/compliance/summary');
    return ComplianceSummaryDto.fromJson(jsonDecode(res.body));
  }

  /// Get active alerts
  Future<List<ProtocolAlertDto>> getAlerts() async {
    final res = await apiClient.get('$basePath/alerts');
    final List<dynamic> data = jsonDecode(res.body);
    return data
        .whereType<Map<String, dynamic>>()
        .map((j) => ProtocolAlertDto.fromJson(j))
        .toList();
  }

  /// Acknowledge an alert
  Future<void> acknowledgeAlert(String alertUuid) async {
    final res = await apiClient.post(
      '$basePath/alerts/$alertUuid/acknowledge',
    );
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Failed to acknowledge alert: ${res.body}');
    }
  }
  /// Get amendments for a protocol
  Future<List<ProtocolAmendmentDto>> getProtocolAmendments(
    String protocolUuid,
  ) async {
    final res = await apiClient.get('$basePath/$protocolUuid/amendment');
    if (res.statusCode >= 400) {
      throw Exception('Failed to load protocol amendments: ${res.statusCode}');
    }
    final List<dynamic> data = jsonDecode(res.body);
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
    final res = await apiClient.post(
      '$basePath/$protocolUuid/amendment',
      body: data,
    );
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('Failed to create amendment: ${res.body}');
    }
    return ProtocolAmendmentDto.fromJson(jsonDecode(res.body));
  }

  /// Apply a recorded amendment
  Future<void> applyAmendment(
    String protocolUuid,
    String amendmentUuid,
  ) async {
    final res = await apiClient.post(
      '$basePath/$protocolUuid/amendment/$amendmentUuid/apply',
    );
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Failed to apply amendment: ${res.body}');
    }
  }

  /// Get documents for a protocol
  Future<List<ProtocolDocumentDto>> getDocuments(
    String protocolUuid,
  ) async {
    final res = await apiClient.get('$basePath/$protocolUuid/document');
    if (res.statusCode >= 400) {
      throw Exception('Failed to load documents: ${res.statusCode}');
    }
    final List<dynamic> data = jsonDecode(res.body);
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
    final res = await apiClient.uploadFile(
      '$basePath/$protocolUuid/document',
      file: file,
      fields: fields,
    );
    final body = await res.stream.bytesToString();
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Failed to upload document: $body');
    }
    return ProtocolDocumentDto.fromJson(jsonDecode(body));
  }

  /// Delete a document from a protocol
  Future<void> deleteDocument(
    String protocolUuid,
    String documentUuid,
  ) async {
    final res = await apiClient.delete(
      '$basePath/$protocolUuid/document/$documentUuid',
    );
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception('Failed to delete document: ${res.body}');
    }
  }
}

final ProtocolApi protocolApi = ProtocolApi();
