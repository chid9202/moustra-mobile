import 'dart:convert';

import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/services/dtos/cage_dto.dart';
import 'package:moustra/services/dtos/paginated_response_dto.dart';
import 'package:moustra/services/dtos/post_cage_dto.dart';
import 'package:moustra/services/dtos/put_cage_dto.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/services/models/list_query_params.dart';

class CageApi {
  static const String basePath = '/cage';

  Future<PaginatedResponseDto<CageDto>> getCagesPage({
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
    return PaginatedResponseDto<CageDto>.fromJson(
      data,
      (j) => CageDto.fromJson(j),
    );
  }

  /// Get cages page with advanced filtering and sorting support
  Future<PaginatedResponseDto<CageDto>> getCagesPageWithParams({
    required ListQueryParams params,
  }) async {
    final queryString = params.buildQueryString();
    final res = await apiClient.getWithQueryString(
      basePath,
      queryString: queryString,
    );
    final Map<String, dynamic> data = jsonDecode(res.body);
    return PaginatedResponseDto<CageDto>.fromJson(
      data,
      (j) => CageDto.fromJson(j),
    );
  }

  Future<PaginatedResponseDto<CageDto>> searchCagesWithAi({
    required String prompt,
  }) async {
    final query = {'prompt': prompt};
    final res = await apiClient.get('$basePath/ai/search', query: query);
    final Map<String, dynamic> data = jsonDecode(res.body);
    return PaginatedResponseDto<CageDto>.fromJson(
      data,
      (j) => CageDto.fromJson(j),
    );
  }

  Future<CageDto> getCage(String cageUuid) async {
    final res = await apiClient.get('$basePath/$cageUuid');
    return CageDto.fromJson(jsonDecode(res.body));
  }

  Future<CageDto> getCageByBarcode(String barcode) async {
    try {
      final res = await apiClient.get('$basePath/barcode/$barcode');
      if (res.statusCode == 404) {
        throw Exception('Cage with barcode "$barcode" not found');
      }
      if (res.statusCode != 200) {
        throw Exception('Failed to get cage by barcode (${res.statusCode})');
      }
      if (res.body.isEmpty) {
        throw Exception('Empty response from server');
      }
      return CageDto.fromJson(jsonDecode(res.body));
    } on FormatException catch (e) {
      throw Exception('Invalid response format: ${e.message}');
    } catch (e) {
      // Re-throw if it's already our custom exception
      if (e.toString().contains('not found') ||
          e.toString().contains('Failed to get')) {
        rethrow;
      }
      // Otherwise wrap it
      throw Exception('Error getting cage by barcode: ${e.toString()}');
    }
  }

  Future<CageDto> createCage(PostCageDto payload) async {
    final res = await apiClient.post(basePath, body: payload);
    if (res.statusCode != 201) {
      throw Exception('Failed to create cage ${res.body}');
    }
    print(jsonDecode(res.body));
    return CageDto.fromJson(jsonDecode(res.body));
  }

  Future<RackDto> createCageInRack({
    required String cageTag,
    required String rackUuid,
  }) async {
    final res = await apiClient.post(
      basePath,
      body: {'cageTag': cageTag, 'rack': rackUuid},
    );
    if (res.statusCode != 201) {
      throw Exception('Failed to create cage in rack: ${res.body}');
    }
    // The response should be a RackDto with the updated rack
    return RackDto.fromJson(jsonDecode(res.body));
  }

  Future<CageDto> putCage(String cageUuid, PutCageDto payload) async {
    print(payload.toJson());
    final res = await apiClient.put('$basePath/$cageUuid', body: payload);
    if (res.statusCode != 200) {
      throw Exception('Failed to update cage ${res.body}');
    }
    return CageDto.fromJson(jsonDecode(res.body));
  }

  Future<void> endCage(String cageUuid) async {
    final res = await apiClient.post('$basePath/$cageUuid/end');
    if (res.statusCode != 204) {
      throw Exception('Failed to end cage ${res.body}');
    }
  }

  Future<RackDto> moveCage(String cageUuid, int order) async {
    final res = await apiClient.put(
      '$basePath/$cageUuid/order',
      body: {'order': order},
    );
    return RackDto.fromJson(jsonDecode(res.body));
  }
}

final CageApi cageApi = CageApi();
