import 'dart:io' show Platform;

import 'package:moustra/services/clients/dio_api_client.dart';
import 'package:moustra/services/dtos/error_report_dto.dart';
import 'package:moustra/services/error_context_service.dart';
import 'package:moustra/services/log_service.dart';
import 'package:moustra/stores/profile_store.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Tracks recent error signatures to prevent duplicate reports
class _ErrorDeduplicator {
  final Map<String, DateTime> _recentErrors = {};
  int _reportCount = 0;
  DateTime _reportWindowStart = DateTime.now();
  static const _dedupeWindow = Duration(seconds: 60);
  static const _maxReportsPerMinute = 10;

  bool shouldReport(String signature) {
    final now = DateTime.now();

    // Reset rate limit window
    if (now.difference(_reportWindowStart).inSeconds >= 60) {
      _reportCount = 0;
      _reportWindowStart = now;
    }

    // Rate limit check
    if (_reportCount >= _maxReportsPerMinute) {
      return false;
    }

    // Deduplication check
    final lastSeen = _recentErrors[signature];
    if (lastSeen != null && now.difference(lastSeen) < _dedupeWindow) {
      return false;
    }

    _recentErrors[signature] = now;
    _reportCount++;

    // Clean old entries
    _recentErrors.removeWhere((_, time) => now.difference(time) > _dedupeWindow);

    return true;
  }
}

class ErrorReportService {
  static final _deduplicator = _ErrorDeduplicator();
  static DateTime? _sessionStartTime;
  static PackageInfo? _packageInfo;

  /// Initialize session tracking. Call once at app startup.
  static void initSession() {
    _sessionStartTime = DateTime.now();
    PackageInfo.fromPlatform().then((info) => _packageInfo = info);
  }

  /// Report an error to the backend
  /// This is a fire-and-forget operation that won't block or throw errors
  /// Includes full context: user info, navigation breadcrumbs, app state, device info, logs
  static void reportError({
    required String subject,
    required String message,
    String severity = 'error',
    String category = 'general',
  }) {
    log.w('reportError: $subject', tag: 'ErrorReport');

    // Deduplication check
    final signature = '${subject.hashCode}:${message.hashCode}';
    if (!_deduplicator.shouldReport(signature)) {
      log.d('Skipping duplicate error report: $subject', tag: 'ErrorReport');
      return;
    }

    // Get account UUID - if not available, still report but note it
    final accountUuid = profileState.value?.accountUuid;

    // Build rich context message
    final richMessage = _buildRichMessage(message);

    if (accountUuid == null || accountUuid.isEmpty) {
      log.d('User not logged in, reporting anyway', tag: 'ErrorReport');
    }

    // Fire-and-forget: don't await, catch any errors silently
    _sendErrorReport(
      subject,
      richMessage,
      severity: severity,
      category: category,
    ).catchError((error) {
      // Silently ignore errors in error reporting to prevent infinite loops
      log.e('Error sending error report: $error', tag: 'ErrorReport');
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

    // Device & app info
    buffer.writeln();
    buffer.writeln('--- Device Info ---');
    try {
      buffer.writeln('OS: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}');
      if (_packageInfo != null) {
        buffer.writeln('App Version: ${_packageInfo!.version}+${_packageInfo!.buildNumber}');
        buffer.writeln('Package: ${_packageInfo!.packageName}');
      }
    } catch (e) {
      buffer.writeln('Device info: Failed to collect ($e)');
    }

    // Session info
    if (_sessionStartTime != null) {
      final uptime = DateTime.now().difference(_sessionStartTime!);
      buffer.writeln('Session uptime: ${uptime.inMinutes}m ${uptime.inSeconds % 60}s');
    }

    // Recent logs
    buffer.writeln();
    buffer.writeln('--- Recent Logs ---');
    try {
      final recentLogs = log.getRecentLogs(count: 20);
      if (recentLogs.isEmpty) {
        buffer.writeln('No log entries');
      } else {
        for (final entry in recentLogs) {
          buffer.writeln(entry);
        }
      }
    } catch (e) {
      buffer.writeln('Logs: Failed to collect ($e)');
    }

    return buffer.toString();
  }

  /// Internal method to send the error report
  static Future<void> _sendErrorReport(
    String subject,
    String message, {
    String severity = 'error',
    String category = 'general',
  }) async {
    try {
      final dto = ErrorReportDto(
        subject: subject,
        message: message,
        severity: severity,
        category: category,
        appVersion: _packageInfo != null
            ? '${_packageInfo!.version}+${_packageInfo!.buildNumber}'
            : null,
        deviceInfo: _buildDeviceInfoString(),
        environment: const String.fromEnvironment('ENV_FILENAME', defaultValue: '.env'),
      );
      await dioApiClient.postWithoutAuth('error-report', body: dto.toJson());
    } catch (e) {
      // Silently ignore errors - we don't want error reporting to cause issues
      log.e('_sendErrorReport failed: $e', tag: 'ErrorReport');
    }
  }

  static String? _buildDeviceInfoString() {
    try {
      return '${Platform.operatingSystem} ${Platform.operatingSystemVersion}';
    } catch (_) {
      return null;
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
  log.e('reportError manually: $error', tag: 'ErrorReport', error: error, stackTrace: stackTrace);

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
