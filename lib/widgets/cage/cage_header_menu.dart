import 'package:flutter/material.dart';

import 'package:moustra/app/router.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/stores/rack_store.dart';
import 'package:moustra/widgets/dialogs/move_cage_dialog.dart';

class CageHeaderMenu extends StatelessWidget {
  final String cageUuid;

  const CageHeaderMenu({required this.cageUuid, super.key});

  RackCageDto? _getCageFromStore() {
    final rackData = rackStore.value?.rackData;
    if (rackData == null) return null;
    return rackData.cages?.firstWhere(
      (cage) => cage.cageUuid == cageUuid,
      orElse: () => RackCageDto(cageUuid: ''),
    );
  }

  void _showMoveCageDialog(BuildContext context) {
    final cage = _getCageFromStore();
    if (cage == null || cage.cageUuid.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cage not found in rack')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => MoveCageDialog(cage: cage),
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'open_cage':
        // Wait for popup menu to fully close before navigating
        Future.delayed(const Duration(milliseconds: 300), () {
          appRouter.go('/cage/$cageUuid?fromCageGrid=true');
        });
        break;
      case 'add_animals':
        // Wait for popup menu to fully close before navigating
        Future.delayed(const Duration(milliseconds: 300), () {
          appRouter.go('/animal/new?cageUuid=$cageUuid&fromCageGrid=true');
        });
        break;
      case 'move_cage':
        _showMoveCageDialog(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          onPressed: () => _handleMenuSelection(context, 'open_cage'),
          child: const Text('Open Cage'),
        ),
        MenuItemButton(
          onPressed: () => _handleMenuSelection(context, 'add_animals'),
          child: const Text('Add Animals'),
        ),
        MenuItemButton(
          onPressed: () => _handleMenuSelection(context, 'move_cage'),
          child: const Text('Move Cage'),
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
}
