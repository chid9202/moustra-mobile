import 'package:flutter/material.dart';

import 'package:moustra/widgets/cage/cage_detailed_view.dart';
import 'package:moustra/widgets/cage/cage_header.dart';
// TODO: Re-enable when compact view is needed
// import 'package:moustra/widgets/cage/cage_compact_view.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/widgets/cage/animal_drag_data.dart';
import 'package:moustra/stores/rack_store.dart';
import 'package:moustra/constants/cages_grid_constants.dart';

class CageInteractiveView extends StatefulWidget {
  final RackCageDto cage;
  final double zoomLevel;
  final RackDto rackData;
  final String? searchQuery;
  final String searchType;

  const CageInteractiveView({
    super.key,
    required this.cage,
    required this.zoomLevel,
    required this.rackData,
    this.searchQuery,
    this.searchType = CagesGridConstants.searchTypeAnimalTag,
  });

  @override
  State<CageInteractiveView> createState() => _CageInteractiveViewState();
}

class _CageInteractiveViewState extends State<CageInteractiveView> {
  bool _isDragOver = false;
  bool _isValidTarget = false;

  bool _shouldHighlightCage() {
    if (widget.searchQuery == null || widget.searchQuery!.isEmpty) {
      return false;
    }
    if (widget.searchType == CagesGridConstants.searchTypeCageTag) {
      final cageTag = widget.cage.cageTag ?? '';
      return cageTag.toLowerCase().contains(widget.searchQuery!.toLowerCase());
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    late final Widget childWidget;
    final shouldHighlight = _shouldHighlightCage();

    // Always show detailed view (compact view disabled for better visibility)
    // TODO: Re-enable compact view when needed
    // if (widget.zoomLevel >= 0.4) {
    childWidget = CageDetailedView(
      cage: widget.cage,
      zoomLevel: widget.zoomLevel,
      searchQuery: widget.searchQuery,
      searchType: widget.searchType,
    );
    // } else {
    //   childWidget = CageCompactView(cage: widget.cage);
    // }

    final borderColor = shouldHighlight
        ? Colors.yellow.shade700
        : (_isDragOver
              ? (_isValidTarget ? Colors.green : Colors.red)
              : Colors.blueGrey.shade400);
    final borderWidth = shouldHighlight ? 3.0 : (_isDragOver ? 3.0 : 2.0);

    final cardContent = Container(
      margin: const EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        color: shouldHighlight ? Colors.yellow.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cage header with background
          CageHeader(cage: widget.cage, showMenu: true),
          // Content area - use Flexible to allow shrinking when constrained
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: childWidget,
            ),
          ),
        ],
      ),
    );

    // Wrap in RepaintBoundary to isolate repaints during pan/zoom
    return RepaintBoundary(
      child: DragTarget<AnimalDragData>(
        onWillAccept: (data) {
          if (data == null) return false;
          final isValid = data.sourceCageUuid != widget.cage.cageUuid;
          setState(() {
            _isDragOver = true;
            _isValidTarget = isValid;
          });
          return isValid;
        },
        onLeave: (data) {
          setState(() {
            _isDragOver = false;
            _isValidTarget = false;
          });
        },
        onAccept: (data) async {
          setState(() {
            _isDragOver = false;
            _isValidTarget = false;
          });

          try {
            await moveAnimal(data.animalUuid, widget.cage.cageUuid);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Animal moved to ${widget.cage.cageTag ?? 'cage'}',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error moving animal: $e'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        },
        builder: (context, candidateData, rejectedData) {
          return cardContent;
        },
      ),
    );
  }
}
