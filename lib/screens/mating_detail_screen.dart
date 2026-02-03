import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/constants/animal_constants.dart';
import 'package:moustra/helpers/account_helper.dart';
import 'package:moustra/services/clients/mating_api.dart';
import 'package:moustra/services/dtos/mating_dto.dart';
import 'package:moustra/services/dtos/post_mating_dto.dart';
import 'package:moustra/services/dtos/put_mating_dto.dart';
import 'package:moustra/services/dtos/stores/account_store_dto.dart';
import 'package:moustra/services/dtos/stores/animal_store_dto.dart';
import 'package:moustra/services/dtos/stores/cage_store_dto.dart';
import 'package:moustra/services/dtos/stores/strain_store_dto.dart';
import 'package:moustra/stores/animal_store.dart';
import 'package:moustra/stores/cage_store.dart';
import 'package:moustra/stores/strain_store.dart';
import 'package:moustra/helpers/animal_helper.dart';
import 'package:moustra/widgets/shared/multi_select_animal.dart';
import 'package:moustra/widgets/shared/select_animal.dart';
import 'package:moustra/widgets/shared/select_cage.dart';
import 'package:moustra/widgets/shared/select_date.dart';
import 'package:moustra/widgets/shared/select_owner.dart';
import 'package:moustra/widgets/shared/select_strain.dart';
import 'package:moustra/widgets/shared/button.dart';
import 'package:moustra/widgets/note/note_list.dart';
import 'package:moustra/services/dtos/note_entity_type.dart';

class MatingDetailScreen extends StatefulWidget {
  final bool fromCageGrid;

  const MatingDetailScreen({super.key, this.fromCageGrid = false});

  @override
  State<MatingDetailScreen> createState() => _MatingDetailScreenState();
}

