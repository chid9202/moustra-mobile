import 'package:flutter/material.dart';

import 'package:moustra/services/clients/rack_api.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/stores/rack_store.dart';

import '../colony_wizard_constants.dart';
import '../state/wizard_state.dart';
import '../widgets/rack_selector.dart';
import '../widgets/wizard_rack_grid.dart';
import 'cage_animal_dialog_screen.dart';

class CagesAnimalsStep extends StatefulWidget {
  const CagesAnimalsStep({super.key});

  @override
  State<CagesAnimalsStep> createState() => _CagesAnimalsStepState();
}

class _CagesAnimalsStepState extends State<CagesAnimalsStep> {
  List<RackSimpleDto> _racks = [];
  RackSimpleDto? _selectedRack;
  RackDto? _currentRackData;
  bool _isLoadingRacks = true;
  bool _isLoadingGrid = false;

  @override
  void initState() {
    super.initState();
    _loadRacks();
  }

  Future<void> _loadRacks() async {
    setState(() => _isLoadingRacks = true);
    try {
      await useRackStore();
      final rackData = rackStore.value?.rackData;
      if (mounted && rackData != null) {
        setState(() {
          _racks = rackData.racks ?? [];
          _isLoadingRacks = false;

          // Auto-select first rack if available
          if (_racks.isNotEmpty && _selectedRack == null) {
            _selectedRack = _racks.first;
            _loadRackGrid(_selectedRack!.rackUuid);
          }
        });
      } else {
        setState(() => _isLoadingRacks = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingRacks = false);
        _showError('Failed to load racks: $e');
      }
    }
  }

  Future<void> _loadRackGrid(String rackUuid) async {
    setState(() => _isLoadingGrid = true);
    try {
      final rackData = await rackApi.getRack(rackUuid: rackUuid);
      if (mounted) {
        setState(() {
          _currentRackData = rackData;
          _isLoadingGrid = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingGrid = false);
        _showError('Failed to load rack data: $e');
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

  void _onRackSelected(RackSimpleDto rack) {
    setState(() => _selectedRack = rack);
    _loadRackGrid(rack.rackUuid);
  }

  void _onCellTapped(int x, int y, RackCageDto? existingCage) {
    // Navigate to cage/animal dialog screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CageAnimalDialogScreen(
          rackUuid: _selectedRack!.rackUuid,
          rackName: _selectedRack!.rackName ?? 'Rack',
          xPosition: x,
          yPosition: y,
          existingCage: existingCage,
          onSaved: () {
            // Refresh the rack grid after save
            _loadRackGrid(_selectedRack!.rackUuid);
          },
        ),
      ),
    );
  }

  int _getCageCount(RackSimpleDto rack) {
    if (_currentRackData != null &&
        _currentRackData!.rackUuid == rack.rackUuid) {
      return _currentRackData!.cages?.length ?? 0;
    }
    return 0;
  }

  int _getTotalPositions(RackDto rackData) {
    return (rackData.rackWidth ?? 0) * (rackData.rackHeight ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cages & Animals',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Click on rack positions to add cages and animals',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        // Rack selector
        if (_isLoadingRacks)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_racks.isEmpty)
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.grid_off,
                      size: 64,
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No racks created yet',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Go back to the Racks step to add one.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        wizardState.goToStep(ColonyWizardConstants.stepRacks);
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Go to Racks'),
                    ),
                  ],
                ),
              ),
            ),
          )
        else ...[
          // Rack selector row
          RackSelector(
            racks: _racks,
            selectedRack: _selectedRack,
            rackData: _currentRackData,
            onRackSelected: _onRackSelected,
          ),

          const SizedBox(height: 8),

          // Rack grid
          Expanded(
            child: _selectedRack == null
                ? Center(
                    child: Text(
                      'Select a rack above',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : _isLoadingGrid
                    ? const Center(child: CircularProgressIndicator())
                    : _currentRackData == null
                        ? Center(
                            child: Text(
                              'Failed to load rack data',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(16),
                            child: WizardRackGrid(
                              rackData: _currentRackData!,
                              onCellTapped: _onCellTapped,
                            ),
                          ),
          ),
        ],
      ],
    );
  }
}
