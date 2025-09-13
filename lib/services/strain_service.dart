import 'dart:convert';

import 'package:moustra/config/api_config.dart';
import 'package:moustra/services/api_client.dart';
import 'package:moustra/services/dtos/paginated_response_dto.dart';
import 'package:moustra/services/dtos/strain_dto.dart';

class StrainPage {
  final int count;
  final List<dynamic> results;

  StrainPage({required this.count, required this.results});
}

class StrainService {
  Future<PaginatedResponseDto<StrainDto>> getStrainsPage({
    int page = 1,
    int pageSize = 25,
    Map<String, String>? query,
  }) async {
    final mergedQuery = <String, String>{
      'page': page.toString(),
      'page_size': pageSize.toString(),
      if (query != null) ...query,
    };
    final res = await apiClient.get(ApiConfig.strains, query: mergedQuery);
    final Map<String, dynamic> data = jsonDecode(res.body);
    return PaginatedResponseDto<StrainDto>.fromJson(
      data,
      (j) => StrainDto.fromJson(j),
    );
  }

  Future<Map<String, dynamic>> createStrain(
    Map<String, dynamic> payload,
  ) async {
    final res = await apiClient.post(ApiConfig.strains, body: payload);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateStrain(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final res = await apiClient.put('${ApiConfig.strains}/$id', body: payload);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<void> deleteStrain(String id) async {
    await apiClient.delete('${ApiConfig.strains}/$id');
  }

  Future<void> mergeStrains(List<String> strainUuids) async {
    await apiClient.post(
      '${ApiConfig.strains}/merge',
      body: <String, dynamic>{'strains': strainUuids},
    );
  }
}

final StrainService strainService = StrainService();
