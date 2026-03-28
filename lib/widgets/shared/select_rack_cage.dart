import 'package:flutter/material.dart';

import 'package:moustra/helpers/snackbar_helper.dart';
import 'package:moustra/services/clients/cage_api.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/stores/cage_store.dart';
import 'package:moustra/stores/rack_store.dart';
import 'package:moustra/widgets/rack_cage_grid.dart';

class SelectRackCage extends StatefulWidget {
  const SelectRackCage({
    super.key,
    required this.selectedCage,
    required this.onSubmit,
    this.label,
    this.disabled = false,
  });
  final RackCageDto? selectedCage;
  final Function(RackCageDto?) onSubmit;
  final String? label;
  final bool disabled;

  @override
  State<SelectRackCage> createState() => _SelectRackCageState();
}

class _SelectRackCageState extends State<SelectRackCage> {
  RackCageDto? _selection;
  bool _isCreatingCage = false;

  RackDto? get _rackData => rackStore.value?.rackData;

  @override
  void initState() {
    super.initState();
    _selection = widget.selectedCage;
  }

  Future<void> _handleCreateCage(String posLabel, int x, int y) async {
    setState(() => _isCreatingCage = true);
    try {
      final rackName = _rackData?.rackName;
      final fullTag = rackName != null ? '$rackName-$posLabel' : posLabel;
      final res = await CageApi().createCageInRack(
        cageTag: fullTag,
        rackUuid: _rackData!.rackUuid!,
        xPosition: x,
        yPosition: y,
      );
      if (mounted) {
        showAppSnackBar(context, 'Cage created', isSuccess: true);
        // Find the newly created cage in the response
        final newCage = res.cages?.firstWhere(
          (c) => c.xPosition == x && c.yPosition == y,
          orElse: () => res.cages!.last,
        );
        await refreshCageStore();
        setState(() {
          _selection = newCage;
          _isCreatingCage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, 'Failed to create cage: $e', isError: true);
        setState(() => _isCreatingCage = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Destination Cage'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isCreatingCage)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Creating cage...'),
                    ],
                  ),
                ),
              if (_rackData != null)
                RackCageGrid(
                  racks: _rackData!.racks ?? [],
                  selectedRack: _rackData,
                  selectedCageUuid: _selection?.cageUuid,
                  sourceCageUuid: widget.selectedCage?.cageUuid,
                  hideRackSelector: true,
                  emptyTooltipPrefix: 'Create cage at',
                  onChangeRack: (_) {},
                  onSelectCage: (cage) {
                    if (cage.cageUuid == widget.selectedCage?.cageUuid) return;
                    setState(() => _selection = cage);
                  },
                  onCreateCage: _handleCreateCage,
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _selection == null ||
                  _selection?.cageUuid == widget.selectedCage?.cageUuid
              ? null
              : () {
                  widget.onSubmit(_selection);
                },
          child: const Text('Move'),
        ),
      ],
    );
  }
}
