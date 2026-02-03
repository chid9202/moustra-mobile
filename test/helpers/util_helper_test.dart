import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/helpers/util_helper.dart';

void main() {
  group('UtilHelper.extractCageUuidFromUrl', () {
    test('extracts UUID from app.moustra.com/cage/{uuid} URL', () {
      const url = 'https://app.moustra.com/cage/a1b2c3d4-e5f6-7890-abcd-ef1234567890';
      final result = UtilHelper.extractCageUuidFromUrl(url);
      expect(result, 'a1b2c3d4-e5f6-7890-abcd-ef1234567890');
    });

    test('extracts UUID from app.moustra.com/cages/{uuid} URL', () {
      const url = 'https://app.moustra.com/cages/a1b2c3d4-e5f6-7890-abcd-ef1234567890';
      final result = UtilHelper.extractCageUuidFromUrl(url);
      expect(result, 'a1b2c3d4-e5f6-7890-abcd-ef1234567890');
    });

    test('extracts UUID from URL with query params', () {
      const url = 'https://app.moustra.com/cage/a1b2c3d4-e5f6-7890-abcd-ef1234567890?tab=animals';
      final result = UtilHelper.extractCageUuidFromUrl(url);
      expect(result, 'a1b2c3d4-e5f6-7890-abcd-ef1234567890');
    });

    test('extracts UUID from URL with hash fragment', () {
      const url = 'https://app.moustra.com/cage/a1b2c3d4-e5f6-7890-abcd-ef1234567890#notes';
      final result = UtilHelper.extractCageUuidFromUrl(url);
      expect(result, 'a1b2c3d4-e5f6-7890-abcd-ef1234567890');
    });

    test('extracts UUID from login-dev.moustra.com URL', () {
      const url = 'https://login-dev.moustra.com/cage/a1b2c3d4-e5f6-7890-abcd-ef1234567890';
      final result = UtilHelper.extractCageUuidFromUrl(url);
      expect(result, 'a1b2c3d4-e5f6-7890-abcd-ef1234567890');
    });

    test('returns null for plain barcode string', () {
      const barcode = 'ABC123456';
      final result = UtilHelper.extractCageUuidFromUrl(barcode);
      expect(result, isNull);
    });

    test('returns null for UUID without URL prefix', () {
      const uuid = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';
      final result = UtilHelper.extractCageUuidFromUrl(uuid);
      expect(result, isNull);
    });

    test('returns null for URL without cage path', () {
      const url = 'https://app.moustra.com/animals/a1b2c3d4-e5f6-7890-abcd-ef1234567890';
      final result = UtilHelper.extractCageUuidFromUrl(url);
      expect(result, isNull);
    });

    test('returns null for malformed UUID in URL', () {
      const url = 'https://app.moustra.com/cage/not-a-valid-uuid';
      final result = UtilHelper.extractCageUuidFromUrl(url);
      expect(result, isNull);
    });

    test('handles uppercase UUID', () {
      const url = 'https://app.moustra.com/cage/A1B2C3D4-E5F6-7890-ABCD-EF1234567890';
      final result = UtilHelper.extractCageUuidFromUrl(url);
      expect(result, 'A1B2C3D4-E5F6-7890-ABCD-EF1234567890');
    });
  });
}
