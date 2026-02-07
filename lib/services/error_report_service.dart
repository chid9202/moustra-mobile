import 'package:flutter/widgets.dart';
import 'package:moustra/services/clients/api_client.dart';
import 'package:moustra/services/dtos/error_report_dto.dart';
import 'package:moustra/services/error_context_service.dart';
import 'package:moustra/stores/profile_store.dart';

class ErrorReportService {
  /// Report an error to the backend
  /// This is a fire-and-forget operation that won't block or throw errors
  /// Includes full context: user info, navigation breadcrumbs, app state
  static void reportError({required String subject, required String message}) {
    debugPrint('reportError: $subject');

    // Get account UUID - if not available, still report but note it
    final accountUuid = profileState.value?.accountUuid;

    // Build rich context message
    final richMessage = _buildRichMessage(message);

    if (accountUuid == null || accountUuid.isEmpty) {
      // Still try to report for startup/logout errors, but note the user state
      debugPrint('reportError: User not logged in, reporting anyway');
    }

    // Fire-and-forget: don't await, catch any errors silently
    _sendErrorReport(subject, richMessage).catchError((error) {
      // Silently ignore errors in error reporting to prevent infinite loops
      debugPrint('Error sending error report: $error');
    });
  }

  /// Build a rich error message with all available context
  static String _buildRichMessage(String originalMessage) {
    final buffer = StringBuffer();

    // Original error message
    buffer.writeln(originalMessage);
    buffer.writeln();

    // Add separator
    buffer.writeln('--- Context ---');
    buffer.writeln();

    // Add full context from ErrorContextService
    try {
      buffer.writeln(errorContextService.buildFullContext());
    } catch (e) {
      // If context building fails, note it but don't fail the report
      buffer.writeln('Context: Failed to build ($e)');
    }

    return buffer.toString();
  }

  /// Internal method to send the error report
  static Future<void> _sendErrorReport(String subject, String message) async {
    try {
      final dto = ErrorReportDto(subject: subject, message: message);
      await apiClient.postWithoutAuth('error-report', body: dto.toJson());
    } catch (e) {
      // Silently ignore errors - we don't want error reporting to cause issues
      debugPrint('_sendErrorReport failed: $e');
    }
  }
}

/// Helper function to report errors manually from catch blocks
/// Usage: reportError(error: e, stackTrace: stackTrace);
void reportError({
  required Object error,
  StackTrace? stackTrace,
  String? context,
}) {
  debugPrint('reportError manually: $error');

  final subject = error.runtimeType.toString();
  final buffer = StringBuffer();

  // Error details
  buffer.writeln('Error: ${error.toString()}');

  // Optional additional context from caller
  if (context != null && context.isNotEmpty) {
    buffer.writeln();
    buffer.writeln('Additional Context: $context');
  }

  // Stack trace
  if (stackTrace != null) {
    buffer.writeln();
    buffer.writeln('Stack Trace:');
    buffer.writeln(stackTrace.toString());
  }

  // Timestamp
  buffer.writeln();
  buffer.writeln('Timestamp: ${DateTime.now().toIso8601String()}');

  ErrorReportService.reportError(subject: subject, message: buffer.toString());
}

/// Report an error with extra context about what the user was doing
/// Usage: reportErrorWithAction(error: e, stackTrace: st, action: 'saving cage');
void reportErrorWithAction({
  required Object error,
  StackTrace? stackTrace,
  required String action,
}) {
  reportError(
    error: error,
    stackTrace: stackTrace,
    context: 'User action: $action',
  );
}
