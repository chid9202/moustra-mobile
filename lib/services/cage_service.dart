import 'dart:convert';

import 'package:moustra/services/api_client.dart';

class CagePage {
  final int count;
  final List<dynamic> results;

  CagePage({required this.count, required this.results});
}

class CageService {
  static const String basePath = '/cage';

  Future<CagePage> getCagesPage({
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
    return CagePage(
      count: (data['count'] as int?) ?? 0,
      results: (data['results'] as List<dynamic>? ?? <dynamic>[]),
    );
  }
}

final CageService cageService = CageService();
