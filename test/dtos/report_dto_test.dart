import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/report_dto.dart';

void main() {
  group('WeeklyReportSummaryDto', () {
    test('should create from JSON', () {
      final json = {
        'reportUuid': 'report-uuid-1',
        'date': '2026-03-01',
        'createdAt': '2026-03-01T10:00:00.000Z',
      };

      final dto = WeeklyReportSummaryDto.fromJson(json);

      expect(dto.reportUuid, 'report-uuid-1');
      expect(dto.date, '2026-03-01');
      expect(dto.createdAt, '2026-03-01T10:00:00.000Z');
    });

    test('should convert to JSON', () {
      final dto = WeeklyReportSummaryDto(
        reportUuid: 'report-uuid-2',
        date: '2026-03-08',
        createdAt: '2026-03-08T09:00:00.000Z',
      );

      final json = dto.toJson();

      expect(json['reportUuid'], 'report-uuid-2');
      expect(json['date'], '2026-03-08');
      expect(json['createdAt'], '2026-03-08T09:00:00.000Z');
    });
  });
}
