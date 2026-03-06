import 'package:json_annotation/json_annotation.dart';

part 'report_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class WeeklyReportSummaryDto {
  final String reportUuid;
  final String date;
  final String createdAt;

  WeeklyReportSummaryDto({
    required this.reportUuid,
    required this.date,
    required this.createdAt,
  });

  factory WeeklyReportSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$WeeklyReportSummaryDtoFromJson(json);
  Map<String, dynamic> toJson() => _$WeeklyReportSummaryDtoToJson(this);
}
