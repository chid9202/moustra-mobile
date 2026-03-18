import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:moustra/helpers/note_helper.dart';
import 'package:moustra/services/dtos/account_dto.dart';

void main() {
  group('NoteHelper', () {
    group('getCreatorName', () {
      test('returns "System" for null account', () {
        expect(NoteHelper.getCreatorName(null), 'System');
      });

      test('returns "System" when user is null', () {
        final account = AccountDto(accountUuid: 'uuid1', user: null);
        expect(NoteHelper.getCreatorName(account), 'System');
      });

      test('returns full name when first and last name present', () {
        final account = AccountDto(
          accountUuid: 'uuid1',
          user: UserDto(firstName: 'John', lastName: 'Doe'),
        );
        expect(NoteHelper.getCreatorName(account), 'John Doe');
      });

      test('returns "Unknown" when firstName is empty', () {
        final account = AccountDto(
          accountUuid: 'uuid1',
          user: UserDto(firstName: '', lastName: 'Doe'),
        );
        expect(NoteHelper.getCreatorName(account), 'Unknown');
      });

      test('returns "Unknown" when lastName is empty', () {
        final account = AccountDto(
          accountUuid: 'uuid1',
          user: UserDto(firstName: 'John', lastName: ''),
        );
        expect(NoteHelper.getCreatorName(account), 'Unknown');
      });

      test('returns "Unknown" when both names are empty', () {
        final account = AccountDto(
          accountUuid: 'uuid1',
          user: UserDto(firstName: '', lastName: ''),
        );
        expect(NoteHelper.getCreatorName(account), 'Unknown');
      });
    });

    group('getInitials', () {
      test('returns "SY" for null account', () {
        expect(NoteHelper.getInitials(null), 'SY');
      });

      test('returns "SY" when user is null', () {
        final account = AccountDto(accountUuid: 'uuid1', user: null);
        expect(NoteHelper.getInitials(account), 'SY');
      });

      test('returns initials for full name', () {
        final account = AccountDto(
          accountUuid: 'uuid1',
          user: UserDto(firstName: 'John', lastName: 'Doe'),
        );
        expect(NoteHelper.getInitials(account), 'JD');
      });

      test('returns uppercase initials', () {
        final account = AccountDto(
          accountUuid: 'uuid1',
          user: UserDto(firstName: 'john', lastName: 'doe'),
        );
        expect(NoteHelper.getInitials(account), 'JD');
      });

      test('returns "?" when firstName is empty', () {
        final account = AccountDto(
          accountUuid: 'uuid1',
          user: UserDto(firstName: '', lastName: 'Doe'),
        );
        expect(NoteHelper.getInitials(account), '?');
      });

      test('returns "?" when lastName is empty', () {
        final account = AccountDto(
          accountUuid: 'uuid1',
          user: UserDto(firstName: 'John', lastName: ''),
        );
        expect(NoteHelper.getInitials(account), '?');
      });
    });

    group('stringToColor', () {
      test('returns a Color object', () {
        final color = NoteHelper.stringToColor('test');
        expect(color, isA<Color>());
      });

      test('returns same color for same string', () {
        final c1 = NoteHelper.stringToColor('hello');
        final c2 = NoteHelper.stringToColor('hello');
        expect(c1, equals(c2));
      });

      test('returns different colors for different strings', () {
        final c1 = NoteHelper.stringToColor('hello');
        final c2 = NoteHelper.stringToColor('world');
        expect(c1, isNot(equals(c2)));
      });

      test('returns fully opaque color (alpha = 0xFF)', () {
        final color = NoteHelper.stringToColor('test');
        // In Flutter, Color.a is a double from 0.0 to 1.0 in newer versions
        // but the code adds 0xFF000000 to ensure full opacity
        expect(color.a, 1.0);
      });

      test('handles empty string', () {
        // Empty string: hash stays 0, so color is #000000 + 0xFF000000
        final color = NoteHelper.stringToColor('');
        expect(color, isA<Color>());
      });

      test('handles single character', () {
        final color = NoteHelper.stringToColor('a');
        expect(color, isA<Color>());
      });
    });

    group('formatNoteDate', () {
      test('formats date correctly', () {
        final date = DateTime(2024, 3, 15, 14, 30);
        final expected = DateFormat('MMM d, yyyy, hh:mm a').format(date);
        expect(NoteHelper.formatNoteDate(date), expected);
      });

      test('formats AM time correctly', () {
        final date = DateTime(2024, 1, 1, 9, 5);
        final result = NoteHelper.formatNoteDate(date);
        expect(result, contains('AM'));
      });

      test('formats PM time correctly', () {
        final date = DateTime(2024, 6, 15, 15, 30);
        final result = NoteHelper.formatNoteDate(date);
        expect(result, contains('PM'));
      });
    });

    group('extractErrorMessage', () {
      test('returns string representation for non-exception errors', () {
        expect(NoteHelper.extractErrorMessage('simple error'), 'simple error');
      });

      test('strips Exception: prefix', () {
        final error = Exception('something went wrong');
        expect(NoteHelper.extractErrorMessage(error), 'something went wrong');
      });

      test('extracts content validation error from JSON', () {
        final error =
            Exception('{"content": ["Field is required"], "status": 400}');
        expect(NoteHelper.extractErrorMessage(error), 'Field is required');
      });

      test('extracts error field from JSON', () {
        final error = Exception('{"error": "Not found"}');
        expect(NoteHelper.extractErrorMessage(error), 'Not found');
      });

      test('extracts message field from JSON', () {
        final error = Exception('{"message": "Unauthorized"}');
        expect(NoteHelper.extractErrorMessage(error), 'Unauthorized');
      });

      test('returns message when JSON parsing fails', () {
        final error = Exception('prefix {invalid json} suffix');
        expect(NoteHelper.extractErrorMessage(error),
            'prefix {invalid json} suffix');
      });

      test('returns message when JSON has no recognized fields', () {
        final error = Exception('{"unknown_field": "value"}');
        // No content, error, or message fields, so returns the full message
        expect(NoteHelper.extractErrorMessage(error),
            '{"unknown_field": "value"}');
      });

      test('handles empty content array', () {
        final error = Exception('{"content": []}');
        // content is empty list, falls through to check error/message, neither found
        expect(NoteHelper.extractErrorMessage(error), '{"content": []}');
      });

      test('guards against jsonStart >= jsonEnd (bug fix verification)', () {
        // A string where indexOf('{') returns a position >= lastIndexOf('}') + 1
        // This happens when '}' appears before '{' in the string
        final error = Exception('error } happened { later');
        // jsonStart = indexOf('{') = position of '{'
        // jsonEnd = lastIndexOf('}') + 1 = position after '}'
        // If '}' comes before '{', jsonStart > jsonEnd, guard triggers
        final result = NoteHelper.extractErrorMessage(error);
        expect(result, 'error } happened { later');
      });

      test('handles message with no braces but Exception prefix', () {
        final error = Exception('plain message without json');
        expect(
            NoteHelper.extractErrorMessage(error), 'plain message without json');
      });

      test('handles nested JSON in error', () {
        final error = Exception(
            'Some prefix {"content": ["Validation failed: name is required"]}');
        expect(NoteHelper.extractErrorMessage(error),
            'Validation failed: name is required');
      });

      test('prefers content over error and message', () {
        final error = Exception(
            '{"content": ["Content error"], "error": "Error msg", "message": "Message msg"}');
        expect(NoteHelper.extractErrorMessage(error), 'Content error');
      });

      test('falls back to error when content is missing', () {
        final error =
            Exception('{"error": "Error msg", "message": "Message msg"}');
        expect(NoteHelper.extractErrorMessage(error), 'Error msg');
      });
    });
  });
}
