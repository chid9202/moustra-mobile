import 'package:flutter/material.dart';
import 'package:moustra/services/dtos/genotype_dto.dart';

class SelectedGenotypeChips extends StatelessWidget {
  const SelectedGenotypeChips({
    super.key,
    required this.selectedGenotypes,
    required this.onGenotypeRemoved,
  });

  final List<GenotypeDto> selectedGenotypes;
  final Function(int) onGenotypeRemoved;

  @override
  Widget build(BuildContext context) {
    if (selectedGenotypes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const Text(
          'Selected Genotypes:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: selectedGenotypes.asMap().entries.map((entry) {
              final index = entry.key;
              final genotype = entry.value;
              return Chip(
                label: Text(
                  '${genotype.gene?.geneName ?? 'Unknown'}: ${genotype.allele?.alleleName ?? 'Unknown'}',
                  style: const TextStyle(fontSize: 12),
                ),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  onGenotypeRemoved(index);
                },
                backgroundColor: Colors.blue.shade50,
                deleteIconColor: Colors.red,
              );
            }).toList(),
          ),
        ),
        const Divider(),
      ],
    );
  }
}
