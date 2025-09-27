import 'package:flutter/material.dart';
import 'package:moustra/screens/cage/animal_card.dart';
import 'package:moustra/services/dtos/rack_dto.dart';

class CageView1 extends StatelessWidget {
  final RackCageDto cage;

  const CageView1({super.key, required this.cage});

  @override
  Widget build(BuildContext context) {
    final animals = cage.animals ?? [];
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${cage.cageTag} ${cage.strain?.strainName != null ? '(${cage.strain?.strainName})' : ''}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                _showCageMenu(context);
              },
            ),
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

  void _showCageMenu(BuildContext context) {
    final hasMating = cage.mating != null;

    final menuItems = <PopupMenuItem>[
      const PopupMenuItem(value: 'open_cage', child: Text('Open Cage')),
      const PopupMenuItem(value: 'add_animals', child: Text('Add Animals')),
      const PopupMenuItem(value: 'end_cage', child: Text('End Cage')),
    ];

    if (hasMating) {
      menuItems.addAll([
        const PopupMenuItem(value: 'open_mating', child: Text('Open Mating')),
        const PopupMenuItem(value: 'add_litter', child: Text('Add Litter')),
      ]);
    }

    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 0, 0),
      items: menuItems,
    ).then((value) {
      if (value != null) {
        // Handle menu selection
        print('Selected: $value for cage ${cage.cageTag}');
      }
    });
  }
}
