import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:moustra/services/clients/animal_api.dart';
import 'package:moustra/services/clients/event_api.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/services/dtos/end_animals_dto.dart';
import 'package:moustra/widgets/shared/select_date.dart';
import 'package:moustra/helpers/snackbar_helper.dart';

class EndAnimalScreen extends StatefulWidget {
  const EndAnimalScreen({super.key});

  @override
  State<EndAnimalScreen> createState() => _EndAnimalScreenState();
}

class _EndAnimalScreenState extends State<EndAnimalScreen> {
  final _commentController = TextEditingController();

  DateTime? _endDate = DateTime.now();
  String? _selectedEndTypeUuid;
  String? _selectedEndReasonUuid;
  bool _endCage = false;
  bool _isSaving = false;

  List<AnimalDto> _animals = [];
  List<EndTypeSummaryDto> _endTypes = [];
  List<EndReasonSummaryDto> _endReasons = [];
  bool _isLoading = true;
  String? _error;

  List<String> get _animalUuids {
    final state = GoRouterState.of(context);
    final animalsParam = state.uri.queryParameters['animals'] ?? '';
    return animalsParam.split(',').where((s) => s.isNotEmpty).toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _loadEndAnimalsData();
    }
  }

  Future<void> _loadEndAnimalsData() async {
    try {
      final data = await animalService.getEndAnimalsData(_animalUuids);
      if (!mounted) return;
      setState(() {
        _animals = data.animals;
        _endTypes = data.endTypes;
        _endReasons = data.endReasons;
        _isLoading = false;

        // Pre-fill form if all animals have the same end data
        if (data.animals.isNotEmpty) {
          final first = data.animals.first;
          final allSameEndType = data.animals.every(
            (a) => a.endType?.endTypeUuid == first.endType?.endTypeUuid,
          );
          final allSameEndReason = data.animals.every(
            (a) => a.endReason?.endReasonUuid == first.endReason?.endReasonUuid,
          );
          final allSameEndDate = data.animals.every(
            (a) => a.endDate == first.endDate,
          );
          final allSameComment = data.animals.every(
            (a) => a.endComment == first.endComment,
          );

          if (allSameEndDate && first.endDate != null) {
            _endDate = first.endDate;
          }
          if (allSameEndType && first.endType != null) {
            _selectedEndTypeUuid = first.endType!.endTypeUuid;
          }
          if (allSameEndReason && first.endReason != null) {
            _selectedEndReasonUuid = first.endReason!.endReasonUuid;
          }
          if (allSameComment && first.endComment != null) {
            _commentController.text = first.endComment!;
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _createNewEndType() async {
    final name = await _showCreateDialog('End Type');
    if (name == null || name.isEmpty) return;
    try {
      final newEndType = await animalService.createEndType(name);
      if (!mounted) return;
      setState(() {
        _endTypes.add(newEndType);
        _selectedEndTypeUuid = newEndType.endTypeUuid;
      });
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, 'Failed to create end type: $e', isError: true);
    }
  }

  Future<void> _createNewEndReason() async {
    final name = await _showCreateDialog('End Reason');
    if (name == null || name.isEmpty) return;
    try {
      final newEndReason = await animalService.createEndReason(name);
      if (!mounted) return;
      setState(() {
        _endReasons.add(newEndReason);
        _selectedEndReasonUuid = newEndReason.endReasonUuid;
      });
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, 'Failed to create end reason: $e', isError: true);
    }
  }

  Future<String?> _showCreateDialog(String label) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Create New $label'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: '$label Name',
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitEndAnimals() async {
    if (_endDate == null) {
      showAppSnackBar(context, 'Please select an end date');
      return;
    }
    setState(() => _isSaving = true);
    try {
      final form = EndAnimalFormDto(
        endDate: DateFormat('yyyy-MM-dd').format(_endDate!),
        endType: _selectedEndTypeUuid,
        endReason: _selectedEndReasonUuid,
        endComment: _commentController.text.isNotEmpty
            ? _commentController.text
            : null,
        endCage: _endCage,
      );
      await animalService.endAnimals(_animalUuids, form);
      eventApi.trackEvent('end_animal');
      if (!mounted) return;
      showAppSnackBar(context, 'Animals ended successfully!', isSuccess: true);
      context.go('/animal');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      showAppSnackBar(context, 'Failed to end animals: $e', isError: true);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.go('/animal'),
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text('End Animals'),
        ),
        body: Center(child: Text('Error: $_error')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/animal');
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('End Animals'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animals being ended
            Text(
              'Ending ${_animals.length} animal(s)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _animals.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final animal = _animals[index];
                  return ListTile(
                    title: Text(animal.physicalTag ?? 'Animal ${animal.animalId}'),
                    subtitle: Text(
                      '${animal.sex ?? 'Unknown'} | ${animal.strain?.strainName ?? 'No strain'}',
                    ),
                    dense: true,
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // End Date
            SelectDate(
              selectedDate: _endDate,
              onChanged: (date) {
                setState(() => _endDate = date);
              },
              labelText: 'End Date',
              hintText: 'Select end date',
            ),
            const SizedBox(height: 16),

            // End Type dropdown with create new option
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedEndTypeUuid,
                    decoration: const InputDecoration(
                      labelText: 'End Type',
                      border: OutlineInputBorder(),
                    ),
                    items: _endTypes
                        .map(
                          (et) => DropdownMenuItem(
                            value: et.endTypeUuid,
                            child: Text(et.endTypeName),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedEndTypeUuid = value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _createNewEndType,
                  icon: const Icon(Icons.add),
                  tooltip: 'Create new end type',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // End Reason dropdown with create new option
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedEndReasonUuid,
                    decoration: const InputDecoration(
                      labelText: 'End Reason',
                      border: OutlineInputBorder(),
                    ),
                    items: _endReasons
                        .map(
                          (er) => DropdownMenuItem(
                            value: er.endReasonUuid,
                            child: Text(er.endReasonName),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedEndReasonUuid = value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _createNewEndReason,
                  icon: const Icon(Icons.add),
                  tooltip: 'Create new end reason',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // HIDDEN: Comment field hidden - use Note instead

            // End Cage checkbox
            SwitchListTile(
              title: const Text('End Cage'),
              subtitle: const Text(
                'Also end the cage(s) containing these animals',
              ),
              value: _endCage,
              onChanged: (value) {
                setState(() => _endCage = value);
              },
            ),
            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submitEndAnimals,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('End Animals'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
