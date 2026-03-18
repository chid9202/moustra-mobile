import 'package:flutter_test/flutter_test.dart';
import 'package:moustra/services/dtos/stores/gene_store_dto.dart';
import 'package:moustra/stores/gene_store.dart';

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
    geneStore.value = null;
  });

  tearDown(() {
    geneStore.value = null;
  });

  group('useGeneStore', () {
    test('returns existing list when store is populated', () async {
      final genes = [
        GeneStoreDto(
          geneId: 1,
          geneUuid: 'uuid-1',
          geneName: 'Brca1',
          isActive: true,
        ),
      ];
      geneStore.value = genes;

      final result = await useGeneStore();
      expect(result.length, 1);
      expect(result.first.geneUuid, 'uuid-1');
    });
  });

  group('getGenesHook', () {
    test('returns all genes when store is populated', () async {
      geneStore.value = [
        GeneStoreDto(
          geneId: 1,
          geneUuid: 'uuid-1',
          geneName: 'Brca1',
          isActive: true,
        ),
        GeneStoreDto(
          geneId: 2,
          geneUuid: 'uuid-2',
          geneName: 'Tp53',
          isActive: true,
        ),
      ];

      final result = await getGenesHook();
      expect(result.length, 2);
    });

    test('returns empty list when store is empty', () async {
      geneStore.value = [];
      final result = await getGenesHook();
      expect(result, isEmpty);
    });
  });

  group('getGeneHook', () {
    test('returns null for null uuid', () async {
      geneStore.value = [
        GeneStoreDto(
          geneId: 1,
          geneUuid: 'uuid-1',
          geneName: 'Brca1',
          isActive: true,
        ),
      ];

      final result = await getGeneHook(null);
      expect(result, isNull);
    });

    test('returns null for empty uuid', () async {
      geneStore.value = [
        GeneStoreDto(
          geneId: 1,
          geneUuid: 'uuid-1',
          geneName: 'Brca1',
          isActive: true,
        ),
      ];

      final result = await getGeneHook('');
      expect(result, isNull);
    });

    test('returns matching gene when uuid exists', () async {
      geneStore.value = [
        GeneStoreDto(
          geneId: 1,
          geneUuid: 'uuid-1',
          geneName: 'Brca1',
          isActive: true,
        ),
        GeneStoreDto(
          geneId: 2,
          geneUuid: 'uuid-2',
          geneName: 'Tp53',
          isActive: true,
        ),
      ];

      final result = await getGeneHook('uuid-2');
      expect(result, isNotNull);
      expect(result!.geneUuid, 'uuid-2');
      expect(result.geneName, 'Tp53');
    });
  });

  group('geneStore value', () {
    test('can be set and read', () {
      final genes = [
        GeneStoreDto(
          geneId: 1,
          geneUuid: 'uuid-1',
          geneName: 'Brca1',
          isActive: true,
        ),
      ];
      geneStore.value = genes;

      expect(geneStore.value, isNotNull);
      expect(geneStore.value!.length, 1);
      expect(geneStore.value!.first.geneName, 'Brca1');
    });

    test('defaults to null', () {
      expect(geneStore.value, isNull);
    });
  });
}
