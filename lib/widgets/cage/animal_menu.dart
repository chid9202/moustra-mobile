import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:moustra/services/clients/animal_api.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/stores/rack_store.dart';
import 'package:moustra/widgets/shared/select_rack_cage.dart';

class AnimalMenu extends StatelessWidget {
  final RackCageDto cage;
  final RackCageAnimalDto animal;
  final Function(bool) onMovingStateChanged;

  const AnimalMenu({
    super.key,
    required this.cage,
    required this.animal,
    required this.onMovingStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (context) => _buildMenuItems(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).dividerColor, width: 1),
      ),
    );
  }

  List<PopupMenuItem> _buildMenuItems(BuildContext context) => [
    PopupMenuItem(
      value: 'move',
      child: const Text('Move'),
      onTap: () {
        // Use Future.microtask to avoid closing the popup menu immediately
        Future.microtask(() => _handleMove(context));
      },
    ),
    PopupMenuItem(
      value: 'open',
      child: const Text('Open'),
      onTap: () {
        Future.microtask(
          () => context.go('/animals/${animal.animalUuid}?fromCageGrid=true'),
        );
      },
    ),
    PopupMenuItem(
      value: 'end',
      child: const Text('End'),
      onTap: () {
        Future.microtask(() => _handleEnd());
      },
    ),
  ];

  Future<void> _handleMove(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return SelectRackCage(
          selectedCage: cage,
          onSubmit: (submittedCage) async {
            debugPrint('submitted cage: ${submittedCage?.cageId}');
            if (submittedCage == null || submittedCage.cageId == cage.cageId) {
              return;
            }
            onMovingStateChanged(true);
            try {
              await moveAnimal(animal.animalUuid, submittedCage.cageUuid);
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            } catch (e) {
              if (context.mounted) {
                await showDialog(
                  context: context,
                  builder: (errorContext) {
                    return AlertDialog(
                      title: const Text('Error while moving animal'),
                      content: SingleChildScrollView(child: Text('$e')),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(errorContext).pop();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              }
            } finally {
              onMovingStateChanged(false);
            }
          },
        );
      },
    );
  }

  void _handleEnd() {
    removeAnimalFromCage(cage.cageUuid, animal.animalUuid);
    animalService.endAnimals([animal.animalUuid]);
  }
}
