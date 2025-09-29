import 'package:flutter/material.dart';
import 'package:moustra/services/dtos/stores/gene_store_dto.dart';
import 'package:moustra/services/dtos/stores/allele_store_dto.dart';
import 'package:moustra/services/dtos/genotype_dto.dart';
import 'package:moustra/stores/allele_store.dart';
import 'package:moustra/stores/gene_store.dart';
import 'package:moustra/widgets/shared/select_gene/gene_list.dart';
import 'package:moustra/widgets/shared/select_gene/allele_list.dart';
import 'package:moustra/widgets/shared/select_gene/selected_genotype_chips.dart';

class SelectGene extends StatefulWidget {
  const SelectGene({
    super.key,
    required this.selectedGenotypes,
    required this.onGenotypesChanged,
    required this.label,
    required this.placeholderText,
  });

  final List<GenotypeDto> selectedGenotypes;
  final Function(List<GenotypeDto>) onGenotypesChanged;
  final String label;
  final String placeholderText;

  @override
  State<SelectGene> createState() => _SelectGeneState();
}

class _SelectGeneState extends State<SelectGene> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    // Initialize stores if they haven't been loaded yet
    await getGenesHook();
    await getAllelesHook();
  }

  @override
  Widget build(BuildContext context) {
    void showGenePicker() {
      List<GenotypeDto> tempSelectedGenotypes = List.from(
        widget.selectedGenotypes,
      );
      GeneStoreDto? tempSelectedGene;
      List<AlleleStoreDto> tempSelectedAlleles = [];
      bool isDeleteMode = false;
      bool isAlleleDeleteMode = false;

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return ValueListenableBuilder<List<GeneStoreDto>?>(
                valueListenable: geneStore,
                builder: (context, genes, _) {
                  return ValueListenableBuilder<List<AlleleStoreDto>?>(
                    valueListenable: alleleStore,
                    builder: (context, alleles, _) {
                      return AlertDialog(
                        title: const Text('Select Genotypes'),
                        content: SizedBox(
                          width: double.maxFinite,
                          // height: 500,
                          child: Column(
                            children: [
                              // Current Genotypes
                              Expanded(
                                flex: 0,
                                child: SelectedGenotypeChips(
                                  selectedGenotypes: tempSelectedGenotypes,
                                  onGenotypeRemoved: (index) {
                                    setDialogState(() {
                                      tempSelectedGenotypes.removeAt(index);
                                    });
                                  },
                                ),
                              ),
                              // Add New Genotype
                              const Text(
                                'Add New Genotype:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                flex: 3,
                                child: Row(
                                  children: [
                                    // Gene Column
                                    Expanded(
                                      child: GeneList(
                                        genes: genes,
                                        tempSelectedGene: tempSelectedGene,
                                        tempSelectedAlleles:
                                            tempSelectedAlleles,
                                        isDeleteMode: isDeleteMode,
                                        onGeneSelected: (gene) {
                                          setDialogState(() {
                                            tempSelectedGene = gene;
                                            tempSelectedAlleles.clear();
                                          });
                                        },
                                        onGeneDeleted: (geneUuid) {
                                          setDialogState(() {
                                            tempSelectedGene = null;
                                            tempSelectedAlleles.clear();
                                          });
                                        },
                                        onDeleteModeToggle: () {
                                          setDialogState(() {
                                            isDeleteMode = !isDeleteMode;
                                          });
                                        },
                                        onAddGene: () {
                                          _showAddGeneDialog(setDialogState);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Allele Column
                                    Expanded(
                                      child: AlleleList(
                                        alleles: alleles,
                                        tempSelectedGene: tempSelectedGene,
                                        tempSelectedAlleles:
                                            tempSelectedAlleles,
                                        isDeleteMode: isAlleleDeleteMode,
                                        onAlleleToggled: (allele) {
                                          setDialogState(() {
                                            if (tempSelectedAlleles.any(
                                              (a) =>
                                                  a.alleleUuid ==
                                                  allele.alleleUuid,
                                            )) {
                                              tempSelectedAlleles.removeWhere(
                                                (a) =>
                                                    a.alleleUuid ==
                                                    allele.alleleUuid,
                                              );
                                            } else {
                                              tempSelectedAlleles.add(allele);
                                            }
                                          });
                                        },
                                        onAlleleDeleted: (alleleUuid) {
                                          setDialogState(() {
                                            tempSelectedAlleles.clear();
                                          });
                                        },
                                        onDeleteModeToggle: () {
                                          setDialogState(() {
                                            isAlleleDeleteMode =
                                                !isAlleleDeleteMode;
                                          });
                                        },
                                        onAddAllele: () {
                                          _showAddAlleleDialog(setDialogState);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Add Genotype Button
                              if (tempSelectedGene != null &&
                                  tempSelectedAlleles.isNotEmpty)
                                ElevatedButton(
                                  onPressed: () {
                                    setDialogState(() {
                                      int order =
                                          tempSelectedGenotypes.length + 1;
                                      for (final allele
                                          in tempSelectedAlleles) {
                                        final newGenotype = GenotypeDto(
                                          gene: GeneDto(
                                            geneId: tempSelectedGene!.geneId,
                                            geneUuid:
                                                tempSelectedGene!.geneUuid,
                                            geneName:
                                                tempSelectedGene!.geneName,
                                          ),
                                          allele: AlleleDto(
                                            alleleId: allele.alleleId,
                                            alleleUuid: allele.alleleUuid,
                                            alleleName: allele.alleleName,
                                            createdDate: DateTime.now(),
                                          ),
                                          order: order++,
                                        );
                                        // Check if genotype already exists
                                        if (!tempSelectedGenotypes.any(
                                          (g) =>
                                              g.gene?.geneUuid ==
                                                  newGenotype.gene?.geneUuid &&
                                              g.allele?.alleleUuid ==
                                                  newGenotype
                                                      .allele
                                                      ?.alleleUuid,
                                        )) {
                                          tempSelectedGenotypes.insert(
                                            0,
                                            newGenotype,
                                          );
                                        }
                                      }
                                      tempSelectedGene = null;
                                      tempSelectedAlleles.clear();
                                    });
                                  },
                                  child: const Text('Add Genotypes'),
                                ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              widget.onGenotypesChanged(tempSelectedGenotypes);
                              Navigator.of(context).pop(true);
                            },
                            child: const Text('OK'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: const Text('Cancel'),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ).then((saved) {
        if (saved != true) {
          // Dialog was closed without saving, reset to original values
          widget.onGenotypesChanged(List.from(widget.selectedGenotypes));
        }
      });
    }

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: showGenePicker,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: widget.label,
                border: const OutlineInputBorder(),
              ),
              child: _buildDisplayText(),
            ),
          ),
        ),
        if (widget.selectedGenotypes.isNotEmpty) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              widget.onGenotypesChanged([]);
            },
            icon: Icon(Icons.clear, color: Colors.grey[600]),
            tooltip: 'Clear all genotypes',
          ),
        ],
      ],
    );
  }

  Widget _buildDisplayText() {
    if (widget.selectedGenotypes.isEmpty) {
      return Text(widget.placeholderText, style: TextStyle(color: Colors.grey));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${widget.selectedGenotypes.length} genotype(s) selected',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        if (widget.selectedGenotypes.length <= 3)
          ...widget.selectedGenotypes.map(
            (genotype) => Text(
              '${genotype.gene?.geneName ?? 'Unknown'}: ${genotype.allele?.alleleName ?? 'Unknown'}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        if (widget.selectedGenotypes.length > 3)
          Text(
            '${widget.selectedGenotypes.take(2).map((g) => '${g.gene?.geneName ?? 'Unknown'}: ${g.allele?.alleleName ?? 'Unknown'}').join(', ')} and ${widget.selectedGenotypes.length - 2} more...',
            style: const TextStyle(fontSize: 12),
          ),
      ],
    );
  }

  void _showAddGeneDialog(StateSetter setDialogState) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Gene'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Gene Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  print('Creating gene: ${controller.text}');
                  Navigator.of(context).pop();
                  await postGeneHook(controller.text);
                  print('Gene creation completed');
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showAddAlleleDialog(StateSetter setDialogState) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Allele'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Allele Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  print('Creating allele: ${controller.text}');
                  Navigator.of(context).pop();
                  await postAlleleHook(controller.text);
                  print('Allele creation completed');
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
