import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/error_report_dto.dart';

void main() {
  group('ErrorReportDto', () {
    test('toJson with all fields', () {
      final dto = ErrorReportDto(
        subject: 'App Crash',
        message: 'The app crashed when opening settings',
        severity: 'high',
        category: 'crash',
        deviceInfo: 'iPhone 15, iOS 17.2',
        appVersion: '1.2.3',
        environment: 'production',
      );

      final output = dto.toJson();

      expect(output['subject'], equals('App Crash'));
      expect(output['message'], equals('The app crashed when opening settings'));
      expect(output['severity'], equals('high'));
      expect(output['category'], equals('crash'));
      expect(output['deviceInfo'], equals('iPhone 15, iOS 17.2'));
      expect(output['appVersion'], equals('1.2.3'));
      expect(output['environment'], equals('production'));
    });

    test('toJson with only required fields omits null optional fields', () {
      final dto = ErrorReportDto(
        subject: 'Bug Report',
        message: 'Something went wrong',
      );

      final output = dto.toJson();

      expect(output['subject'], equals('Bug Report'));
      expect(output['message'], equals('Something went wrong'));
      expect(output.containsKey('severity'), isFalse);
      expect(output.containsKey('category'), isFalse);
      expect(output.containsKey('deviceInfo'), isFalse);
      expect(output.containsKey('appVersion'), isFalse);
      expect(output.containsKey('environment'), isFalse);
    });

    test('toJson with partial optional fields', () {
      final dto = ErrorReportDto(
        subject: 'Bug',
        message: 'Error detail',
        severity: 'low',
      );

      final output = dto.toJson();

      expect(output['severity'], equals('low'));
      expect(output.containsKey('category'), isFalse);
    });
  });
}
