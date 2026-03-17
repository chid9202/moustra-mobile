import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart' show Level;
import 'package:moustra/services/log_service.dart';

void main() {
  group('LogService', () {
    test('is a singleton', () {
      final a = LogService();
      final b = LogService();
      expect(identical(a, b), isTrue);
    });

    test('adds entries to buffer', () {
      final svc = LogService();
      final initialCount = svc.buffer.length;
      svc.d('debug msg', tag: 'Test');
      svc.i('info msg', tag: 'Test');
      svc.w('warn msg', tag: 'Test');
      svc.e('error msg', tag: 'Test');
      expect(svc.buffer.length, initialCount + 4);
    });

    test('getRecentLogs returns last N entries', () {
      final svc = LogService();
      // Add known entries
      for (var i = 0; i < 5; i++) {
        svc.d('entry $i', tag: 'Test');
      }
      final recent = svc.getRecentLogs(count: 3);
      expect(recent.length, 3);
      expect(recent.last, contains('entry 4'));
    });

    test('buffer does not exceed maxBufferSize', () {
      final svc = LogService();
      // Add more than maxBufferSize entries
      for (var i = 0; i < LogService.maxBufferSize + 50; i++) {
        svc.d('entry $i', tag: 'Test');
      }
      expect(svc.buffer.length, LogService.maxBufferSize);
    });

    test('LogEntry toString has expected format', () {
      final entry = LogEntry(
        level: Level.warning,
        tag: 'MyTag',
        message: 'hello world',
        timestamp: DateTime(2024, 1, 15, 10, 30, 0),
      );
      final str = entry.toString();
      expect(str, contains('WARNING'));
      expect(str, contains('[MyTag]'));
      expect(str, contains('hello world'));
    });
  });
}
