import 'dart:convert';

import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/services/dtos/paginated_response_dto.dart';
import 'package:moustra/services/dtos/plug_event_dto.dart';
import 'package:moustra/services/dtos/plug_check_dto.dart';
import 'package:moustra/services/dtos/post_plug_check_dto.dart';
import 'package:moustra/services/dtos/post_plug_event_dto.dart';
import 'package:moustra/services/dtos/put_plug_event_dto.dart';
import 'package:moustra/services/dtos/record_outcome_dto.dart';
import 'package:moustra/services/models/list_query_params.dart';

class PlugApi {
  static const String plugEventPath = '/plug-event';
  static const String plugCheckPath = '/plug-check';

  Future<PaginatedResponseDto<PlugEventDto>> getPlugEventsPage({
    required ListQueryParams params,
  }) async {
    final queryString = params.buildQueryString();
    final res = await apiClient.getWithQueryString(
      plugEventPath,
      queryString: queryString,
    );
    final Map<String, dynamic> data = jsonDecode(res.body);
    return PaginatedResponseDto<PlugEventDto>.fromJson(
      data,
      (j) => PlugEventDto.fromJson(j),
    );
  }

  Future<PlugEventDto> getPlugEvent(String uuid) async {
    final res = await apiClient.get('$plugEventPath/$uuid');
    return PlugEventDto.fromJson(jsonDecode(res.body));
  }

  Future<PaginatedResponseDto<PlugEventDto>> getActivePlugEvents({
    int page = 1,
    int pageSize = 25,
  }) async {
    final res = await apiClient.get(plugEventPath, query: {
      'page': page.toString(),
      'page_size': pageSize.toString(),
      'filter': 'is_active',
      'op': 'equals',
      'value': 'true',
    });
    final Map<String, dynamic> data = jsonDecode(res.body);
    return PaginatedResponseDto<PlugEventDto>.fromJson(
      data,
      (j) => PlugEventDto.fromJson(j),
    );
  }

  Future<PaginatedResponseDto<PlugEventDto>> getDueSoonPlugEvents({
    int days = 3,
    int page = 1,
    int pageSize = 25,
  }) async {
    final res = await apiClient.get(plugEventPath, query: {
      'page': page.toString(),
      'page_size': pageSize.toString(),
      'filter': 'due_soon',
      'op': 'equals',
      'value': days.toString(),
    });
    final Map<String, dynamic> data = jsonDecode(res.body);
    return PaginatedResponseDto<PlugEventDto>.fromJson(
      data,
      (j) => PlugEventDto.fromJson(j),
    );
  }

  Future<PlugEventDto> createPlugEvent(PostPlugEventDto dto) async {
    final res = await apiClient.post(plugEventPath, body: dto.toJson());
    if (res.statusCode != 201) {
      throw Exception('Failed to create plug event: ${res.body}');
    }
    return PlugEventDto.fromJson(jsonDecode(res.body));
  }

  Future<PlugEventDto> updatePlugEvent(
    String uuid,
    PutPlugEventDto dto,
  ) async {
    final res = await apiClient.put('$plugEventPath/$uuid', body: dto.toJson());
    if (res.statusCode >= 400) {
      throw Exception('Failed to update plug event: ${res.body}');
    }
    return PlugEventDto.fromJson(jsonDecode(res.body));
  }

  Future<void> deletePlugEvent(String uuid) async {
    final res = await apiClient.delete('$plugEventPath/$uuid');
    if (res.statusCode >= 400) {
      throw Exception('Failed to delete plug event: ${res.body}');
    }
  }

  Future<PlugEventDto> recordOutcome(
    String uuid,
    RecordOutcomeDto dto,
  ) async {
    final res = await apiClient.post(
      '$plugEventPath/$uuid/outcome',
      body: dto.toJson(),
    );
    if (res.statusCode >= 400) {
      throw Exception('Failed to record outcome: ${res.body}');
    }
    return PlugEventDto.fromJson(jsonDecode(res.body));
  }

  Future<List<PlugCheckDto>> batchCreatePlugChecks(
    List<PostPlugCheckDto> checks,
  ) async {
    final res = await apiClient.post(
      '$plugCheckPath/batch',
      body: checks.map((c) => c.toJson()).toList(),
    );
    if (res.statusCode != 201) {
      throw Exception('Failed to create plug checks ${res.body}');
    }
    final List<dynamic> data = jsonDecode(res.body);
    return data
        .whereType<Map<String, dynamic>>()
        .map((j) => PlugCheckDto.fromJson(j))
        .toList();
  }
}

final PlugApi plugService = PlugApi();
