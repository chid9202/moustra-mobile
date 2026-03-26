import 'package:flutter/material.dart';

import 'package:moustra/widgets/cage/cage_header_menu.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
class CageHeader extends StatelessWidget {
  final RackCageDto cage;
  final bool showMenu;

  const CageHeader({required this.cage, this.showMenu = false, super.key});

  String? get _positionLabel {
    final x = cage.xPosition;
    final y = cage.yPosition;
    if (x == null || y == null) return null;
    // Convert row index to letter(s): 0→A, 25→Z, 26→AA, etc.
    var row = y;
    var letters = '';
    do {
      letters = String.fromCharCode(65 + (row % 26)) + letters;
      row = row ~/ 26 - 1;
    } while (row >= 0);
    return '$letters${x + 1}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final posLabel = _positionLabel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerHighest : Colors.blueGrey.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      child: Row(
        children: [
          // Position label (top-left, like web)
          if (posLabel != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.blueGrey.shade800
                    : Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                posLabel,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.blueGrey.shade800,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: cage.cageTag ?? 'Unnamed',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.blueGrey.shade200 : Colors.blueGrey,
                    ),
                  ),
                  if (cage.strain?.strainName != null) ...[
                    const TextSpan(text: '  '),
                    TextSpan(
                      text: cage.strain!.strainName!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.blueGrey.shade300 : Colors.blueGrey.shade400,
                      ),
                    ),
                  ],
                ],
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (showMenu) CageHeaderMenu(cageUuid: cage.cageUuid),
        ],
      ),
    );
  }
}
