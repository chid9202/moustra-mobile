import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:moustra/helpers/datetime_helper.dart';

void main() {
  group('DateTimeHelper', () {
    group('parseIsoToDateTime', () {
      test('returns empty string for null input', () {
        expect(DateTimeHelper.parseIsoToDateTime(null), '');
      });

      test('returns original string for unparseable input', () {
        expect(DateTimeHelper.parseIsoToDateTime('not-a-date'), 'not-a-date');
      });

      test('returns empty string for empty string input', () {
        // DateTime.tryParse('') returns null, so it returns the original ''
        // Actually '' is unparseable, so it returns ''
        expect(DateTimeHelper.parseIsoToDateTime(''), '');
      });

      test('parses valid ISO string to formatted datetime', () {
        final utc = DateTime.utc(2024, 3, 15, 14, 30, 45);
        final local = utc.toLocal();
        final expected = DateFormat('M/d/y, h:mm:ss a').format(local);
        expect(
          DateTimeHelper.parseIsoToDateTime(utc.toIso8601String()),
          expected,
        );
      });

      test('parses date-only ISO string', () {
        final result = DateTimeHelper.parseIsoToDateTime('2024-01-01');
        // Should parse successfully; DateTime.tryParse('2024-01-01') is valid
        expect(result, isNotEmpty);
        expect(result, isNot('2024-01-01'));
      });
    });

    group('parseIsoToDate', () {
      test('returns empty string for null input', () {
        expect(DateTimeHelper.parseIsoToDate(null), '');
      });

      test('returns original string for unparseable input', () {
        expect(DateTimeHelper.parseIsoToDate('bad'), 'bad');
      });

      test('parses valid ISO string to date only', () {
        final utc = DateTime.utc(2024, 12, 25, 10, 0, 0);
        final local = utc.toLocal();
        final expected = DateFormat('M/d/y').format(local);
        expect(DateTimeHelper.parseIsoToDate(utc.toIso8601String()), expected);
      });
    });

    group('formatDate', () {
      test('returns empty string for null input', () {
        expect(DateTimeHelper.formatDate(null), '');
      });

      test('formats DateTime to date string', () {
        final dt = DateTime(2024, 6, 15, 10, 30);
        final expected = DateFormat('M/d/y').format(dt.toLocal());
        expect(DateTimeHelper.formatDate(dt), expected);
      });

      test('formats UTC DateTime converting to local', () {
        final utc = DateTime.utc(2024, 1, 1, 0, 0, 0);
        final local = utc.toLocal();
        final expected = DateFormat('M/d/y').format(local);
        expect(DateTimeHelper.formatDate(utc), expected);
      });
    });

    group('formatDateTime', () {
      test('returns empty string for null input', () {
        expect(DateTimeHelper.formatDateTime(null), '');
      });

      test('formats DateTime to full datetime string', () {
        final dt = DateTime(2024, 6, 15, 14, 30, 45);
        final expected = DateFormat('M/d/y, h:mm:ss a').format(dt.toLocal());
        expect(DateTimeHelper.formatDateTime(dt), expected);
      });
    });

    group('formatRelativeTime', () {
      test('returns "Just now" for less than 1 minute ago', () {
        final dateTime = DateTime.now().subtract(const Duration(seconds: 30));
        expect(DateTimeHelper.formatRelativeTime(dateTime), 'Just now');
      });

      test('returns minutes ago for less than 1 hour', () {
        final dateTime = DateTime.now().subtract(const Duration(minutes: 5));
        expect(DateTimeHelper.formatRelativeTime(dateTime), '5m ago');
      });

      test('returns hours ago for less than 1 day', () {
        final dateTime = DateTime.now().subtract(const Duration(hours: 3));
        expect(DateTimeHelper.formatRelativeTime(dateTime), '3h ago');
      });

      test('returns days ago for less than 7 days', () {
        final dateTime = DateTime.now().subtract(const Duration(days: 4));
        expect(DateTimeHelper.formatRelativeTime(dateTime), '4d ago');
      });

      test('returns formatted date for 7+ days ago', () {
        final dateTime = DateTime.now().subtract(const Duration(days: 10));
        final expected = DateFormat('M/d/y').format(dateTime.toLocal());
        expect(DateTimeHelper.formatRelativeTime(dateTime), expected);
      });

      test('boundary: exactly 1 minute ago returns minutes', () {
        final dateTime = DateTime.now().subtract(const Duration(minutes: 1));
        expect(DateTimeHelper.formatRelativeTime(dateTime), '1m ago');
      });

      test('boundary: exactly 59 minutes returns minutes', () {
        final dateTime = DateTime.now().subtract(const Duration(minutes: 59));
        expect(DateTimeHelper.formatRelativeTime(dateTime), '59m ago');
      });

      test('boundary: exactly 1 hour returns hours', () {
        final dateTime = DateTime.now().subtract(const Duration(hours: 1));
        expect(DateTimeHelper.formatRelativeTime(dateTime), '1h ago');
      });

      test('boundary: exactly 23 hours returns hours', () {
        final dateTime = DateTime.now().subtract(const Duration(hours: 23));
        expect(DateTimeHelper.formatRelativeTime(dateTime), '23h ago');
      });

      test('boundary: exactly 6 days returns days', () {
        final dateTime = DateTime.now().subtract(const Duration(days: 6));
        expect(DateTimeHelper.formatRelativeTime(dateTime), '6d ago');
      });
    });
  });
}
