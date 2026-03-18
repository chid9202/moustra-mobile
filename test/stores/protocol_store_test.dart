import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/protocol_dto.dart';
import 'package:moustra/stores/protocol_store.dart';

import '../test_helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    installNoOpDioApiClient();
  });

  tearDownAll(() {
    restoreDioApiClient();
  });

  setUp(() {
    protocolStore.value = null;
  });

  tearDown(() {
    protocolStore.value = null;
  });

  group('useProtocolStore', () {
    test('returns existing list when store is populated', () async {
      final protocols = [
        ProtocolDto(
          protocolUuid: 'uuid-1',
          protocolNumber: 'P-001',
          title: 'Test Protocol',
        ),
      ];
      protocolStore.value = protocols;

      final result = await useProtocolStore();
      expect(result.length, 1);
      expect(result.first.protocolUuid, 'uuid-1');
      expect(result.first.title, 'Test Protocol');
    });

    test('returns empty list when store is null and refresh fails', () async {
      protocolStore.value = null;
      // refreshProtocolStore will catch the error from NoOpDioApiClient,
      // so protocolStore stays null and useProtocolStore returns [].
      final result = await useProtocolStore();
      expect(result, isEmpty);
    });
  });

  group('protocolStore value', () {
    test('can be set and read', () {
      final protocols = [
        ProtocolDto(
          protocolUuid: 'uuid-1',
          protocolNumber: 'P-001',
          title: 'Test Protocol',
        ),
        ProtocolDto(
          protocolUuid: 'uuid-2',
          protocolNumber: 'P-002',
          title: 'Another Protocol',
        ),
      ];
      protocolStore.value = protocols;

      expect(protocolStore.value, isNotNull);
      expect(protocolStore.value!.length, 2);
      expect(protocolStore.value!.first.protocolNumber, 'P-001');
      expect(protocolStore.value!.last.title, 'Another Protocol');
    });

    test('defaults to null', () {
      expect(protocolStore.value, isNull);
    });

    test('can be set to empty list', () {
      protocolStore.value = [];
      expect(protocolStore.value, isNotNull);
      expect(protocolStore.value, isEmpty);
    });
  });
}
