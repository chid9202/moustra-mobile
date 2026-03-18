import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/connectivity_service.dart';

void main() {
  group('ConnectivityService', () {
    test('is a singleton', () {
      final a = ConnectivityService();
      final b = ConnectivityService();
      expect(identical(a, b), isTrue);
    });

    test('isOnline defaults to true', () {
      final service = ConnectivityService();
      expect(service.isOnline.value, isTrue);
    });

    test('global connectivityService instance is a ConnectivityService', () {
      expect(connectivityService, isA<ConnectivityService>());
    });

    test('global instance is the same as factory-constructed instance', () {
      expect(identical(connectivityService, ConnectivityService()), isTrue);
    });

    test('dispose does not throw', () {
      expect(() => connectivityService.dispose(), returnsNormally);
    });
  });
}
