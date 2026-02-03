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

  List<PopupMenuItem<String>> _buildMenuItems(BuildContext context) => [
    const PopupMenuItem<String>(value: 'open_cage', child: Text('Open Cage')),
    const PopupMenuItem<String>(
      value: 'add_animals',
      child: Text('Add Animals'),
    ),
    const PopupMenuItem<String>(value: 'move_cage', child: Text('Move Cage')),
  ];

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
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (context) => _buildMenuItems(context),
      onSelected: (value) => _handleMenuSelection(context, value),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).dividerColor, width: 1),
      ),
    );
  }
}
