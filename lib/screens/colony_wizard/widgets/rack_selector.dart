import 'package:flutter/material.dart';
import 'package:moustra/services/dtos/rack_dto.dart';

/// Horizontal scrollable rack selector with occupancy overview
class RackSelector extends StatelessWidget {
  final List<RackSimpleDto> racks;
  final RackSimpleDto? selectedRack;
  final RackDto? rackData;
  final Function(RackSimpleDto) onRackSelected;

  const RackSelector({
    super.key,
    required this.racks,
    required this.selectedRack,
    required this.rackData,
    required this.onRackSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: racks.map((rack) {
          final isSelected = selectedRack?.rackUuid == rack.rackUuid;
          final cageCount = _getCageCount(rack);
          final totalPositions = _getTotalPositions(rack);
          final isComplete = cageCount > 0 && cageCount >= totalPositions;
          final percentage =
              totalPositions > 0 ? (cageCount / totalPositions) * 100 : 0.0;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _RackCard(
              rack: rack,
              isSelected: isSelected,
              cageCount: cageCount,
              totalPositions: totalPositions,
              isComplete: isComplete,
              percentage: percentage,
              onTap: () => onRackSelected(rack),
            ),
          );
        }).toList(),
      ),
    );
  }

  int _getCageCount(RackSimpleDto rack) {
    if (rackData != null && rackData!.rackUuid == rack.rackUuid) {
      return rackData!.cages?.length ?? 0;
    }
    return 0;
  }

  int _getTotalPositions(RackSimpleDto rack) {
    if (rackData != null && rackData!.rackUuid == rack.rackUuid) {
      return (rackData!.rackWidth ?? 0) * (rackData!.rackHeight ?? 0);
    }
    // Return estimated value based on rack ID
    return 24; // Default assumption
  }
}

class _RackCard extends StatelessWidget {
  final RackSimpleDto rack;
  final bool isSelected;
  final int cageCount;
  final int totalPositions;
  final bool isComplete;
  final double percentage;
  final VoidCallback onTap;

  const _RackCard({
    required this.rack,
    required this.isSelected,
    required this.cageCount,
    required this.totalPositions,
    required this.isComplete,
    required this.percentage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withOpacity(0.5)
              : theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Name and complete indicator
            Row(
              children: [
                Expanded(
                  child: Text(
                    rack.rackName ?? 'Unnamed',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isComplete)
                  Icon(
                    Icons.check_circle,
                    size: 18,
                    color: Colors.green,
                  ),
              ],
            ),
            const SizedBox(height: 4),

            // Cage count
            Text(
              '$cageCount/$totalPositions cages',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 4,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isComplete ? Colors.green : theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
