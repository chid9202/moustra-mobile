import 'dart:convert';

import 'package:moustra/services/api_client.dart';
import 'package:moustra/services/dtos/dashboard_dto.dart';

class DashboardService {
  static const String basePath = '/dashboard';

  Future<Map<String, dynamic>> getDashboard({
    Map<String, String>? query,
  }) async {
    final res = await apiClient.get(basePath, query: query);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<DashboardResponseDto> getDashboardDto({
    Map<String, String>? query,
  }) async {
    final res = await apiClient.get(basePath, query: query);
    final Map<String, dynamic> data =
        jsonDecode(res.body) as Map<String, dynamic>;
    return DashboardResponseDto.fromJson(data);
  }
}

final DashboardService dashboardService = DashboardService();