class _MatingDetailScreenState extends State<MatingDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _matingTagController = TextEditingController();
  final _commentController = TextEditingController();

  AnimalStoreDto? _selectedMale;
  List<AnimalStoreDto> _selectedFemales = [];
  CageStoreDto? _selectedCage;
  StrainStoreDto? _selectedStrain;
  DateTime? _selectedSetUpDate = DateTime.now();
  AccountStoreDto? _selectedOwner;
  MatingDto? _matingData;
  bool _matingDataLoaded = false;

  String? get _matingUuid {
    final state = GoRouterState.of(context);
    return state.pathParameters['matingUuid'];
  }

  @override
  void initState() {
    super.initState();
    _loadDefaultOwner();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_matingDataLoaded) {
      _loadMatingData();
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

  void _loadMatingData() async {
    final matingUuid = _matingUuid;
    if (matingUuid == null || matingUuid == 'new') {
      _matingDataLoaded = true;
      return;
    }
    try {
      final mating = await MatingApi().getMating(matingUuid);
      if (mounted) {
        setState(() {
          _matingTagController.text = mating.matingTag ?? '';
          _commentController.text = mating.comment ?? '';
          // Extract male and females from animals list
          final animals = mating.animals;
          final maleAnimal = animals
              ?.where((a) => a.sex == SexConstants.male)
              .firstOrNull;
          final femaleAnimals = animals
              ?.where((a) => a.sex == SexConstants.female)
              .toList();

          _selectedMale = maleAnimal != null
              ? AnimalStoreDto(
                  animalId: maleAnimal.animalId,
                  animalUuid: maleAnimal.animalUuid,
                  physicalTag: maleAnimal.physicalTag,
                  sex: maleAnimal.sex,
                  dateOfBirth: maleAnimal.dateOfBirth,
                  eid:
                      0, // Default value since not available in AnimalSummaryDto
                )
              : null;
          _selectedFemales =
              femaleAnimals
                  ?.map(
                    (f) => AnimalStoreDto(
                      animalId: f.animalId,
                      animalUuid: f.animalUuid,
                      physicalTag: f.physicalTag,
                      sex: f.sex,
                      dateOfBirth: f.dateOfBirth,
                      eid:
                          0, // Default value since not available in AnimalSummaryDto
                    ),
                  )
                  .toList() ??
              [];
          _selectedCage = mating.cage != null
              ? CageStoreDto(
                  cageId: mating.cage!.cageId,
                  cageUuid: mating.cage!.cageUuid,
                  cageTag: mating.cage!.cageTag,
                )
              : null;
          _selectedStrain = mating.litterStrain != null
              ? StrainStoreDto(
                  strainId: mating.litterStrain!.strainId,
                  strainUuid: mating.litterStrain!.strainUuid,
                  strainName: mating.litterStrain!.strainName,
                  weanAge: mating.litterStrain!.weanAge,
                  genotypes: const [],
                )
              : null;
          _selectedSetUpDate = mating.setUpDate ?? DateTime.now();
          _selectedOwner = mating.owner?.toAccountStoreDto();
          _matingData = mating;
          _matingDataLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading mating: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading mating: $e')));
      }
      _matingDataLoaded = true;
    }
  }

  @override
  void dispose() {
    _matingTagController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _saveMating() async {
    if (_formKey.currentState!.validate()) {
      try {
        final matingUuid = _matingUuid;
        if (matingUuid == null || matingUuid == 'new') {
          final mating = PostMatingDto(
            matingTag: _matingTagController.text,
            maleAnimal: _selectedMale!.animalUuid,
            femaleAnimals: _selectedFemales.map((f) => f.animalUuid).toList(),
            cage: _selectedCage,
            litterStrain: _selectedStrain,
            setUpDate: _selectedSetUpDate!,
            owner: _selectedOwner ?? await AccountHelper.getDefaultOwner(),
            comment: _commentController.text,
          );
          await MatingApi().createMating(mating);
          // Refresh related stores
          await refreshAnimalStore();
          await refreshCageStore();
          await refreshStrainStore();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mating created successfully!')),
          );
        } else {
          final matingData = _matingData!;
          await MatingApi().putMating(
            matingUuid,
            PutMatingDto(
              matingId: matingData.matingId,
              matingUuid: matingUuid,
              matingTag: _matingTagController.text,
              litterStrain: _selectedStrain,
              setUpDate: _selectedSetUpDate!,
              owner: _selectedOwner ?? await AccountHelper.getDefaultOwner(),
              comment: _commentController.text,
            ),
          );
          // Refresh related stores
          await refreshAnimalStore();
          await refreshCageStore();
          await refreshStrainStore();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mating updated successfully!')),
          );
        }
        // Navigate back to the appropriate page based on where we came from
        if (widget.fromCageGrid) {
          context.go('/cage/grid');
        } else {
          context.go('/mating');
        }
      } catch (e) {
        debugPrint('Error saving mating: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving mating: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedOwner == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_matingUuid != null && !_matingDataLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    final isNew = _matingUuid == null || _matingUuid == 'new';
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            // Navigate back to the appropriate page based on where we came from
            if (widget.fromCageGrid) {
              context.go('/cage/grid');
            } else {
              context.go('/mating');
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(isNew ? 'Create Mating' : 'Edit Mating'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _matingTagController,
                decoration: const InputDecoration(
                  labelText: 'Mating Tag',
                  hintText: 'Enter mating tag',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a mating tag';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SelectAnimal(
                selectedAnimal: _selectedMale,
                onChanged: (male) {
                  setState(() {
                    _selectedMale = male;
                  });
                },
                label: 'Male Animal',
                placeholderText: 'Select male animal',
                filter: (animals) {
                  return animals
                      .where((a) => a.sex == SexConstants.male)
                      .where((a) => AnimalHelper.isMature(a))
                      .toList();
                },
                disabled: !isNew,
              ),
              const SizedBox(height: 16),
              MultiSelectAnimal(
                selectedAnimals: _selectedFemales,
                onChanged: (females) {
                  setState(() {
                    _selectedFemales = females;
                  });
                },
                label: 'Female Animals',
                placeholderText: 'Select female animals',
                filter: (animals) {
                  return animals
                      .where((a) => a.sex == SexConstants.female)
                      .where((a) => AnimalHelper.isMature(a))
                      .toList();
                },
                disabled: !isNew,
              ),
              const SizedBox(height: 16),
              SelectCage(
                selectedCage: _selectedCage,
                onChanged: (cage) {
                  setState(() {
                    _selectedCage = cage;
                  });
                },
                label: 'Target Cage',
                disabled: !isNew,
              ),
              const SizedBox(height: 16),
              SelectStrain(
                selectedStrain: _selectedStrain,
                onChanged: (strain) {
                  setState(() {
                    _selectedStrain = strain;
                  });
                },
                label: 'Primary Strain',
              ),
              const SizedBox(height: 16),
              SelectDate(
                selectedDate: _selectedSetUpDate,
                onChanged: (date) {
                  setState(() {
                    _selectedSetUpDate = date;
                  });
                },
                labelText: 'Set Up Date',
                hintText: 'Select set up date',
                validator: (date) {
                  if (date == null) {
                    return 'Please select a set up date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SelectOwner(
                selectedOwner: _selectedOwner,
                onChanged: (owner) {
                  setState(() {
                    _selectedOwner = owner;
                  });
                },
              ),
              const SizedBox(height: 16),
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

              // Notes Section
              if (_matingUuid != null && _matingUuid != 'new')
                NoteList(
                  entityUuid: _matingUuid,
                  entityType: NoteEntityType.mating,
                  initialNotes: _matingData?.notes,
                ),

              SizedBox(
                width: double.infinity,
                child: MoustraButtonPrimary(
                  label: 'Save Mating',
                  onPressed: _saveMating,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
