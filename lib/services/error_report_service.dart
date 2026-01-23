import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/services/dtos/error_report_dto.dart';
import 'package:moustra/stores/profile_store.dart';

class ErrorReportService {
  /// Report an error to the backend (only in production)
  /// This is a fire-and-forget operation that won't block or throw errors
  static void reportError({required String subject, required String message}) {
    print('reportError: $subject, $message');
    // Get account UUID - if not available, skip reporting
    final accountUuid = profileState.value?.accountUuid;
    if (accountUuid == null || accountUuid.isEmpty) {
      return;
    }

    // Fire-and-forget: don't await, catch any errors silently
    _sendErrorReport(subject, message).catchError((error) {
      // Silently ignore errors in error reporting to prevent infinite loops
    });
  }

  /// Internal method to send the error report
  static Future<void> _sendErrorReport(String subject, String message) async {
    try {
      final dto = ErrorReportDto(subject: subject, message: message);
      await apiClient.postWithoutAuth('error-report', body: dto.toJson());
    } catch (e) {
      // Silently ignore errors - we don't want error reporting to cause issues
    }
  }
}

/// Helper function to report errors manually from catch blocks
/// Usage: reportError(error: e, stackTrace: stackTrace);
void reportError({required Object error, StackTrace? stackTrace}) {
  print('reportError manually: $error, $stackTrace');
  final subject = error.runtimeType.toString();
  final buffer = StringBuffer();
  buffer.writeln('Error: ${error.toString()}');
  if (stackTrace != null) {
    buffer.writeln('\nStack Trace:');
    buffer.writeln(stackTrace.toString());
  }
  buffer.writeln('\nTimestamp: ${DateTime.now().toIso8601String()}');

  ErrorReportService.reportError(subject: subject, message: buffer.toString());
}
