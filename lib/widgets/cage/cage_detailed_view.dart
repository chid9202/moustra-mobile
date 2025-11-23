import 'package:flutter/material.dart';

import 'package:moustra/widgets/cage/animal_card.dart';
import 'package:moustra/widgets/cage/cage_header_menu.dart';
import 'package:moustra/services/dtos/rack_dto.dart';

class CageDetailedView extends StatelessWidget {
  final RackCageDto cage;
  final double zoomLevel;

  const CageDetailedView({
    required this.cage,
    required this.zoomLevel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final animals = cage.animals ?? [];
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: cage.cageTag ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (cage.strain?.strainName != null) ...[
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: cage.strain!.strainName!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            CageHeaderMenu(cageUuid: cage.cageUuid),
          ],
        ),
        if (animals.isNotEmpty)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: animals
                    .map(
                      (animal) => AnimalCard(
                        animal: animal,
                        hasMating: _hasMating(animal),
                        cage: cage,
                        zoomLevel: zoomLevel,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
      ],
    );
  }

  bool _hasMating(RackCageAnimalDto animal) {
    return cage.mating?.animals?.any(
          (matingAnimal) => matingAnimal.animalUuid == animal.animalUuid,
        ) ??
        false;
  }
}

