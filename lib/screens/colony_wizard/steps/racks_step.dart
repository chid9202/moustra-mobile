import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:moustra/services/clients/rack_api.dart';
import 'package:moustra/services/dtos/post_rack_dto.dart';
import 'package:moustra/services/dtos/put_rack_dto.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/stores/rack_store.dart';

import '../state/wizard_state.dart';
import '../colony_wizard_constants.dart';

class RacksStep extends StatefulWidget {
  const RacksStep({super.key});

  @override
  State<RacksStep> createState() => _RacksStepState();
}

class _RacksStepState extends State<RacksStep> {
  final _rackNameController = TextEditingController();
  final _customWidthController = TextEditingController(text: '6');
  final _customHeightController = TextEditingController(text: '4');

  String _selectedTemplate = 'small';
  List<RackSimpleDto> _racks = [];
  bool _isLoading = true;
  bool _isAddingRack = false;
  String? _editingRackUuid;

  // Edit mode controllers
  final _editNameController = TextEditingController();
  final _editWidthController = TextEditingController();
  final _editHeightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRacks();
  }

  @override
  void dispose() {
    _rackNameController.dispose();
    _customWidthController.dispose();
    _customHeightController.dispose();
    _editNameController.dispose();
    _editWidthController.dispose();
    _editHeightController.dispose();
    super.dispose();
  }

  Future<void> _loadRacks() async {
    setState(() => _isLoading = true);
    try {
      await useRackStore();
      final rackData = rackStore.value?.rackData;
      if (mounted && rackData?.racks != null) {
        setState(() {
          _racks = rackData!.racks!;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Failed to load racks: $e');
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: ColonyWizardConstants.snackbarDuration,
      ),
    );
  }

  Map<String, int> _getDimensions() {
    if (_selectedTemplate == 'custom') {
      return {
        'width': int.tryParse(_customWidthController.text) ?? 6,
        'height': int.tryParse(_customHeightController.text) ?? 4,
      };
    }
    return ColonyWizardConstants.rackTemplates[_selectedTemplate] ??
        {'width': 6, 'height': 4};
  }

  String _generateRackName() {
    final name = _rackNameController.text.trim();
    if (name.isNotEmpty) return name;
    return 'Rack ${_racks.length + 1}';
  }

  Future<void> _addRack() async {
    final dimensions = _getDimensions();
    final name = _generateRackName();

    setState(() => _isAddingRack = true);

    try {
      final payload = PostRackDto(
        rackName: name,
        rackWidth: dimensions['width']!,
        rackHeight: dimensions['height']!,
      );

      await rackApi.createRack(payload);

      // Reload rack list
      final newRackData = await rackApi.getRack();
      if (mounted) {
        setState(() {
          _racks = newRackData.racks ?? [];
          _isAddingRack = false;
        });

        _rackNameController.clear();
        wizardState.incrementRacksAdded();
        _showSuccess('Rack "$name" created');

        // Push undo action
        final newRackUuid = newRackData.rackUuid;
        if (newRackUuid != null) {
          wizardState.pushUndoAction(
            UndoAction(
              type: UndoActionType.addRack,
              description: 'Added rack "$name"',
              undo: () async {
                // Note: Would need delete rack API endpoint
                await _loadRacks();
                wizardState.decrementRacksAdded();
              },
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAddingRack = false);
        _showError('Failed to create rack: $e');
      }
    }
  }

  void _startEditRack(RackSimpleDto rack) async {
    // Fetch full rack details
    try {
      final fullRack = await rackApi.getRack(rackUuid: rack.rackUuid);
      if (mounted) {
        setState(() {
          _editingRackUuid = rack.rackUuid;
          _editNameController.text = rack.rackName ?? '';
          _editWidthController.text = (fullRack.rackWidth ?? 6).toString();
          _editHeightController.text = (fullRack.rackHeight ?? 4).toString();
        });
      }
    } catch (e) {
      _showError('Failed to load rack details: $e');
    }
  }

  void _cancelEditRack() {
    setState(() {
      _editingRackUuid = null;
      _editNameController.clear();
      _editWidthController.clear();
      _editHeightController.clear();
    });
  }

  Future<void> _saveEditRack() async {
    if (_editingRackUuid == null) return;

    final name = _editNameController.text.trim();
    if (name.isEmpty) {
      _showError('Rack name is required');
      return;
    }

    try {
      final payload = PutRackDto(
        rackName: name,
        rackWidth: int.tryParse(_editWidthController.text) ?? 6,
        rackHeight: int.tryParse(_editHeightController.text) ?? 4,
      );

      await rackApi.updateRack(_editingRackUuid!, payload);

      // Reload rack list
      final newRackData = await rackApi.getRack();
      if (mounted) {
        setState(() {
          _racks = newRackData.racks ?? [];
          _editingRackUuid = null;
        });
        _showSuccess('Rack updated');
      }
    } catch (e) {
      _showError('Failed to update rack: $e');
    }
  }

  Future<void> _deleteRack(RackSimpleDto rack) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Rack'),
        content: Text(
          'Are you sure you want to delete "${rack.rackName}"? This will also delete all cages in this rack.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Optimistic update
    final previousRacks = List<RackSimpleDto>.from(_racks);
    setState(() {
      _racks.removeWhere((r) => r.rackUuid == rack.rackUuid);
    });

    try {
      // Note: Would need rack delete endpoint
      // For now, just reload
      await _loadRacks();
      _showSuccess('Rack "${rack.rackName}" deleted');
    } catch (e) {
      // Rollback
      if (mounted) {
        setState(() => _racks = previousRacks);
        _showError('Failed to delete rack: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 800;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Racks',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add racks to organize your cages',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildAddRackCard(theme)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildCreatedRacksCard(theme)),
                  ],
                )
              else
                Column(
                  children: [
                    _buildAddRackCard(theme),
                    const SizedBox(height: 16),
                    _buildCreatedRacksCard(theme),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddRackCard(ThemeData theme) {
    final dimensions = _getDimensions();
    final totalPositions = dimensions['width']! * dimensions['height']!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ADD A RACK',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),

            // Rack name input
            TextField(
              controller: _rackNameController,
              decoration: const InputDecoration(
                labelText: 'Rack Name (optional)',
                hintText: 'Auto-generated if empty',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),

            // Template selector
            Text(
              'Size',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),

            ...ColonyWizardConstants.rackTemplates.entries.map((entry) {
              final key = entry.key;
              final dims = entry.value;
              final label = _getTemplateLabel(key);
              final total = dims['width']! * dims['height']!;

              return RadioListTile<String>(
                value: key,
                groupValue: _selectedTemplate,
                onChanged: (value) {
                  setState(() => _selectedTemplate = value!);
                },
                title: Text(label),
                subtitle: Text(
                  '${dims['width']} x ${dims['height']} ($total positions)',
                ),
                dense: true,
                contentPadding: EdgeInsets.zero,
              );
            }),

            RadioListTile<String>(
              value: 'custom',
              groupValue: _selectedTemplate,
              onChanged: (value) {
                setState(() => _selectedTemplate = value!);
              },
              title: const Text('Custom Size'),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),

            // Custom size inputs
            if (_selectedTemplate == 'custom') ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customWidthController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Width',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _customHeightController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Height',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '$totalPositions positions',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Add button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isAddingRack ? null : _addRack,
                icon: _isAddingRack
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
                label: const Text('Add Rack'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatedRacksCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CREATED RACKS (${_racks.length})',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_racks.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No racks added yet.\nAdd a rack to get started.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _racks.length,
                  itemBuilder: (context, index) {
                    final rack = _racks[index];
                    final isEditing = _editingRackUuid == rack.rackUuid;

                    if (isEditing) {
                      return _buildEditRackItem(theme, rack);
                    }
                    return _buildRackItem(theme, rack);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRackItem(ThemeData theme, RackSimpleDto rack) {
    return ListTile(
      title: Text(rack.rackName ?? 'Unnamed Rack'),
      subtitle: Text('ID: ${rack.rackId}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _startEditRack(rack),
            tooltip: 'Edit rack',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deleteRack(rack),
            tooltip: 'Delete rack',
          ),
        ],
      ),
    );
  }

  Widget _buildEditRackItem(ThemeData theme, RackSimpleDto rack) {
    return Card(
      color: theme.colorScheme.surfaceContainerLow,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _editNameController,
              decoration: const InputDecoration(
                labelText: 'Rack Name',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _editWidthController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Width',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _editHeightController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Height',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: _cancelEditRack,
                  icon: const Icon(Icons.close),
                  label: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _saveEditRack,
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTemplateLabel(String key) {
    switch (key) {
      case 'small':
        return 'Small';
      case 'medium':
        return 'Medium';
      case 'large':
        return 'Large';
      case 'extraLarge':
        return 'Extra Large';
      default:
        return key;
    }
  }
}
