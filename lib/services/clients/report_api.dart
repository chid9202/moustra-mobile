import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/report_dto.dart';

class ReportApi {
  static const String basePath = '/reports';

  Future<List<WeeklyReportSummaryDto>> getWeeklyReports() async {
    final res = await dioApiClient.get(basePath);
    final List<dynamic> data = res.data as List<dynamic>;
    return data
        .map((e) => WeeklyReportSummaryDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final ReportApi reportApi = ReportApi();
