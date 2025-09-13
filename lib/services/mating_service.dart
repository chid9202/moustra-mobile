import 'dart:convert';

import 'package:moustra/services/api_client.dart';
import 'package:moustra/services/dtos/paginated_response_dto.dart';

class MatingPage {
  final int count;
  final List<dynamic> results;

  MatingPage({required this.count, required this.results});
}

class MatingService {
  static const String basePath = '/mating';

  Future<PaginatedResponseDto<Map<String, dynamic>>> getMatingsPage({
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
    return PaginatedResponseDto<Map<String, dynamic>>.fromJson(data, (j) => j);
  }
}

final MatingService matingService = MatingService();
