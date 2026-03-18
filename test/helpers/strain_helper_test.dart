import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/helpers/strain_helper.dart';
import 'package:moustra/services/dtos/strain_dto.dart';

void main() {
  group('StrainHelper', () {
    group('getBackgroundNames', () {
      test('returns empty string for null backgrounds', () {
        expect(StrainHelper.getBackgroundNames(null), '');
      });

      test('returns empty string for empty list', () {
        expect(StrainHelper.getBackgroundNames([]), '');
      });

      test('returns single background name', () {
        final backgrounds = [
          StrainBackgroundDto(id: 1, uuid: 'u1', name: 'C57BL/6'),
        ];
        expect(StrainHelper.getBackgroundNames(backgrounds), 'C57BL/6');
      });

      test('joins multiple background names with comma', () {
        final backgrounds = [
          StrainBackgroundDto(id: 1, uuid: 'u1', name: 'C57BL/6'),
          StrainBackgroundDto(id: 2, uuid: 'u2', name: 'BALB/c'),
        ];
        expect(StrainHelper.getBackgroundNames(backgrounds),
            'C57BL/6, BALB/c');
      });

      test('includes empty names in result (no filtering)', () {
        // The current implementation does NOT filter empty names
        final backgrounds = [
          StrainBackgroundDto(id: 1, uuid: 'u1', name: ''),
          StrainBackgroundDto(id: 2, uuid: 'u2', name: 'BALB/c'),
        ];
        expect(StrainHelper.getBackgroundNames(backgrounds), ', BALB/c');
      });

      test('handles three backgrounds', () {
        final backgrounds = [
          StrainBackgroundDto(id: 1, uuid: 'u1', name: 'C57BL/6'),
          StrainBackgroundDto(id: 2, uuid: 'u2', name: 'BALB/c'),
          StrainBackgroundDto(id: 3, uuid: 'u3', name: 'FVB/N'),
        ];
        expect(StrainHelper.getBackgroundNames(backgrounds),
            'C57BL/6, BALB/c, FVB/N');
      });
    });
  });
}
