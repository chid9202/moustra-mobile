import 'dart:convert';

import 'package:grid_view/services/api_client.dart';

class MatingPage {
  final int count;
  final List<dynamic> results;

  MatingPage({required this.count, required this.results});
}

class MatingService {
  static const String basePath = '/mating';

  Future<MatingPage> getMatingsPage({
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
    return MatingPage(
      count: (data['count'] as int?) ?? 0,
      results: (data['results'] as List<dynamic>? ?? <dynamic>[]),
    );
  }
}

final MatingService matingService = MatingService();
