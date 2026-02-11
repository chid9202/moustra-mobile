import 'package:flutter/material.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import '../colony_wizard_constants.dart';

/// Interactive rack grid for the colony wizard
class WizardRackGrid extends StatelessWidget {
  final RackDto rackData;
  final Function(int x, int y, RackCageDto? cage) onCellTapped;

  const WizardRackGrid({
    super.key,
    required this.rackData,
    required this.onCellTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = rackData.rackWidth ?? 6;
    final height = rackData.rackHeight ?? 4;
    final cages = rackData.cages ?? [];

    // Create a map for quick cage lookup by position
    final cageMap = <String, RackCageDto>{};
    for (final cage in cages) {
      if (cage.xPosition != null && cage.yPosition != null) {
        final key = '${cage.xPosition}-${cage.yPosition}';
        cageMap[key] = cage;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rack header
            Text(
              '${rackData.rackName ?? "Rack"} ($width x $height)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Grid
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: _buildGrid(context, theme, width, height, cageMap),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    ThemeData theme,
    int width,
    int height,
    Map<String, RackCageDto> cageMap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(height, (y) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: y < height - 1 ? ColonyWizardConstants.gridCellGap : 0,
          ),
          child: Row(
            children: List.generate(width, (x) {
              final key = '$x-$y';
              final cage = cageMap[key];
              final positionLabel = _getPositionLabel(x, y);

              return Padding(
                padding: EdgeInsets.only(
                  right: x < width - 1 ? ColonyWizardConstants.gridCellGap : 0,
                ),
                child: _GridCell(
                  positionLabel: positionLabel,
                  cage: cage,
                  onTap: () => onCellTapped(x, y, cage),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  /// Generate position label: A1, A2, B1, etc.
  String _getPositionLabel(int x, int y) {
    final rowLetter = String.fromCharCode(65 + y); // A, B, C...
    final colNumber = x + 1; // 1, 2, 3...
    return '$rowLetter$colNumber';
  }
}

class _GridCell extends StatelessWidget {
  final String positionLabel;
  final RackCageDto? cage;
  final VoidCallback onTap;

  const _GridCell({
    required this.positionLabel,
    required this.cage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOccupied = cage != null;

    return Tooltip(
      message: isOccupied
          ? _buildOccupiedTooltip()
          : 'Click to add cage $positionLabel',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: ColonyWizardConstants.gridCellSize,
          height: ColonyWizardConstants.gridCellSize,
          decoration: BoxDecoration(
            color: isOccupied
                ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                : theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isOccupied
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
              width: isOccupied ? 2 : 1,
            ),
          ),
          child: isOccupied
              ? _buildOccupiedCell(theme)
              : _buildEmptyCell(theme),
        ),
      ),
    );
  }

  Widget _buildEmptyCell(ThemeData theme) {
    return Center(
      child: Text(
        positionLabel,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildOccupiedCell(ThemeData theme) {
    final animals = cage!.animals ?? [];
    final maleCount = animals.where((a) => a.sex == 'M').length;
    final femaleCount = animals.where((a) => a.sex == 'F').length;
    final unknownCount = animals.where((a) => a.sex != 'M' && a.sex != 'F').length;
    final hasMating = cage!.mating != null;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cage tag
              Text(
                cage!.cageTag ?? positionLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              // Animal counts
              if (animals.isNotEmpty)
                Wrap(
                  spacing: 2,
                  runSpacing: 2,
                  alignment: WrapAlignment.center,
                  children: [
                    if (maleCount > 0)
                      _AnimalChip(
                        count: maleCount,
                        color: Colors.blue,
                      ),
                    if (femaleCount > 0)
                      _AnimalChip(
                        count: femaleCount,
                        color: Colors.pink,
                      ),
                    if (unknownCount > 0)
                      _AnimalChip(
                        count: unknownCount,
                        color: Colors.grey,
                      ),
                  ],
                ),
            ],
          ),
        ),
        // Mating indicator
        if (hasMating)
          Positioned(
            top: 2,
            right: 2,
            child: Icon(
              Icons.favorite,
              size: 12,
              color: Colors.red,
            ),
          ),
      ],
    );
  }

  String _buildOccupiedTooltip() {
    final animals = cage!.animals ?? [];
    final maleCount = animals.where((a) => a.sex == 'M').length;
    final femaleCount = animals.where((a) => a.sex == 'F').length;
    final hasMating = cage!.mating != null;

    final buffer = StringBuffer();
    buffer.write('Click to edit ${cage!.cageTag ?? positionLabel}');
    buffer.write(' - ${animals.length} animal(s)');
    if (animals.isNotEmpty) {
      buffer.write(' (${maleCount}M ${femaleCount}F)');
    }
    if (hasMating) {
      buffer.write(' - Mating');
    }
    return buffer.toString();
  }
}

class _AnimalChip extends StatelessWidget {
  final int count;
  final Color color;

  const _AnimalChip({
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
