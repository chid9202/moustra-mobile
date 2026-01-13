import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/helpers/account_helper.dart';
import 'package:moustra/services/clients/litter_api.dart';
import 'package:moustra/services/clients/mating_api.dart';
import 'package:moustra/services/dtos/mating_dto.dart';
import 'package:moustra/services/dtos/litter_dto.dart';
import 'package:moustra/services/dtos/post_litter_dto.dart';
import 'package:moustra/services/dtos/put_litter_dto.dart';
import 'package:moustra/services/dtos/stores/account_store_dto.dart';
import 'package:moustra/stores/animal_store.dart';
import 'package:moustra/stores/strain_store.dart';
import 'package:moustra/widgets/shared/button.dart';
import 'package:moustra/widgets/shared/select_date.dart';
import 'package:moustra/widgets/shared/select_mating.dart';
import 'package:moustra/widgets/shared/select_owner.dart';
import 'package:moustra/widgets/note/note_list.dart';
import 'package:moustra/services/dtos/note_entity_type.dart';

class LitterDetailScreen extends StatefulWidget {
  final String? matingUuid;
  final bool fromCageGrid;

  const LitterDetailScreen({
    super.key,
    this.matingUuid,
    this.fromCageGrid = false,
  });

  @override
  State<LitterDetailScreen> createState() => _LitterDetailScreenState();
}

class _LitterDetailScreenState extends State<LitterDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _litterTagController = TextEditingController();
  final _numberOfMalesController = TextEditingController(text: '0');
  final _numberOfFemalesController = TextEditingController(text: '0');
  final _numberOfUnknownController = TextEditingController(text: '0');
  final _commentController = TextEditingController();

  MatingDto? _selectedMating;
  DateTime? _selectedDateOfBirth = DateTime.now();
  DateTime? _selectedWeanDate = DateTime.now().add(const Duration(days: 21));
  AccountStoreDto? _selectedOwner;
  LitterDto? _litterData;
  bool _litterDataLoaded = false;

  String? get _litterUuid {
    final state = GoRouterState.of(context);
    return state.pathParameters['litterUuid'];
  }

  @override
  void initState() {
    super.initState();
    _loadDefaultOwner();
    _loadMatingIfProvided();
  }

  void _loadMatingIfProvided() async {
    if (widget.matingUuid != null) {
      try {
        final mating = await MatingApi().getMating(widget.matingUuid!);
        if (mounted) {
          setState(() {
            _selectedMating = mating;
          });
        }
      } catch (e) {
        print('Error loading mating: $e');
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_litterDataLoaded && _litterUuid != null) {
      _loadLitterData();
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

  void _loadLitterData() async {
    final litter = await litterService.getLitter(_litterUuid!);
    if (mounted) {
      setState(() {
        _litterData = litter;
        _litterDataLoaded = true;
        _selectedMating = MatingDto(
          matingId: litter.mating?.matingId ?? 0,
          matingUuid: litter.mating?.matingUuid ?? '',
          matingTag: litter.mating?.matingTag ?? '',
          litterStrain: litter.mating?.litterStrain,
        );
        _litterTagController.text = litter.litterTag ?? '';
        _selectedDateOfBirth = litter.dateOfBirth;
        _selectedWeanDate = litter.weanDate;
        _selectedOwner = litter.owner?.toAccountStoreDto();
      });
    }
  }

  @override
  void dispose() {
    _litterTagController.dispose();
    _numberOfMalesController.dispose();
    _numberOfFemalesController.dispose();
    _numberOfUnknownController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _saveLitter() async {
    if (_formKey.currentState!.validate()) {
      try {
        final litter = PostLitterDto(
          mating: _selectedMating!.matingUuid,
          numberOfMale: int.parse(_numberOfMalesController.text),
          numberOfFemale: int.parse(_numberOfFemalesController.text),
          numberOfUnknown: int.parse(_numberOfUnknownController.text),
          litterTag: _litterTagController.text,
          dateOfBirth: _selectedDateOfBirth!,
          weanDate: _selectedWeanDate,
          owner: _selectedOwner ?? await AccountHelper.getDefaultOwner(),
          comment: _commentController.text.isEmpty
              ? null
              : _commentController.text,
        );

        if (_litterUuid == null || _litterUuid == 'new') {
          await litterService.createLitter(litter);
        } else {
          await litterService.putLitter(
            _litterUuid!,
            PutLitterDto(
              comment: _commentController.text.isEmpty
                  ? null
                  : _commentController.text,
              dateOfBirth: _selectedDateOfBirth,
              weanDate: _selectedWeanDate,
              owner: _selectedOwner,
              litterTag: _litterTagController.text,
            ),
          );
        }
        // Refresh related stores
        await refreshAnimalStore();
        await refreshStrainStore();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Litter created successfully!')),
        );

        // Navigate back to the appropriate page based on where we came from
        if (widget.fromCageGrid) {
          context.go('/cages/grid');
        } else {
          context.go('/litters');
        }
      } catch (e) {
        print('Error saving litter: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving litter: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedOwner == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_litterUuid != null && !_litterDataLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    final isNew = _litterUuid == null || _litterUuid == 'new';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            // Navigate back to the appropriate page based on where we came from
            if (widget.fromCageGrid) {
              context.go('/cages/grid');
            } else {
              context.go('/litters');
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(isNew ? 'Create Litter' : 'Update Litter'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectMating(
                selectedMating: _selectedMating,
                onChanged: (mating) {
                  setState(() {
                    _selectedMating = mating;
                  });
                },
                label: 'Mating',
                placeholderText: 'Select mating',
                disabled: _litterDataLoaded,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _litterTagController,
                decoration: const InputDecoration(
                  labelText: 'Litter Tag',
                  hintText: 'Enter litter tag',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a litter tag';
                  }
                  return null;
                },
              ),
              if (isNew) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _numberOfMalesController,
                        decoration: const InputDecoration(
                          labelText: '# Males',
                          hintText: '0',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _numberOfFemalesController,
                        decoration: const InputDecoration(
                          labelText: '# Females',
                          hintText: '0',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _numberOfUnknownController,
                        decoration: const InputDecoration(
                          labelText: '# Unknown',
                          hintText: '0',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              SelectDate(
                selectedDate: _selectedDateOfBirth,
                onChanged: (date) {
                  setState(() {
                    _selectedDateOfBirth = date;
                  });
                },
                labelText: 'Date of Birth',
                hintText: 'Select date of birth',
                validator: (date) {
                  if (date == null) {
                    return 'Please select date of birth';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SelectDate(
                selectedDate: _selectedWeanDate,
                onChanged: (date) {
                  setState(() {
                    _selectedWeanDate = date;
                  });
                },
                labelText: 'Wean Date (Optional)',
                hintText: 'Select wean date',
                validator: (date) {
                  // Optional field, no validation needed
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
                  labelText: 'Comment (Optional)',
                  hintText: 'Enter any additional comments',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Notes Section
              if (_litterUuid != null && _litterUuid != 'new')
                NoteList(
                  entityUuid: _litterUuid,
                  entityType: NoteEntityType.litter,
                  initialNotes: _litterData?.notes,
                ),

              SizedBox(
                width: double.infinity,
                child: MoustraButtonPrimary(
                  onPressed: _selectedMating == null ? null : _saveLitter,
                  label: isNew ? 'Create Litter' : 'Update Litter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
