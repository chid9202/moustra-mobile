import 'dart:convert';

import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/services/dtos/report_dto.dart';

class ReportApi {
  static const String basePath = '/reports';

  Future<List<WeeklyReportSummaryDto>> getWeeklyReports() async {
    final res = await apiClient.get(basePath);
    final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
    return data
        .map((e) => WeeklyReportSummaryDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final ReportApi reportApi = ReportApi();
