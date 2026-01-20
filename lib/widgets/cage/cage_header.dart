import 'package:flutter/material.dart';

import 'package:moustra/widgets/cage/cage_header_menu.dart';
import 'package:moustra/services/dtos/rack_dto.dart';

class CageHeader extends StatelessWidget {
  final RackCageDto cage;
  final bool showMenu;

  const CageHeader({required this.cage, this.showMenu = false, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 8.0,
      ),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
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
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  if (cage.strain?.strainName != null) ...[
                    const TextSpan(text: '  '),
                    TextSpan(
                      text: cage.strain!.strainName!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.blueGrey.shade400,
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
