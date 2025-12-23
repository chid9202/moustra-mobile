import 'dart:convert';

import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/services/dtos/paginated_response_dto.dart';
import 'package:moustra/services/dtos/litter_dto.dart';
import 'package:moustra/services/dtos/post_litter_dto.dart';
import 'package:moustra/services/dtos/put_litter_dto.dart';
import 'package:moustra/services/models/list_query_params.dart';

class LitterApi {
  static const String basePath = '/litter';

  Future<PaginatedResponseDto<LitterDto>> getLittersPage({
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
    final Map<String, dynamic> data =
        jsonDecode(res.body) as Map<String, dynamic>;
    return PaginatedResponseDto<LitterDto>.fromJson(
      data,
      (j) => LitterDto.fromJson(j),
    );
  }

  /// Get litters page with advanced filtering and sorting support
  Future<PaginatedResponseDto<LitterDto>> getLittersPageWithParams({
    required ListQueryParams params,
  }) async {
    final queryString = params.buildQueryString();
    final res = await apiClient.getWithQueryString(
      basePath,
      queryString: queryString,
    );
    final Map<String, dynamic> data =
        jsonDecode(res.body) as Map<String, dynamic>;
    return PaginatedResponseDto<LitterDto>.fromJson(
      data,
      (j) => LitterDto.fromJson(j),
    );
  }

  Future<LitterDto> getLitter(String litterUuid) async {
    final res = await apiClient.get('$basePath/$litterUuid');
    if (res.statusCode != 200) {
      throw Exception('Failed to get litter: ${res.body}');
    }
    return LitterDto.fromJson(jsonDecode(res.body));
  }

  Future createLitter(PostLitterDto payload) async {
    final res = await apiClient.post(basePath, body: payload);
    if (res.statusCode != 201) {
      throw Exception('Failed to create litter: ${res.body}');
    }
    return;
  }

  Future putLitter(String litterUuid, PutLitterDto payload) async {
    final res = await apiClient.put('$basePath/$litterUuid', body: payload);
    if (res.statusCode != 200) {
      throw Exception('Failed to update litter: ${res.body}');
    }
    return;
  }
}

final LitterApi litterService = LitterApi();
