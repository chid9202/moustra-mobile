import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/helpers/platform_helper.dart';

void main() {
  group('PlatformHelper', () {
    test('getPlatform returns a known label', () {
      final p = PlatformHelper.getPlatform();
      if (Platform.isIOS) {
        expect(p, 'iOS');
      } else if (Platform.isAndroid) {
        expect(p, 'Android');
      } else {
        expect(p, 'Unknown');
      }
    });
  });
}
