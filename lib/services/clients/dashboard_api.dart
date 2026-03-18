import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/dashboard_dto.dart';

class DashboardApi {
  static const String basePath = '/dashboard';

  Future<Map<String, dynamic>> getDashboard({
    Map<String, String>? query,
  }) async {
    final res = await dioApiClient.get(basePath, query: query);
    return res.data as Map<String, dynamic>;
  }

  Future<DashboardResponseDto> getDashboardDto({
    Map<String, String>? query,
  }) async {
    final res = await dioApiClient.get(basePath, query: query);
    final Map<String, dynamic> data = res.data as Map<String, dynamic>;
    return DashboardResponseDto.fromJson(data);
  }
}

final DashboardApi dashboardService = DashboardApi();
