import 'dart:convert';

import 'package:moustra/services/api_client.dart';
import 'package:moustra/services/dtos/paginated_response_dto.dart';

class AnimalPage {
  final int count;
  final List<dynamic> results;
  final String? next;

  AnimalPage({required this.count, required this.results, this.next});
}

class AnimalService {
  static const String basePath = '/animal';

  Future<PaginatedResponseDto<Map<String, dynamic>>> getAnimalsPage({
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

final AnimalService animalService = AnimalService();
