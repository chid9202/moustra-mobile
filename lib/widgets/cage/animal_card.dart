import 'package:flutter/material.dart';

import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/widgets/cage/animal_menu.dart';
import 'package:moustra/widgets/cage/animal_drag_data.dart';
import 'package:moustra/constants/cages_grid_constants.dart';

class AnimalCard extends StatefulWidget {
  final RackCageDto cage;
  final RackCageAnimalDto animal;
  final bool hasMating;
  final double zoomLevel;
  final String? searchQuery;
  final String searchType;

  const AnimalCard({
    super.key,
    required this.animal,
    required this.hasMating,
    required this.cage,
    required this.zoomLevel,
    this.searchQuery,
    this.searchType = CagesGridConstants.searchTypeAnimalTag,
  });

  @override
  State<AnimalCard> createState() => _AnimalCardState();
}

class _AnimalCardState extends State<AnimalCard> {
  bool _moving = false;

  bool _shouldHighlight() {
    if (widget.searchQuery == null || widget.searchQuery!.isEmpty) {
      return false;
    }
    if (widget.searchType == CagesGridConstants.searchTypeAnimalTag) {
      final physicalTag = widget.animal.physicalTag ?? '';
      return physicalTag.toLowerCase().contains(
        widget.searchQuery!.toLowerCase(),
      );
    }
    return false;
  }

  Color _getGenderColor() {
    final sex = widget.animal.sex?.toUpperCase();
    if (sex == 'M') return Colors.blue.shade600;
    if (sex == 'F') return Colors.pink.shade400;
    return Colors.grey;
  }

  Color _getGenderBackgroundColor() {
    final sex = widget.animal.sex?.toUpperCase();
    if (sex == 'M') return Colors.blue.shade50;
    if (sex == 'F') return Colors.pink.shade50;
    return Colors.grey.shade100;
  }

  Widget _buildGenderBadge({double size = 36}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getGenderBackgroundColor(),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getGenderColor(), width: 1.5),
      ),
      child: Center(
        child: Text(
          widget.animal.sex ?? '?',
          style: TextStyle(
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
            color: _getGenderColor(),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent({bool forFeedback = false}) {
    final shouldHighlight = _shouldHighlight();
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: shouldHighlight
              ? Colors.yellow.shade700
              : Colors.grey.shade200,
          width: shouldHighlight ? 2.0 : 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
        color: shouldHighlight ? Colors.yellow.shade50 : Colors.grey.shade50,
      ),
      child: Row(
        children: [
          // Left: Gender badge
          _buildGenderBadge(size: forFeedback ? 40 : 36),
          const SizedBox(width: 10),
          // Middle: Physical tag and genotypes
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Physical tag with bold font and icons
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.animal.physicalTag ?? 'No tag',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.hasMating) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.favorite, color: Colors.red.shade400, size: 14),
                    ],
                    if (widget.animal.litter != null) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.child_care, color: Colors.orange.shade400, size: 14),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                // Genotypes
                Text(
                  _formatGenotypes(),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          // Right: Menu or drag indicator
          if (forFeedback)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.drag_indicator, size: 20, color: Colors.grey),
            )
          else
            SizedBox(
              width: 32,
              child: _moving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
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
        ],
      ),
    );

    if (forFeedback) {
      return SizedBox(width: 280, child: content);
    }

    return content;
  }

  @override
  Widget build(BuildContext context) {
    final cardContent = _buildCardContent();

    // Only enable drag when zoomed in (detailed view)
    final canDrag = widget.zoomLevel >= 0.4 && !_moving;

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

}
