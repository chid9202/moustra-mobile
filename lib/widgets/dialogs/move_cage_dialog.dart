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
    // Use cage's xPosition/yPosition directly
    final xPos = widget.cage.xPosition ?? 0;
    final yPos = widget.cage.yPosition ?? 0;

    // Convert to 1-indexed for display (row = y + 1, column = x + 1)
    _rowController.text = (yPos + 1).toString();
    _columnController.text = (xPos + 1).toString();
  }

  int _getCurrentRow() {
    // Row is y + 1 (1-indexed)
    return (widget.cage.yPosition ?? 0) + 1;
  }

  int _getCurrentColumn() {
    // Column is x + 1 (1-indexed)
    return (widget.cage.xPosition ?? 0) + 1;
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
      // Convert 1-indexed form values to 0-indexed
      final newXPosition = columnValue - 1;
      final newYPosition = rowValue - 1;
      
      final currentXPosition = widget.cage.xPosition ?? 0;
      final currentYPosition = widget.cage.yPosition ?? 0;

      if (newXPosition == currentXPosition && newYPosition == currentYPosition) {
        _rowError = 'New position must be different from current position';
        isValid = false;
      }
    }

    setState(() {});
    return isValid;
  }

  Future<void> _handleMove() async {
    if (!_validateForm()) {
      return;
    }

    // Convert 1-indexed form values to 0-indexed for API
    final rowValue = int.parse(_rowController.text);
    final columnValue = int.parse(_columnController.text);
    final xPosition = columnValue - 1;
    final yPosition = rowValue - 1;

    setState(() {
      isLoading = true;
    });

    try {
      await moveCage(
        widget.cage.cageUuid,
        x: xPosition,
        y: yPosition,
      );
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
          child: Stack(
            children: [
              Opacity(
                opacity: isLoading ? 0.5 : 1.0,
                child: IgnorePointer(
                  ignoring: isLoading,
                  child: SingleChildScrollView(
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
            if (isLoading)
              const Positioned.fill(
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
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
