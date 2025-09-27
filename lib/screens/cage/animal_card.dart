import 'package:flutter/material.dart';
import 'package:moustra/services/dtos/rack_dto.dart';

class AnimalCard extends StatelessWidget {
  final RackCageAnimalDto animal;
  final bool hasMating;

  const AnimalCard({super.key, required this.animal, required this.hasMating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        children: [
          // Left: Gender with large font
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                animal.sex ?? 'U',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Middle: Physical tag and genotypes
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Physical tag with bold font and heart icon if has mating
                Row(
                  children: [
                    Text(
                      _getCardTitle(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (animal.litter != null) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.favorite, color: Colors.red, size: 16),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                // Genotypes using formatGenotypes method
                Text(
                  _formatGenotypes(),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          // Right: Menu icon
          Expanded(
            flex: 1,
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // Show menu for now
                  _showMenu(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatGenotypes() {
    if (animal.genotypes == null || animal.genotypes!.isEmpty) {
      return 'No genotypes';
    }

    return animal.genotypes!
        .map((g) {
          final String gene = (g.gene?.geneName ?? '').toString();
          final String allele = (g.allele?.alleleName ?? '').toString();
          if (gene.isNotEmpty && allele.isNotEmpty) {
            return '$gene/$allele';
          }
          if (gene.isNotEmpty) {
            return gene;
          }
          if (allele.isNotEmpty) {
            return allele;
          }
          return '';
        })
        .where((s) => s.isNotEmpty)
        .join(', ');
  }

  String _getCardTitle() {
    var physicalTag = animal.physicalTag ?? 'No tag';
    if (hasMating) {
      physicalTag += ' [mating]';
    }
    return physicalTag;
  }

  void _showMenu(BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 0, 0),
      items: [
        const PopupMenuItem(value: 'open', child: Text('Open')),
        const PopupMenuItem(value: 'end', child: Text('End')),
        const PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    ).then((value) {
      if (value != null) {
        // Handle menu selection
        print('Selected: $value for animal ${animal.physicalTag}');
      }
    });
  }
}
