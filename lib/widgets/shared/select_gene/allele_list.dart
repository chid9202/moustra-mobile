import 'package:flutter/material.dart';
import 'package:moustra/services/dtos/stores/gene_store_dto.dart';
import 'package:moustra/services/dtos/stores/allele_store_dto.dart';
import 'package:moustra/stores/allele_store.dart';

class AlleleList extends StatelessWidget {
  const AlleleList({
    super.key,
    required this.alleles,
    required this.tempSelectedGene,
    required this.tempSelectedAlleles,
    required this.isDeleteMode,
    required this.onAlleleToggled,
    required this.onAlleleDeleted,
    required this.onDeleteModeToggle,
    required this.onAddAllele,
  });

  final List<AlleleStoreDto>? alleles;
  final GeneStoreDto? tempSelectedGene;
  final List<AlleleStoreDto> tempSelectedAlleles;
  final bool isDeleteMode;
  final Function(AlleleStoreDto) onAlleleToggled;
  final Function(String) onAlleleDeleted;
  final Function() onDeleteModeToggle;
  final Function() onAddAllele;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Alleles',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onAddAllele,
                  icon: const Icon(Icons.add, size: 20),
                  tooltip: 'Add Allele',
                ),
                IconButton(
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
            itemCount: alleles?.where((a) => a.isActive).length ?? 0,
            itemBuilder: (context, index) {
              final allele = alleles?.where((a) => a.isActive).toList()[index];
              final isSelected = tempSelectedAlleles.any(
                (a) => a.alleleUuid == allele?.alleleUuid,
              );

              return InkWell(
                onTap: isDeleteMode
                    ? null
                    : tempSelectedGene != null
                    ? () {
                        onAlleleToggled(allele!);
                      }
                    : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      if (!isDeleteMode) ...[
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Checkbox(
                            visualDensity: const VisualDensity(
                              horizontal: VisualDensity.minimumDensity,
                              vertical: VisualDensity.minimumDensity,
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            value: isSelected,
                            onChanged: tempSelectedGene != null
                                ? (bool? value) {
                                    onAlleleToggled(allele!);
                                  }
                                : null,
                          ),
                        ),
                      ],
                      Expanded(
                        child: Text(
                          allele?.alleleName ?? '',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      if (isDeleteMode) ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: IconButton(
                            onPressed: () async {
                              try {
                                await deleteAlleleHook(allele!.alleleUuid);
                                onAlleleDeleted(allele.alleleUuid);
                              } catch (e) {
                                print('Error deleting allele: $e');
                              }
                            },
                            icon: const Icon(
                              Icons.delete,
                              size: 18,
                              color: Colors.red,
                            ),
                            tooltip: 'Delete Allele',
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
