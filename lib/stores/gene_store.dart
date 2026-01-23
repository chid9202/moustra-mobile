import 'package:flutter/material.dart';
import 'package:moustra/services/clients/gene_api.dart';
import 'package:moustra/services/clients/store_api.dart';
import 'package:moustra/services/dtos/stores/gene_store_dto.dart';

final geneStore = ValueNotifier<List<GeneStoreDto>?>(null);

Future<List<GeneStoreDto>> useGeneStore() async {
  if (geneStore.value == null) {
    final value = await StoreApi<GeneStoreDto>().getStore(StoreKeys.gene);
    geneStore.value = value;
    return value;
  }
  return geneStore.value ?? [];
}

Future<List<GeneStoreDto>> getGenesHook() async {
  await useGeneStore();
  return geneStore.value ?? [];
}

Future<GeneStoreDto?> getGeneHook(String? uuid) async {
  if (uuid == null || uuid == '') {
    return null;
  }
  await useGeneStore();
  return geneStore.value?.firstWhere((gene) => gene.geneUuid == uuid);
}

Future<GeneStoreDto> postGeneHook(String geneName) async {
  final newGene = await geneApi.postGene(geneName);
  // Fetch full list to maintain integrity
  final value = await StoreApi<GeneStoreDto>().getStore(StoreKeys.gene);
  debugPrint('Gene store updated after create, new count: ${value.length}');
  geneStore.value = value;
  return newGene;
}

Future<void> deleteGeneHook(String geneUuid) async {
  await geneApi.deleteGene(geneUuid);
  // Fetch full list to maintain integrity
  final value = await StoreApi<GeneStoreDto>().getStore(StoreKeys.gene);
  debugPrint('Gene store updated after delete, new count: ${value.length}');
  geneStore.value = value;
}
