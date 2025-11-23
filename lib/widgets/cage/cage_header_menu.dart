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
    PopupMenuItem<String>(
      value: 'open_cage',
      child: const Text('Open Cage'),
      onTap: () {
        // Use Future.microtask to avoid closing the popup menu immediately
        Future.microtask(() {
          appRouter.go('/cages/$cageUuid?fromCageGrid=true');
        });
      },
    ),
    PopupMenuItem<String>(
      value: 'add_animals',
      child: const Text('Add Animals'),
      onTap: () {
        Future.microtask(() {
          appRouter.go('/animals/new?cageUuid=$cageUuid&fromCageGrid=true');
        });
      },
    ),
    PopupMenuItem<String>(
      value: 'move_cage',
      child: const Text('Move Cage'),
      onTap: () {
        Future.microtask(() => _showMoveCageDialog(context));
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (context) => _buildMenuItems(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).dividerColor, width: 1),
      ),
    );
  }
}
