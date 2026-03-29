import 'package:flutter/material.dart';

/// A compact chip that displays a linked entity reference in a DataGrid cell.
/// Tapping navigates to the entity's detail page.
class LinkedRecordChip extends StatelessWidget {
  /// Display label for the linked record.
  final String label;

  /// Called when the chip is tapped (typically navigates to detail page).
  final VoidCallback? onTap;

  /// Background color of the chip. Defaults to a subtle grey.
  final Color? backgroundColor;

  const LinkedRecordChip({
    super.key,
    required this.label,
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.grey[100],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey[300]!, width: 0.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: onTap != null
                ? Theme.of(context).colorScheme.primary
                : Colors.black87,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }
}

/// Renders a row of linked record chips that wrap within the cell.
/// Used for multi-value linked fields (e.g., Dam with multiple animals).
class LinkedRecordChipList extends StatelessWidget {
  /// The chips to display.
  final List<LinkedRecordChipData> chips;

  /// Maximum number of chips to show before truncating with "+N".
  final int maxVisible;

  const LinkedRecordChipList({
    super.key,
    required this.chips,
    this.maxVisible = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (chips.isEmpty) return const SizedBox.shrink();

    final visible = chips.take(maxVisible).toList();
    final overflow = chips.length - maxVisible;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Wrap(
        spacing: 4,
        runSpacing: 2,
        children: [
          ...visible.map(
            (chip) => LinkedRecordChip(
              label: chip.label,
              onTap: chip.onTap,
            ),
          ),
          if (overflow > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '+$overflow',
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ),
        ],
      ),
    );
  }
}

/// Data for a single linked record chip.
class LinkedRecordChipData {
  final String label;
  final VoidCallback? onTap;

  const LinkedRecordChipData({required this.label, this.onTap});
}
