import 'dart:convert';

import 'package:moustra/services/api_client.dart';
import 'package:moustra/services/dtos/paginated_response_dto.dart';

class LitterPage {
  final int count;
  final List<dynamic> results;

  LitterPage({required this.count, required this.results});
}

class LitterService {
  static const String basePath = '/litter';

  Future<PaginatedResponseDto<Map<String, dynamic>>> getLittersPage({
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

final LitterService litterService = LitterService();
