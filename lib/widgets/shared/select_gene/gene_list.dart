import 'package:flutter/material.dart';
import 'package:moustra/services/dtos/stores/gene_store_dto.dart';
import 'package:moustra/services/dtos/stores/allele_store_dto.dart';
import 'package:moustra/stores/gene_store.dart';

class GeneList extends StatelessWidget {
  const GeneList({
    super.key,
    required this.genes,
    required this.tempSelectedGene,
    required this.tempSelectedAlleles,
    required this.isDeleteMode,
    required this.onGeneSelected,
    required this.onGeneDeleted,
    required this.onDeleteModeToggle,
    required this.onAddGene,
  });

  final List<GeneStoreDto>? genes;
  final GeneStoreDto? tempSelectedGene;
  final List<AlleleStoreDto> tempSelectedAlleles;
  final bool isDeleteMode;
  final Function(GeneStoreDto?) onGeneSelected;
  final Function(String) onGeneDeleted;
  final Function() onDeleteModeToggle;
  final Function() onAddGene;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Gene',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: onAddGene,
                  icon: const Icon(Icons.add, size: 20),
                  tooltip: 'Add Gene',
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: onDeleteModeToggle,
                  icon: Icon(
                    isDeleteMode ? Icons.check : Icons.delete,
                    size: 20,
                    color: isDeleteMode ? Colors.green : Colors.red,
                  ),
                  tooltip: isDeleteMode ? 'Exit Delete Mode' : 'Delete Mode',
                ),
              ],
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: genes?.where((g) => g.isActive).length ?? 0,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final gene = genes?.where((g) => g.isActive).toList()[index];
              return InkWell(
                onTap: isDeleteMode
                    ? null
                    : () {
                        onGeneSelected(gene);
                      },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: isDeleteMode ? 0 : 8),
                  child: Row(
                    children: [
                      if (!isDeleteMode) ...[
                        Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Radio<GeneStoreDto?>(
                            visualDensity: const VisualDensity(
                              horizontal: VisualDensity.minimumDensity,
                              vertical: VisualDensity.minimumDensity,
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            value: gene,
                            // ignore: deprecated_member_use
                            groupValue: tempSelectedGene,
                            // ignore: deprecated_member_use
                            onChanged: (GeneStoreDto? value) {
                              onGeneSelected(value);
                            },
                          ),
                        ),
                      ],
                      Expanded(
                        child: Text(
                          gene?.geneName ?? '',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      if (isDeleteMode) ...[
                        Padding(
                          padding: EdgeInsets.zero,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            visualDensity: const VisualDensity(
                              horizontal: 0,
                              vertical: 0,
                            ),
                            iconSize: 18,
                            onPressed: () async {
                              await deleteGeneHook(gene!.geneUuid);
                              onGeneDeleted(gene.geneUuid);
                            },
                            icon: const Icon(
                              Icons.delete,
                              size: 18,
                              color: Colors.red,
                            ),
                            tooltip: 'Delete Gene',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
