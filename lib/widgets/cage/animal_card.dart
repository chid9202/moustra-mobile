import 'package:flutter/material.dart';

import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/widgets/cage/animal_menu.dart';
import 'package:moustra/widgets/cage/animal_drag_data.dart';

class AnimalCard extends StatefulWidget {
  final RackCageDto cage;
  final RackCageAnimalDto animal;
  final bool hasMating;
  final double zoomLevel;

  const AnimalCard({
    super.key,
    required this.animal,
    required this.hasMating,
    required this.cage,
    required this.zoomLevel,
  });

  @override
  State<AnimalCard> createState() => _AnimalCardState();
}

class _AnimalCardState extends State<AnimalCard> {
  bool _moving = false;

  Widget _buildCardContent({bool forFeedback = false}) {
    final content = Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        children: [
          // Left: Gender with large font
          if (forFeedback)
            SizedBox(
              width: 60,
              child: Center(
                child: Text(
                  widget.animal.sex ?? 'U',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  widget.animal.sex ?? 'U',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          // Middle: Physical tag and genotypes
          if (forFeedback)
            SizedBox(
              width: 180,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Physical tag with bold font and heart icon if has mating
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          _getCardTitle(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.animal.litter != null) ...[
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
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            )
          else
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
                      if (widget.animal.litter != null) ...[
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
          if (forFeedback)
            const SizedBox(
              width: 60,
              child: Center(child: Icon(Icons.drag_indicator, size: 24)),
            )
          else
            Expanded(
              flex: 1,
              child: Center(
                child: _moving
                    ? const CircularProgressIndicator()
                    : AnimalMenu(
                        cage: widget.cage,
                        animal: widget.animal,
                        onMovingStateChanged: (bool value) {
                          setState(() {
                            _moving = value;
                          });
                        },
                      ),
              ),
            ),
        ],
      ),
    );

    if (forFeedback) {
      return SizedBox(width: 300, child: content);
    }

    return content;
  }

  @override
  Widget build(BuildContext context) {
    final cardContent = _buildCardContent();

    // Only enable drag when zoomed in (detailed view)
    final canDrag = widget.zoomLevel >= 0.8 && !_moving;

    if (!canDrag) {
      return cardContent;
    }

    final dragData = AnimalDragData(
      animalUuid: widget.animal.animalUuid,
      sourceCageUuid: widget.cage.cageUuid,
    );

    return LongPressDraggable<AnimalDragData>(
      data: dragData,
      feedback: Material(
        elevation: 6.0,
        borderRadius: BorderRadius.circular(4.0),
        child: Opacity(
          opacity: 0.8,
          child: _buildCardContent(forFeedback: true),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: cardContent),
      child: cardContent,
    );
  }

  String _formatGenotypes() {
    if (widget.animal.genotypes == null || widget.animal.genotypes!.isEmpty) {
      return 'No genotypes';
    }

    return widget.animal.genotypes!
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
    var physicalTag = widget.animal.physicalTag ?? 'No tag';
    if (widget.hasMating) {
      physicalTag += ' 💕';
    }
    return physicalTag;
  }
}
