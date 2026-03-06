// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeeklyReportSummaryDto _$WeeklyReportSummaryDtoFromJson(
  Map<String, dynamic> json,
) => WeeklyReportSummaryDto(
  reportUuid: json['reportUuid'] as String,
  date: json['date'] as String,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$WeeklyReportSummaryDtoToJson(
  WeeklyReportSummaryDto instance,
) => <String, dynamic>{
  'reportUuid': instance.reportUuid,
  'date': instance.date,
  'createdAt': instance.createdAt,
};
