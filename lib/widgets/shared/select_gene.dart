import 'package:flutter/material.dart';
import 'package:moustra/services/clients/store_api.dart';
import 'package:moustra/services/dtos/stores/gene_store_dto.dart';
import 'package:moustra/services/dtos/stores/allele_store_dto.dart';
import 'package:moustra/services/dtos/genotype_dto.dart';

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
  List<GeneStoreDto>? genes;
  List<AlleleStoreDto>? alleles;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    if (genes == null && alleles == null && mounted) {
      try {
        final loadedGenes = await StoreApi<GeneStoreDto>().getStore(
          StoreKeys.gene,
        );
        final loadedAlleles = await StoreApi<AlleleStoreDto>().getStore(
          StoreKeys.allele,
        );

        if (mounted) {
          setState(() {
            genes = loadedGenes;
            alleles = loadedAlleles;
          });
        }
      } catch (e) {
        print('Error loading genes and alleles: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    void showGenePicker() {
      List<GenotypeDto> tempSelectedGenotypes = List.from(
        widget.selectedGenotypes,
      );
      GeneStoreDto? tempSelectedGene;
      List<AlleleStoreDto> tempSelectedAlleles = [];

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Select Genotypes'),
                content: SizedBox(
                  width: double.maxFinite,
                  height: 500,
                  child: Column(
                    children: [
                      // Current Genotypes
                      if (tempSelectedGenotypes.isNotEmpty) ...[
                        const Text(
                          'Selected Genotypes:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          flex: 2,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: tempSelectedGenotypes.length,
                            itemBuilder: (context, index) {
                              final genotype = tempSelectedGenotypes[index];
                              return Card(
                                child: ListTile(
                                  title: Text(
                                    '${genotype.gene?.geneName ?? 'Unknown'}: ${genotype.allele?.alleleName ?? 'Unknown'}',
                                  ),
                                  trailing: IconButton(
                                    onPressed: () {
                                      setDialogState(() {
                                        tempSelectedGenotypes.removeAt(index);
                                      });
                                    },
                                    icon: const Icon(Icons.delete),
                                    tooltip: 'Remove genotype',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const Divider(),
                      ],
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Gene',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            _showAddGeneDialog(setDialogState),
                                        icon: const Icon(Icons.add, size: 20),
                                        tooltip: 'Add Gene',
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: genes?.length ?? 0,
                                      itemBuilder: (context, index) {
                                        final gene = genes?[index];
                                        return RadioListTile<GeneStoreDto?>(
                                          title: Text(
                                            gene?.geneName ?? '',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                          value: gene,
                                          // ignore: deprecated_member_use
                                          groupValue: tempSelectedGene,
                                          // ignore: deprecated_member_use
                                          onChanged: (GeneStoreDto? value) {
                                            setDialogState(() {
                                              tempSelectedGene = value;
                                              tempSelectedAlleles.clear();
                                            });
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Allele Column
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Alleles',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => _showAddAlleleDialog(
                                          setDialogState,
                                        ),
                                        icon: const Icon(Icons.add, size: 20),
                                        tooltip: 'Add Allele',
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: alleles?.length ?? 0,
                                      itemBuilder: (context, index) {
                                        final allele = alleles?[index];
                                        final isSelected = tempSelectedAlleles
                                            .any(
                                              (a) =>
                                                  a.alleleUuid ==
                                                  allele?.alleleUuid,
                                            );

                                        return CheckboxListTile(
                                          title: Text(
                                            allele?.alleleName ?? '',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                          value: isSelected,
                                          onChanged: tempSelectedGene != null
                                              ? (bool? value) {
                                                  setDialogState(() {
                                                    if (value == true) {
                                                      tempSelectedAlleles.add(
                                                        allele!,
                                                      );
                                                    } else {
                                                      tempSelectedAlleles
                                                          .removeWhere(
                                                            (a) =>
                                                                a.alleleUuid ==
                                                                allele
                                                                    ?.alleleUuid,
                                                          );
                                                    }
                                                  });
                                                }
                                              : null,
                                        );
                                      },
                                    ),
                                  ),
                                ],
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
                              int order = tempSelectedGenotypes.length + 1;
                              for (final allele in tempSelectedAlleles) {
                                final newGenotype = GenotypeDto(
                                  gene: GeneDto(
                                    geneId: tempSelectedGene!.geneId,
                                    geneUuid: tempSelectedGene!.geneUuid,
                                    geneName: tempSelectedGene!.geneName,
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
                                          newGenotype.allele?.alleleUuid,
                                )) {
                                  tempSelectedGenotypes.add(newGenotype);
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
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  // TODO: Implement API call to create gene
                  // For now, create a mock DTO
                  final newGene = GeneStoreDto(
                    geneId: DateTime.now().millisecondsSinceEpoch,
                    geneUuid: 'temp-${DateTime.now().millisecondsSinceEpoch}',
                    geneName: controller.text.trim(),
                  );
                  setDialogState(() {
                    genes?.add(newGene);
                  });
                  Navigator.of(context).pop();
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
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  // TODO: Implement API call to create allele
                  // For now, create a mock DTO
                  final newAllele = AlleleStoreDto(
                    alleleId: DateTime.now().millisecondsSinceEpoch,
                    alleleUuid: 'temp-${DateTime.now().millisecondsSinceEpoch}',
                    alleleName: controller.text.trim(),
                  );
                  setDialogState(() {
                    alleles?.add(newAllele);
                  });
                  Navigator.of(context).pop();
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
