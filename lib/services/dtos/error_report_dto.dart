class ErrorReportDto {
  final String subject;
  final String message;
  final String? severity;
  final String? category;
  final String? deviceInfo;
  final String? appVersion;
  final String? environment;

  ErrorReportDto({
    required this.subject,
    required this.message,
    this.severity,
    this.category,
    this.deviceInfo,
    this.appVersion,
    this.environment,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
    'subject': subject,
    'message': message,
    if (severity != null) 'severity': severity,
    if (category != null) 'category': category,
    if (deviceInfo != null) 'deviceInfo': deviceInfo,
    if (appVersion != null) 'appVersion': appVersion,
    if (environment != null) 'environment': environment,
  };
}
