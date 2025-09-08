import 'dart:convert';

import 'package:grid_view/core/services/api_client.dart';

class LitterPage {
  final int count;
  final List<dynamic> results;

  LitterPage({required this.count, required this.results});
}

class LitterService {
  static const String basePath = '/litter';

  Future<LitterPage> getLittersPage({
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
    return LitterPage(
      count: (data['count'] as int?) ?? 0,
      results: (data['results'] as List<dynamic>? ?? <dynamic>[]),
    );
  }
}

final LitterService litterService = LitterService();
