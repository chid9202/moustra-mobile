import 'dart:convert';

import 'package:grid_view/core/services/api_client.dart';

class DashboardService {
  static const String basePath = '/dashboard';

  Future<Map<String, dynamic>> getDashboard({
    Map<String, String>? query,
  }) async {
    final res = await apiClient.get(basePath, query: query);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}

final DashboardService dashboardService = DashboardService();
