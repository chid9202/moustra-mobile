import 'package:flutter/material.dart';

import 'package:moustra/widgets/cage/cage_detailed_view.dart';
import 'package:moustra/widgets/cage/cage_compact_view.dart';
import 'package:moustra/services/dtos/rack_dto.dart';

class CageInteractiveView extends StatelessWidget {
  final RackCageDto cage;
  final double zoomLevel;
  final RackDto rackData;

  const CageInteractiveView({
    super.key,
    required this.cage,
    required this.zoomLevel,
    required this.rackData,
  });

  @override
  Widget build(BuildContext context) {
    late final Widget childWidget;

    // Show detailed view when zoomed in (zoom >= 0.8)
    // Show compact view when zoomed out (zoom < 0.8)
    if (zoomLevel >= 0.8) {
      childWidget = CageDetailedView(cage: cage);
    } else {
      childWidget = CageCompactView(cage: cage);
    }

    return Card(
      elevation: 12.0,
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: const BorderSide(color: Colors.grey, width: 2.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [Expanded(child: childWidget)],
        ),
      ),
    );
  }
}
