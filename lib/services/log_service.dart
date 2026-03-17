import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Circular buffer entry for log history
class LogEntry {
  final Level level;
  final String tag;
  final String message;
  final DateTime timestamp;

  LogEntry({
    required this.level,
    required this.tag,
    required this.message,
    required this.timestamp,
  });

  @override
  String toString() =>
      '[${timestamp.toIso8601String()}] ${level.name.toUpperCase()} [$tag] $message';
}

/// Application-wide structured logging service.
/// In debug mode, logs all levels with pretty printing.
/// In release mode, logs only warnings and above.
/// Maintains a circular buffer of last 200 entries for error report attachment.
class LogService {
  static final LogService _instance = LogService._internal();
  factory LogService() => _instance;

  late final Logger _logger;
  final List<LogEntry> _buffer = [];
  static const int maxBufferSize = 200;

  LogService._internal() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 80,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      level: kReleaseMode ? Level.warning : Level.debug,
    );
  }

  void _addToBuffer(Level level, String tag, String message) {
    _buffer.add(LogEntry(
      level: level,
      tag: tag,
      message: message,
      timestamp: DateTime.now(),
    ));
    while (_buffer.length > maxBufferSize) {
      _buffer.removeAt(0);
    }
  }

  /// Debug log — development-only diagnostics
  void d(String message, {String tag = 'App'}) {
    _addToBuffer(Level.debug, tag, message);
    _logger.d('[$tag] $message');
  }

  /// Info log — normal operational events
  void i(String message, {String tag = 'App'}) {
    _addToBuffer(Level.info, tag, message);
    _logger.i('[$tag] $message');
  }

  /// Warning log — potentially harmful situations
  void w(String message, {String tag = 'App'}) {
    _addToBuffer(Level.warning, tag, message);
    _logger.w('[$tag] $message');
  }

  /// Error log — errors that should be investigated
  void e(String message, {String tag = 'App', Object? error, StackTrace? stackTrace}) {
    _addToBuffer(Level.error, tag, message);
    _logger.e('[$tag] $message', error: error, stackTrace: stackTrace);
  }

  /// Get the last [count] log entries as strings for error report attachment.
  List<String> getRecentLogs({int count = 20}) {
    final start = _buffer.length > count ? _buffer.length - count : 0;
    return _buffer.sublist(start).map((e) => e.toString()).toList();
  }

  /// Get all buffered entries (for debugging)
  List<LogEntry> get buffer => List.unmodifiable(_buffer);
}

/// Global log instance
final log = LogService();
