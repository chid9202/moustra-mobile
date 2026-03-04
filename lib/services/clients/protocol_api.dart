import 'dart:convert';

import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/services/dtos/animal_protocol_dto.dart';
import 'package:moustra/services/dtos/compliance_summary_dto.dart';
import 'package:moustra/services/dtos/paginated_response_dto.dart';
import 'package:moustra/services/dtos/protocol_alert_dto.dart';
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
    final res = await apiClient.get('$basePath/$protocolUuid');
    return ProtocolDto.fromJson(jsonDecode(res.body));
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
    final res = await apiClient.patch('$basePath/$protocolUuid', body: data);
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
    final res = await apiClient.get('$basePath/$protocolUuid/animals');
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
      '$basePath/$protocolUuid/animals',
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
      '$basePath/$protocolUuid/animals/bulk',
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
      '$basePath/$protocolUuid/animals/$animalUuid',
    );
    if (res.statusCode != 204) {
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
}

final ProtocolApi protocolApi = ProtocolApi();
