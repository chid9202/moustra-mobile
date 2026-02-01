import 'package:flutter/material.dart';

import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/stores/rack_store.dart';

class MoveCageDialog extends StatefulWidget {
  final RackCageDto cage;

  const MoveCageDialog({super.key, required this.cage});

  @override
  State<MoveCageDialog> createState() => _MoveCageDialogState();
}

class _MoveCageDialogState extends State<MoveCageDialog> {
  final _formKey = GlobalKey<FormState>();
  final _rowController = TextEditingController();
  final _columnController = TextEditingController();
  bool isLoading = false;
  String? _rowError;
  String? _columnError;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    _rowController.dispose();
    _columnController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    // Use xPosition/yPosition if available (sparse grid), otherwise calculate from order
    if (widget.cage.xPosition != null && widget.cage.yPosition != null) {
      // Convert 0-indexed to 1-indexed for display
      _rowController.text = (widget.cage.yPosition! + 1).toString();
      _columnController.text = (widget.cage.xPosition! + 1).toString();
      return;
    }

    // Fallback: Calculate from sorted order
    final rackData = rackStore.value?.rackData;
    if (rackData == null) return;

    final rackWidth = rackData.rackWidth ?? 5;
    final rackHeight = rackData.rackHeight ?? 1;

    List<RackCageDto> displayedCages = [];
    if (rackData.cages != null) {
      displayedCages = List<RackCageDto>.from(rackData.cages!);
      displayedCages.sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
      if (displayedCages.length > rackHeight * rackWidth) {
        displayedCages.removeRange(
          rackHeight * rackWidth,
          displayedCages.length,
        );
      }
    }

    final currentPositionIndex = displayedCages.indexWhere(
      (cage) => cage.cageUuid == widget.cage.cageUuid,
    );

