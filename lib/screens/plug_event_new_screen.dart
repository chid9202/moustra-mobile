import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:moustra/services/clients/plug_api.dart';
import 'package:moustra/services/dtos/mating_dto.dart';
import 'package:moustra/services/dtos/post_plug_event_dto.dart';
import 'package:moustra/services/dtos/stores/animal_store_dto.dart';
import 'package:moustra/widgets/shared/select_animal.dart';
import 'package:moustra/widgets/shared/select_date.dart';
import 'package:moustra/widgets/shared/select_mating.dart';
import 'package:moustra/helpers/snackbar_helper.dart';
import 'package:moustra/services/clients/event_api.dart';

class PlugEventNewScreen extends StatefulWidget {
  final String? matingUuid;
  final String? femaleUuid;

  const PlugEventNewScreen({super.key, this.matingUuid, this.femaleUuid});

  @override
  State<PlugEventNewScreen> createState() => _PlugEventNewScreenState();
}

class _PlugEventNewScreenState extends State<PlugEventNewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _targetEdayController = TextEditingController();
  final _commentController = TextEditingController();

  MatingDto? _selectedMating;
  AnimalStoreDto? _selectedFemale;
  AnimalStoreDto? _selectedMale;
  DateTime? _selectedPlugDate = DateTime.now();
  bool _isSaving = false;

  List<AnimalStoreDto> _filterFemales(List<AnimalStoreDto> animals) {
    var filtered = animals.where((a) => a.sex == 'F').toList();
    if (_selectedMating != null && _selectedMating!.animals != null) {
      final matingAnimalUuids =
          _selectedMating!.animals!.map((a) => a.animalUuid).toSet();
      filtered =
          filtered.where((a) => matingAnimalUuids.contains(a.animalUuid)).toList();
    }
    return filtered;
  }

  List<AnimalStoreDto> _filterMales(List<AnimalStoreDto> animals) {
    return animals.where((a) => a.sex == 'M').toList();
  }

  void _onMatingChanged(MatingDto? mating) {
    setState(() {
      _selectedMating = mating;
      if (mating != null && mating.animals != null) {
        // Auto-set male from mating
        final males = mating.animals!.where((a) => a.sex == 'M');
        if (males.length == 1) {
          final maleAnimal = males.first;
          _selectedMale = AnimalStoreDto(
            eid: 0,
            animalId: maleAnimal.animalId,
            animalUuid: maleAnimal.animalUuid,
            physicalTag: maleAnimal.physicalTag,
            sex: maleAnimal.sex,
          );
        }
        // Auto-select female if only one in mating
        final females = mating.animals!.where((a) => a.sex == 'F');
        if (females.length == 1) {
          final femaleAnimal = females.first;
          _selectedFemale = AnimalStoreDto(
            eid: 0,
            animalId: femaleAnimal.animalId,
            animalUuid: femaleAnimal.animalUuid,
            physicalTag: femaleAnimal.physicalTag,
            sex: femaleAnimal.sex,
          );
        }
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFemale == null) {
      showAppSnackBar(context, 'Please select a female');
      return;
    }
    if (_selectedPlugDate == null) {
      showAppSnackBar(context, 'Please select a plug date');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final dto = PostPlugEventDto(
        female: _selectedFemale!.animalUuid,
        male: _selectedMale?.animalUuid,
        mating: _selectedMating?.matingUuid,
        plugDate: DateFormat('yyyy-MM-dd').format(_selectedPlugDate!),
        targetEday: _targetEdayController.text.isNotEmpty
            ? int.tryParse(_targetEdayController.text)
            : null,
        comment:
            _commentController.text.isNotEmpty ? _commentController.text : null,
      );

      await plugService.createPlugEvent(dto);
      eventApi.trackEvent('create_plug_event');

      if (mounted) {
        showAppSnackBar(context, 'Plug event created successfully', isSuccess: true);
        context.go('/plug-event');
      }
    } catch (e, stack) {
      debugPrint('Error creating plug event: $e');
      debugPrint('$stack');
      if (mounted) {
        showAppSnackBar(context, 'Error creating plug event: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _targetEdayController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/plug-event');
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Record Plug Event'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectMating(
                selectedMating: _selectedMating,
                onChanged: _onMatingChanged,
                label: 'Mating (optional)',
                placeholderText: 'Select a mating',
              ),
              const SizedBox(height: 16),
              SelectAnimal(
                selectedAnimal: _selectedFemale,
                onChanged: (animal) {
                  setState(() => _selectedFemale = animal);
                },
                label: 'Female *',
                placeholderText: 'Select female',
                filter: _filterFemales,
              ),
              const SizedBox(height: 16),
              SelectAnimal(
                selectedAnimal: _selectedMale,
                onChanged: (animal) {
                  setState(() => _selectedMale = animal);
                },
                label: 'Male',
                placeholderText: 'Select male (optional)',
                filter: _filterMales,
              ),
              const SizedBox(height: 16),
              SelectDate(
                selectedDate: _selectedPlugDate,
                onChanged: (date) {
                  setState(() => _selectedPlugDate = date);
                },
                labelText: 'Plug Date *',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _targetEdayController,
                decoration: const InputDecoration(
                  labelText: 'Target E-Day',
                  hintText: 'e.g. 18',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              // HIDDEN: Comment field hidden - use Note instead
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Plug Event'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
