import 'dart:convert';

import 'package:grid_view/services/api_client.dart';

class AnimalPage {
  final int count;
  final List<dynamic> results;
  final String? next;

  AnimalPage({required this.count, required this.results, this.next});
}

class AnimalService {
  static const String basePath = '/animal';

  Future<AnimalPage> getAnimalsPage({
    int page = 1,
    int pageSize = 25,
    Map<String, String>? query,
  }) async {
    final mergedQuery = {
      'page': page.toString(),
      'page_size': pageSize.toString(),
      if (query != null) ...query,
    };
    final res = await apiClient.get('$basePath', query: mergedQuery);
    final Map<String, dynamic> data =
        jsonDecode(res.body) as Map<String, dynamic>;
    return AnimalPage(
      count: (data['count'] as int?) ?? 0,
      results: (data['results'] as List<dynamic>? ?? <dynamic>[]),
      next: data['next'] as String?,
    );
  }
}

final AnimalService animalService = AnimalService();
