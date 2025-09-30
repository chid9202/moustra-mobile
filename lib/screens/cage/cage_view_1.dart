import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:moustra/screens/cage/animal_card.dart';
import 'package:moustra/services/clients/cage_api.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/stores/rack_store.dart';

class CageView1 extends StatelessWidget {
  final RackCageDto cage;

  const CageView1({required this.cage, super.key});

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
                        cage: cage,
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
      PopupMenuItem(
        value: 'open_cage',
        child: const Text('Open Cage'),
        onTap: () => context.go('/cages/${cage.cageUuid}?fromCageGrid=true'),
      ),
      PopupMenuItem(
        value: 'add_animals',
        child: Text('Add Animals'),
        onTap: () => context.go(
          '/animals/new?cageUuid=${cage.cageUuid}&fromCageGrid=true',
        ),
      ),
      PopupMenuItem(
        value: 'end_cage',
        child: const Text('End Cage'),
        onTap: () {
          removeCageFromRack(cage.cageUuid);
          cageApi.endCage(cage.cageUuid);
        },
      ),
    ];

    if (hasMating) {
      menuItems.addAll([
        PopupMenuItem(
          value: 'open_mating',
          child: Text('Open Mating'),
          onTap: () => context.go(
            '/matings/${cage.mating?.matingUuid}?fromCageGrid=true',
          ),
        ),
        PopupMenuItem(
          value: 'add_litter',
          child: Text('Add Litter'),
          onTap: () => context.go(
            '/litters/new?matingUuid=${cage.mating?.matingUuid}&fromCageGrid=true',
          ),
        ),
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
