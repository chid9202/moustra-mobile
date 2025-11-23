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

  void _showMenu(BuildContext context) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    final Offset offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final Size size = renderBox?.size ?? Size.zero;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx + size.width - 200,
        offset.dy + size.height,
        offset.dx + size.width,
        offset.dy + size.height + 100,
      ),
      items: [
        const PopupMenuItem<String>(
          value: 'open_cage',
          child: Text('Open Cage'),
        ),
        const PopupMenuItem<String>(
          value: 'add_animals',
          child: Text('Add Animals'),
        ),
        const PopupMenuItem<String>(
          value: 'move_cage',
          child: Text('Move Cage'),
        ),
      ],
    ).then((value) {
      if (value != null) {
        // Wait for popup menu route animation to fully complete before navigating
        // This avoids "deactivated widget's ancestor" error during popup closing
        Future.delayed(const Duration(milliseconds: 400), () {
          if (value == 'open_cage') {
            appRouter.go('/cages/$cageUuid?fromCageGrid=true');
          } else if (value == 'add_animals') {
            appRouter.go('/animals/new?cageUuid=$cageUuid&fromCageGrid=true');
          } else if (value == 'move_cage') {
            _showMoveCageDialog(context);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.more_vert),
      onPressed: () => _showMenu(context),
    );
  }
}

