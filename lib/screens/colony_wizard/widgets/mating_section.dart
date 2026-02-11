import 'package:flutter/material.dart';
import 'package:moustra/services/dtos/stores/strain_store_dto.dart';
import 'strain_picker.dart';

/// Collapsible mating section with pup counter
class MatingSection extends StatelessWidget {
  final bool expanded;
  final bool hasMaturePair;
  final TextEditingController matingTagController;
  final StrainStoreDto? litterStrain;
  final List<StrainStoreDto> strains;
  final int pupMaleCount;
  final int pupFemaleCount;
  final int pupUnknownCount;
  final Function(bool) onExpandedChanged;
  final VoidCallback onMatingTagChanged;
  final Function(StrainStoreDto?) onLitterStrainChanged;
  final Function(int male, int female, int unknown) onPupCountChanged;

  const MatingSection({
    super.key,
    required this.expanded,
    required this.hasMaturePair,
    required this.matingTagController,
    required this.litterStrain,
    required this.strains,
    required this.pupMaleCount,
    required this.pupFemaleCount,
    required this.pupUnknownCount,
    required this.onExpandedChanged,
    required this.onMatingTagChanged,
    required this.onLitterStrainChanged,
    required this.onPupCountChanged,
  });

  int get totalPups => pupMaleCount + pupFemaleCount + pupUnknownCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: () => onExpandedChanged(!expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Mating',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (hasMaturePair) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Mature pair detected',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ],
              ),
            ),
          ),

          // Content
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 12),

                  // Mating tag and strain
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: matingTagController,
                          decoration: const InputDecoration(
                            labelText: 'Mating Tag',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (_) => onMatingTagChanged(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StrainPicker(
                          label: 'Litter Strain',
                          value: litterStrain,
                          strains: strains,
                          onChanged: onLitterStrainChanged,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Pups section
                  Text(
                    'Pups',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Pup counter buttons
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _PupCounter(
                        label: 'Male',
                        count: pupMaleCount,
                        color: Colors.blue,
                        onIncrement: () => onPupCountChanged(
                          pupMaleCount + 1,
                          pupFemaleCount,
                          pupUnknownCount,
                        ),
                        onDecrement: pupMaleCount > 0
                            ? () => onPupCountChanged(
                                  pupMaleCount - 1,
                                  pupFemaleCount,
                                  pupUnknownCount,
                                )
                            : null,
                      ),
                      _PupCounter(
                        label: 'Female',
                        count: pupFemaleCount,
                        color: Colors.pink,
                        onIncrement: () => onPupCountChanged(
                          pupMaleCount,
                          pupFemaleCount + 1,
                          pupUnknownCount,
                        ),
                        onDecrement: pupFemaleCount > 0
                            ? () => onPupCountChanged(
                                  pupMaleCount,
                                  pupFemaleCount - 1,
                                  pupUnknownCount,
                                )
                            : null,
                      ),
                      _PupCounter(
                        label: 'Unknown',
                        count: pupUnknownCount,
                        color: Colors.grey,
                        onIncrement: () => onPupCountChanged(
                          pupMaleCount,
                          pupFemaleCount,
                          pupUnknownCount + 1,
                        ),
                        onDecrement: pupUnknownCount > 0
                            ? () => onPupCountChanged(
                                  pupMaleCount,
                                  pupFemaleCount,
                                  pupUnknownCount - 1,
                                )
                            : null,
                      ),
                    ],
                  ),

                  // Total pups
                  if (totalPups > 0) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Total pups: $totalPups',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => onPupCountChanged(0, 0, 0),
                          icon: const Icon(Icons.clear, size: 16),
                          label: const Text('Clear'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PupCounter extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final VoidCallback onIncrement;
  final VoidCallback? onDecrement;

  const _PupCounter({
    required this.label,
    required this.count,
    required this.color,
    required this.onIncrement,
    this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement button
          IconButton(
            onPressed: onDecrement,
            icon: const Icon(Icons.remove, size: 18),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
          ),

          // Count display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  label == 'Male'
                      ? Icons.male
                      : label == 'Female'
                          ? Icons.female
                          : Icons.question_mark,
                  size: 16,
                  color: color,
                ),
                Text(
                  '$count',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Increment button
          IconButton(
            onPressed: onIncrement,
            icon: const Icon(Icons.add, size: 18),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
