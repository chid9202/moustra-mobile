import 'package:flutter/material.dart';
import 'package:moustra/helpers/rack_utils.dart';
import 'package:moustra/services/dtos/rack_dto.dart';

/// Compact visual rack grid for position selection, cage picking, and move/swap flows.
///
/// Used in:
/// - Cage creation (select position)
/// - Move cage dialog (pick target or swap)
/// - Move animal dialog (pick target cage or create new)
/// - Cage select autocomplete (grid picker mode)
class RackCageGrid extends StatelessWidget {
  final List<RackSimpleDto> racks;
  final RackDto? selectedRack;
  final String? selectedCageUuid;
  final RackGridPosition? selectedPosition;
  final String? sourceCageUuid;
  final bool hideRackSelector;
  final String emptyTooltipPrefix;
  final ValueChanged<String> onChangeRack;
  final ValueChanged<RackCageDto> onSelectCage;
  final void Function(String posLabel, int x, int y)? onCreateCage;

  const RackCageGrid({
    super.key,
    required this.racks,
    this.selectedRack,
    this.selectedCageUuid,
    this.selectedPosition,
    this.sourceCageUuid,
    this.hideRackSelector = false,
    this.emptyTooltipPrefix = 'Add cage at',
    required this.onChangeRack,
    required this.onSelectCage,
    this.onCreateCage,
  });

  @override
  Widget build(BuildContext context) {
    final rackWidth = selectedRack?.rackWidth ?? 3;
    final rackHeight = selectedRack?.rackHeight ?? 3;
    final cages = selectedRack?.cages ?? [];

    // Build position map for O(1) lookup
    final cagesByPosition = <String, RackCageDto>{};
    final hasPositionData = cages.any(
      (c) => c.xPosition != null && c.yPosition != null,
    );
    if (hasPositionData) {
      for (final cage in cages) {
        if (cage.xPosition != null && cage.yPosition != null) {
          cagesByPosition['${cage.xPosition},${cage.yPosition}'] = cage;
        }
      }
    } else {
      for (var i = 0; i < cages.length; i++) {
        final x = i % rackWidth;
        final y = i ~/ rackWidth;
        cagesByPosition['$x,$y'] = cages[i];
      }
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Rack selector
        if (!hideRackSelector && racks.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: racks.length <= 6
                ? _RackChips(
                    racks: racks,
                    selectedRackUuid: selectedRack?.rackUuid,
                    onChangeRack: onChangeRack,
                  )
                : _RackDropdown(
                    racks: racks,
                    selectedRackUuid: selectedRack?.rackUuid,
                    onChangeRack: onChangeRack,
                  ),
          ),

        // Grid
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column headers (numbers: 1, 2, 3...)
              Row(
                children: [
                  const SizedBox(width: 28), // row header space
                  for (var x = 0; x < rackWidth; x++)
                    SizedBox(
                      width: 52,
                      child: Center(
                        child: Text(
                          '${x + 1}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),

              // Rows
              for (var y = 0; y < rackHeight; y++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      // Row header (letter: A, B, C...)
                      SizedBox(
                        width: 28,
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + y),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      // Cells
                      for (var x = 0; x < rackWidth; x++)
                        _buildCell(
                          context,
                          x,
                          y,
                          cagesByPosition['$x,$y'],
                          colorScheme,
                          theme,
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCell(
    BuildContext context,
    int x,
    int y,
    RackCageDto? cage,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    final rowLetter = String.fromCharCode(65 + y);
    final posLabel = '$rowLetter${x + 1}';

    if (cage != null) {
      return _OccupiedCell(
        cage: cage,
        isSelected: cage.cageUuid == selectedCageUuid,
        isSource: cage.cageUuid == sourceCageUuid,
        onTap: () => onSelectCage(cage),
        colorScheme: colorScheme,
        theme: theme,
      );
    }

    final isSelected =
        selectedPosition?.x == x && selectedPosition?.y == y;
    final isClickable = onCreateCage != null;

    return _EmptyCell(
      posLabel: posLabel,
      tooltipPrefix: emptyTooltipPrefix,
      isSelected: isSelected,
      isClickable: isClickable,
      onTap: isClickable ? () => onCreateCage!(posLabel, x, y) : null,
      colorScheme: colorScheme,
      theme: theme,
    );
  }
}

// ─── Rack Chips ──────────────────────────────────────────────────────

class _RackChips extends StatelessWidget {
  final List<RackSimpleDto> racks;
  final String? selectedRackUuid;
  final ValueChanged<String> onChangeRack;

  const _RackChips({
    required this.racks,
    this.selectedRackUuid,
    required this.onChangeRack,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: racks.map((rack) {
        final isSelected = rack.rackUuid == selectedRackUuid;
        return ChoiceChip(
          label: Text(rack.rackName ?? 'Unnamed'),
          selected: isSelected,
          onSelected: (_) => onChangeRack(rack.rackUuid),
          visualDensity: VisualDensity.compact,
        );
      }).toList(),
    );
  }
}

// ─── Rack Dropdown ───────────────────────────────────────────────────

class _RackDropdown extends StatelessWidget {
  final List<RackSimpleDto> racks;
  final String? selectedRackUuid;
  final ValueChanged<String> onChangeRack;

  const _RackDropdown({
    required this.racks,
    this.selectedRackUuid,
    required this.onChangeRack,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedRackUuid,
      decoration: const InputDecoration(
        labelText: 'Rack',
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: racks.map((rack) {
        return DropdownMenuItem(
          value: rack.rackUuid,
          child: Text(rack.rackName ?? 'Unnamed'),
        );
      }).toList(),
      onChanged: (uuid) {
        if (uuid != null) onChangeRack(uuid);
      },
    );
  }
}

// ─── Occupied Cell ───────────────────────────────────────────────────

class _OccupiedCell extends StatelessWidget {
  final RackCageDto cage;
  final bool isSelected;
  final bool isSource;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _OccupiedCell({
    required this.cage,
    required this.isSelected,
    required this.isSource,
    required this.onTap,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final animalCount = cage.animals?.length ?? 0;
    final tag = cage.cageTag ?? '';

    final tooltipLines = [tag];
    if (animalCount > 0) {
      tooltipLines.add('$animalCount animal${animalCount != 1 ? 's' : ''}');
    }
    if (cage.strain?.strainName != null) {
      tooltipLines.add(cage.strain!.strainName!);
    }

    return Tooltip(
      message: tooltipLines.join(' \u00B7 '),
      child: GestureDetector(
        onTap: isSource ? null : onTap,
        child: Container(
          width: 48,
          height: 48,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSource
                  ? colorScheme.outlineVariant
                  : isSelected
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
              width: isSelected ? 2 : 1,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
            color: isSource
                ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                : isSelected
                    ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                    : colorScheme.surface,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                tag,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSource
                      ? colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                      : colorScheme.onSurface,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
              ),
              if (animalCount > 0)
                Text(
                  '$animalCount',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: isSource
                        ? colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Empty Cell ──────────────────────────────────────────────────────

class _EmptyCell extends StatelessWidget {
  final String posLabel;
  final String tooltipPrefix;
  final bool isSelected;
  final bool isClickable;
  final VoidCallback? onTap;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _EmptyCell({
    required this.posLabel,
    required this.tooltipPrefix,
    required this.isSelected,
    required this.isClickable,
    this.onTap,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isClickable ? '$tooltipPrefix $posLabel' : '',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
              width: isSelected ? 2 : 1,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
            color: isSelected
                ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
          child: isClickable
              ? Center(
                  child: Text(
                    '+',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
