import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/services/clients/animal_api.dart';
import 'package:moustra/services/dtos/stores/account_store_dto.dart';
import 'package:moustra/services/dtos/animal_dto.dart';
import 'package:moustra/services/dtos/stores/animal_store_dto.dart';
import 'package:moustra/services/dtos/stores/cage_store_dto.dart';
import 'package:moustra/services/dtos/stores/strain_store_dto.dart';
import 'package:moustra/services/dtos/strain_dto.dart';
import 'package:moustra/helpers/account_helper.dart';
import 'package:moustra/stores/account_store.dart';
import 'package:moustra/stores/animal_store.dart';
import 'package:moustra/stores/cage_store.dart';
import 'package:moustra/stores/strain_store.dart';
import 'package:moustra/widgets/shared/multi_select_animal.dart';
import 'package:moustra/widgets/shared/select_animal.dart';
import 'package:moustra/widgets/shared/select_cage.dart';
import 'package:moustra/widgets/shared/select_date.dart';
import 'package:moustra/widgets/shared/select_owner.dart';
import 'package:intl/intl.dart';
import 'package:moustra/widgets/shared/select_sex.dart';
import 'package:moustra/widgets/shared/select_strain.dart';

class AnimalDetailScreen extends StatefulWidget {
  const AnimalDetailScreen({super.key});

  @override
  State<AnimalDetailScreen> createState() => _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends State<AnimalDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _physicalTagController = TextEditingController();
  final _commentController = TextEditingController();

  String? _selectedSex;
  StrainStoreDto? _selectedStrain;
  DateTime? _selectedDateOfBirth;
  DateTime? _selectedWeanDate;
  AccountStoreDto? _selectedOwner;
  CageStoreDto? _selectedCage;
  AnimalStoreDto? _selectedSire;
  List<AnimalStoreDto> _selectedDam = [];
  AnimalDto? _animalData;
  bool _animalDataLoaded = false;

  // Get the animal UUID from the route parameters
  String? get _animalUuid {
    final state = GoRouterState.of(context);
    return state.pathParameters['animalUuid'];
  }

  @override
  void initState() {
    super.initState();
    _loadDefaultOwner();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_animalDataLoaded) {
      _loadAnimalData();
    }
  }

  void _loadDefaultOwner() async {
    final owner = await AccountHelper.getDefaultOwner();
    if (mounted) {
      setState(() {
        _selectedOwner = owner;
      });
    }
  }

  void _loadAnimalData() async {
    final animalUuid = _animalUuid;
    if (animalUuid == null || animalUuid == 'new') {
      _animalDataLoaded = true;
      return;
    }
    try {
      // Load existing animal data for editing
      final animal = await AnimalApi().getAnimal(animalUuid);
      if (mounted) {
        setState(() async {
          _physicalTagController.text = animal.physicalTag ?? '';
          _commentController.text = animal.comment ?? '';
          _selectedSex = animal.sex;
          _selectedStrain = await getStrainHook(animal.strain?.strainUuid);
          _selectedDateOfBirth = animal.dateOfBirth;
          _selectedWeanDate = animal.weanDate;
          _selectedOwner = await getAccountHook(
            animal.owner?.accountUuid ?? '',
          );
          _selectedCage = await getCageHook(animal.cage?.cageUuid);
          _selectedSire = await getAnimalHook(animal.sire?.animalUuid ?? '');
          _selectedDam = await getAnimalsHookByUuids(
            animal.dam?.map((dam) => dam.animalUuid).toList() ?? [],
          );
          _animalData = animal;
          _animalDataLoaded = true;
        });
      }
    } catch (e) {
      print('Error loading animal: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading animal: $e')));
      }
      _animalDataLoaded = true;
    }
  }

  @override
  void dispose() {
    _physicalTagController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _saveAnimal() async {
    if (_formKey.currentState!.validate()) {
      try {
        final animalUuid = _animalUuid;
        // Update existing animal
        // await AnimalApi().updateAnimal(
        //   animalUuid,
        //   PutAnimalDto(
        //     animalId: _animalData!.animalId,
        //     animalUuid: animalUuid,
        //     physicalTag: _physicalTagController.text,
        //     sex: _selectedSex!,
        //     strain: _selectedStrain!,
        //     dateOfBirth: _selectedDateOfBirth!,
        //     weanDate: _selectedWeanDate,
        //     cageTag: _selectedCage!,
        //     owner: _selectedOwner ?? await AccountHelper.getDefaultOwner(),
        //     sire: _selectedSire,
        //     dam: _selectedDam,
        //     comment: _commentController.text,
        //   ),
        // );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Animal updated successfully!')),
        );
        context.go('/animals');
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving animal: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedOwner == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _animalUuid == null || _animalUuid == 'new'
              ? 'Create Animal'
              : 'Edit Animal',
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Physical Tag Field
              TextFormField(
                controller: _physicalTagController,
                decoration: const InputDecoration(
                  labelText: 'Physical Tag',
                  hintText: 'Enter physical tag',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a physical tag';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Sex Selection
              SelectSex(
                selectedSex: _selectedSex,
                onChanged: (sex) {
                  setState(() {
                    _selectedSex = sex;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Strain Selection
              SelectStrain(
                selectedStrain: _selectedStrain,
                onChanged: (strain) {
                  setState(() {
                    _selectedStrain = strain;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Date of Birth
              SelectDate(
                selectedDate: _selectedDateOfBirth,
                onChanged: (date) {
                  setState(() {
                    _selectedDateOfBirth = date;
                  });
                },
                labelText: 'Date of Birth',
              ),

              const SizedBox(height: 16),

              // Wean Date
              SelectDate(
                selectedDate: _selectedWeanDate,
                onChanged: (date) {
                  setState(() {
                    _selectedWeanDate = date;
                  });
                },
                labelText: 'Wean Date',
              ),

              const SizedBox(height: 16),

              // Owner Select Field
              SelectOwner(
                selectedOwner: _selectedOwner,
                onChanged: (owner) {
                  setState(() {
                    _selectedOwner = owner;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Cage Selection
              SelectCage(
                selectedCage: _selectedCage,
                onChanged: (cage) {
                  setState(() {
                    _selectedCage = cage;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Sire Selection
              SelectAnimal(
                selectedAnimal: _selectedSire,
                onChanged: (animal) {
                  setState(() {
                    _selectedSire = animal;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Dam Selection
              MultiSelectAnimal(
                selectedAnimals: _selectedDam,
                onChanged: (items) {
                  setState(() {
                    _selectedDam = items;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Comment Field
              TextFormField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: 'Comment',
                  hintText: 'Enter any additional comments',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveAnimal,
                  child: const Text('Save Animal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
