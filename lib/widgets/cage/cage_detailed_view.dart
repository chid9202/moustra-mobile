import 'package:flutter/material.dart';

import 'package:moustra/widgets/cage/animal_card.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/constants/cages_grid_constants.dart';

class CageDetailedView extends StatelessWidget {
  final RackCageDto cage;
  final double zoomLevel;
  final String? searchQuery;
  final String searchType;

  const CageDetailedView({
    required this.cage,
    required this.zoomLevel,
    this.searchQuery,
    this.searchType = CagesGridConstants.searchTypeAnimalTag,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final animals = cage.animals ?? [];

    if (animals.isEmpty) {
      return Center(
        child: Text(
          'No animals',
          style: TextStyle(color: Colors.grey.shade400, fontSize: 48),
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: CagesGridConstants.maxCageHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animals list
          Flexible(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: animals.length,
              separatorBuilder: (context, index) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final animal = animals[index];
                return AnimalCard(
                  animal: animal,
                  hasMating: _hasMating(animal),
                  cage: cage,
                  zoomLevel: zoomLevel,
                  searchQuery: searchQuery,
                  searchType: searchType,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _hasMating(RackCageAnimalDto animal) {
    return cage.mating?.animals?.any(
          (matingAnimal) => matingAnimal.animalUuid == animal.animalUuid,
        ) ??
        false;
  }
}
