import 'package:flutter/material.dart';

import 'package:moustra/helpers/rack_utils.dart';
import 'package:moustra/helpers/snackbar_helper.dart';
import 'package:moustra/services/clients/cage_api.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/stores/rack_store.dart';
import 'package:moustra/widgets/rack_cage_grid.dart';

class MoveCageDialog extends StatefulWidget {
  final RackCageDto cage;

  const MoveCageDialog({super.key, required this.cage});

  @override
  State<MoveCageDialog> createState() => _MoveCageDialogState();
}

class _MoveCageDialogState extends State<MoveCageDialog> {
  bool _isLoading = false;
  RackGridPosition? _targetPosition;
  String? _swapCageUuid;

  RackDto? get _rackData => rackStore.value?.rackData;
  String? get _rackName => _rackData?.rackName;

  bool get _isSwap => _swapCageUuid != null;

  void _handleSelectCage(RackCageDto cage) {
    if (cage.cageUuid == widget.cage.cageUuid) return;
    if (cage.xPosition == null || cage.yPosition == null) return;
    setState(() {
      _targetPosition = RackGridPosition(x: cage.xPosition!, y: cage.yPosition!);
      _swapCageUuid = cage.cageUuid;
    });
  }

  void _handleSelectEmpty(String posLabel, int x, int y) {
    setState(() {
      _targetPosition = RackGridPosition(x: x, y: y);
      _swapCageUuid = null;
    });
  }

  Future<void> _handleConfirm() async {
    if (_targetPosition == null) return;

    setState(() => _isLoading = true);

    try {
      if (_isSwap) {
        await CageApi().swapCage(widget.cage.cageUuid, _swapCageUuid!);
      } else {
        await moveCage(
          widget.cage.cageUuid,
          x: _targetPosition!.x,
          y: _targetPosition!.y,
        );
      }
      if (mounted) {
        Navigator.of(context).pop(true);
        showAppSnackBar(
          context,
          _isSwap ? 'Cages swapped successfully' : 'Cage moved successfully',
          isSuccess: true,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        showAppSnackBar(
          context,
          _isSwap ? 'Failed to swap cages' : 'Failed to move cage: $e',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isSwap ? 'Swap Cage' : 'Move Cage'),
      content: SizedBox(
        width: double.maxFinite,
        child: Stack(
          children: [
            Opacity(
              opacity: _isLoading ? 0.5 : 1.0,
              child: IgnorePointer(
                ignoring: _isLoading,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Moving ${widget.cage.cageTag ?? "Untitled"} from ${_rackName ?? "Unknown Rack"}. '
                        'Select a position or cage to swap with.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      RackCageGrid(
                        racks: _rackData?.racks ?? [],
                        selectedRack: _rackData,
                        selectedCageUuid: _swapCageUuid ?? widget.cage.cageUuid,
                        selectedPosition: _swapCageUuid == null ? _targetPosition : null,
                        sourceCageUuid: widget.cage.cageUuid,
                        hideRackSelector: true,
                        emptyTooltipPrefix: 'Move to',
                        onChangeRack: (_) {},
                        onSelectCage: _handleSelectCage,
                        onCreateCage: _handleSelectEmpty,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isLoading)
              const Positioned.fill(
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isLoading || _targetPosition == null ? null : _handleConfirm,
          child: Text(_isSwap ? 'Swap' : 'Move'),
        ),
      ],
    );
  }
}
