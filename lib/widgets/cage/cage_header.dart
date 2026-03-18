import 'package:flutter/material.dart';

import 'package:moustra/widgets/cage/cage_header_menu.dart';
import 'package:moustra/services/dtos/rack_dto.dart';

class CageHeader extends StatelessWidget {
  final RackCageDto cage;
  final bool showMenu;

  const CageHeader({required this.cage, this.showMenu = false, super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

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
