import 'package:flutter/material.dart';

import 'package:moustra/app/router.dart';
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
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          onPressed: () => _handleMenuSelection(context, 'move'),
          child: const Text('Move'),
        ),
        MenuItemButton(
          onPressed: () => _handleMenuSelection(context, 'open'),
          child: const Text('Open'),
        ),
        MenuItemButton(
          onPressed: () => _handleMenuSelection(context, 'end'),
          child: const Text('End'),
        ),
      ],
      builder: (BuildContext context, MenuController controller, Widget? child) {
        return IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        );
      },
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'move':
        _handleMove(context);
        break;
      case 'open':
        // Wait for popup menu to fully close before navigating
        // Use a delay to ensure the popup menu route is fully disposed
        Future.delayed(const Duration(milliseconds: 300), () {
          appRouter.go('/animal/${animal.animalUuid}?fromCageGrid=true');
        });
        break;
      case 'end':
        _handleEnd();
        break;
    }
  }

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
