class ErrorReportDto {
  final String subject;
  final String message;

  ErrorReportDto({required this.subject, required this.message});

  Map<String, dynamic> toJson() => <String, dynamic>{
    'subject': subject,
    'message': message,
  };
}