    if (currentPositionIndex >= 0) {
      final currentRow0Indexed = currentPositionIndex ~/ rackWidth;
      final currentColumn0Indexed = currentPositionIndex % rackWidth;

      // Convert to 1-indexed for display and form
      _rowController.text = (currentRow0Indexed + 1).toString();
      _columnController.text = (currentColumn0Indexed + 1).toString();
    } else {
      _rowController.text = '1';
      _columnController.text = '1';
    }
  }

  int _getCurrentRow() {
    // Use yPosition if available (sparse grid)
    if (widget.cage.yPosition != null) {
      return widget.cage.yPosition! + 1;  // Convert to 1-indexed
    }

    // Fallback: Calculate from sorted order
    final rackData = rackStore.value?.rackData;
    if (rackData == null) return 1;

    final rackWidth = rackData.rackWidth ?? 5;
    final rackHeight = rackData.rackHeight ?? 1;

    List<RackCageDto> displayedCages = [];
    if (rackData.cages != null) {
      displayedCages = List<RackCageDto>.from(rackData.cages!);
      displayedCages.sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
      if (displayedCages.length > rackHeight * rackWidth) {
        displayedCages.removeRange(
          rackHeight * rackWidth,
          displayedCages.length,
        );
      }
    }

    final currentPositionIndex = displayedCages.indexWhere(
      (cage) => cage.cageUuid == widget.cage.cageUuid,
    );

    if (currentPositionIndex >= 0) {
      final currentRow0Indexed = currentPositionIndex ~/ rackWidth;
      return currentRow0Indexed + 1;
    }
    return 1;
  }

  int _getCurrentColumn() {
    // Use xPosition if available (sparse grid)
    if (widget.cage.xPosition != null) {
      return widget.cage.xPosition! + 1;  // Convert to 1-indexed
    }

    // Fallback: Calculate from sorted order
    final rackData = rackStore.value?.rackData;
    if (rackData == null) return 1;

    final rackWidth = rackData.rackWidth ?? 5;

    List<RackCageDto> displayedCages = [];
    if (rackData.cages != null) {
      displayedCages = List<RackCageDto>.from(rackData.cages!);
      displayedCages.sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
    }

    final currentPositionIndex = displayedCages.indexWhere(
      (cage) => cage.cageUuid == widget.cage.cageUuid,
    );

    if (currentPositionIndex >= 0) {
      return (currentPositionIndex % rackWidth) + 1;
    }
    return 1;
  }

  bool _validateForm() {
    _rowError = null;
    _columnError = null;

    final rackData = rackStore.value?.rackData;
    if (rackData == null) {
      _rowError = 'Rack dimensions are not available';
      setState(() {});
      return false;
    }

    final rackWidth = rackData.rackWidth ?? 5;
    final rackHeight = rackData.rackHeight ?? 1;

    if (rackWidth == 0 || rackHeight == 0) {
      _rowError = 'Rack dimensions are not available';
      setState(() {});
      return false;
    }

    // Parse row and column values
    final rowValue = int.tryParse(_rowController.text);
    final columnValue = int.tryParse(_columnController.text);

    bool isValid = true;

    // Validate 1-indexed input (1 to rackHeight/rackWidth)
    if (rowValue == null || rowValue < 1 || rowValue > rackHeight) {
      _rowError = 'Row must be between 1 and $rackHeight';
      isValid = false;
    }

    if (columnValue == null || columnValue < 1 || columnValue > rackWidth) {
      _columnError = 'Column must be between 1 and $rackWidth';
      isValid = false;
    }

    // Check if the new position is the same as current position
    if (isValid && rowValue != null && columnValue != null) {
      // Convert 1-indexed form values to 0-indexed for comparison
      final newX = columnValue - 1;
      final newY = rowValue - 1;

      // Compare against current position (using x/y if available)
      final currentX = widget.cage.xPosition;
      final currentY = widget.cage.yPosition;

      if (currentX != null && currentY != null) {
        // Direct x/y comparison for sparse grid
        if (newX == currentX && newY == currentY) {
          _rowError = 'New position must be different from current position';
          isValid = false;
        }
      } else {
        // Fallback: Compare using order-based index
        final newPositionIndex = newY * rackWidth + newX;

        List<RackCageDto> displayedCages = [];
        if (rackData.cages != null) {
          displayedCages = List<RackCageDto>.from(rackData.cages!);
          displayedCages.sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
          if (displayedCages.length > rackHeight * rackWidth) {
            displayedCages.removeRange(
              rackHeight * rackWidth,
              displayedCages.length,
            );
          }
        }

        final currentPositionIndex = displayedCages.indexWhere(
          (cage) => cage.cageUuid == widget.cage.cageUuid,
        );

        if (newPositionIndex == currentPositionIndex) {
          _rowError = 'New position must be different from current position';
          isValid = false;
        }
      }
    }

    setState(() {});
    return isValid;
  }

  Future<void> _handleMove() async {
    if (!_validateForm()) {
      return;
    }

    final rackData = rackStore.value?.rackData;
    if (rackData == null) return;

    // Convert 1-indexed form values to 0-indexed for API (x = column, y = row)
    final rowValue = int.parse(_rowController.text);
    final columnValue = int.parse(_columnController.text);
    final x = columnValue - 1;  // x = column (0-indexed)
    final y = rowValue - 1;      // y = row (0-indexed)

    setState(() {
      isLoading = true;
    });

    try {
      // Use position-based API for sparse grid positioning
      await moveCageByPosition(widget.cage.cageUuid, x, y);
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cage moved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to move cage: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rackData = rackStore.value?.rackData;
    final rackWidth = rackData?.rackWidth ?? 5;
    final rackHeight = rackData?.rackHeight ?? 1;
    final currentRow = _getCurrentRow();
    final currentColumn = _getCurrentColumn();

    return AlertDialog(
      title: const Text('Move Cage'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: double.maxFinite,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cage: ${widget.cage.cageTag ?? 'Untitled'}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Current Position: Row $currentRow, Column $currentColumn',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rack Size: $rackWidth columns × $rackHeight rows',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _rowController,
                              decoration: InputDecoration(
                                labelText: 'Row',
                                hintText: '1',
                                border: const OutlineInputBorder(),
                                errorText: _rowError,
                              ),
                              keyboardType: TextInputType.number,
                              enabled: !isLoading,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _columnController,
                              decoration: InputDecoration(
                                labelText: 'Column',
                                hintText: '1',
                                border: const OutlineInputBorder(),
                                errorText: _columnError,
                              ),
                              keyboardType: TextInputType.number,
                              enabled: !isLoading,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: isLoading ? null : _handleMove,
          child: const Text('Move'),
        ),
      ],
    );
  }
}
