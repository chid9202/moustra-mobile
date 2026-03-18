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
import 'package:moustra/stores/profile_store.dart';
import 'package:moustra/services/dtos/account_dto.dart';
import 'package:intl/intl.dart';
import 'package:moustra/services/dtos/litter_dto.dart';
import 'package:moustra/helpers/snackbar_helper.dart';

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

  bool get _isDisbanded => _matingData?.disbandedDate != null;

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
        showAppSnackBar(context, 'Error loading mating: $e', isError: true);
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

  Future<void> _showDisbandDialog() async {
    DateTime disbandDate = DateTime.now();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Disband Mating'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Are you sure you want to disband this mating?'),
              const SizedBox(height: 16),
              SelectDate(
                selectedDate: disbandDate,
                onChanged: (date) {
                  if (date != null) {
                    setDialogState(() => disbandDate = date);
                  }
                },
                labelText: 'Disband Date',
                hintText: 'Select disband date',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Disband'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final matingData = _matingData!;
      final matingUuid = _matingUuid!;
      final profile = profileState.value;

      // Build disbandedBy from current user's profile
      AccountStoreDto? disbandedByAccount;
      if (profile != null) {
        disbandedByAccount = AccountStoreDto(
          accountId: 0,
          accountUuid: profile.accountUuid,
          user: UserDto(
            email: profile.email,
            firstName: profile.firstName,
            lastName: profile.lastName,
          ),
        );
      }

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
          disbandedDate: disbandDate,
          disbandedBy: disbandedByAccount,
        ),
      );
      if (!mounted) return;
      showAppSnackBar(context, 'Mating disbanded successfully!', isSuccess: true);
      if (widget.fromCageGrid) {
        context.go('/cage/grid');
      } else {
        context.go('/mating');
      }
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, 'Error disbanding mating: $e', isError: true);
    }
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
          showAppSnackBar(context, 'Mating created successfully!', isSuccess: true);
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
          showAppSnackBar(context, 'Mating updated successfully!', isSuccess: true);
        }
        // Navigate back to the appropriate page based on where we came from
        if (widget.fromCageGrid) {
          context.go('/cage/grid');
        } else {
          context.go('/mating');
        }
      } catch (e) {
        debugPrint('Error saving mating: $e');
        showAppSnackBar(context, 'Error saving mating: $e', isError: true);
      }
    }
  }

  Color _edayColor(double? currentEday, double? targetEday) {
    if (currentEday == null || targetEday == null) return Colors.grey;
    if (currentEday > targetEday) return Colors.red;
    if (currentEday >= targetEday - 1) return Colors.orange;
    return Colors.green;
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParentsSection() {
    final animals = _matingData?.animals ?? [];
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Parents', animals.length),
            const SizedBox(height: 8),
            if (animals.isEmpty)
              const Text('No parents assigned', style: TextStyle(color: Colors.grey))
            else
              ...animals.map((animal) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: animal.sex == SexConstants.male
                          ? Colors.blue.withValues(alpha: 0.1)
                          : Colors.pink.withValues(alpha: 0.1),
                      child: Text(
                        animal.sex == SexConstants.male ? 'M' : 'F',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: animal.sex == SexConstants.male
                              ? Colors.blue
                              : Colors.pink,
                        ),
                      ),
                    ),
                    title: Text(
                      animal.physicalTag ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      '${animal.sex == SexConstants.male ? "Sire" : "Dam"}'
                      '${animal.dateOfBirth != null ? ' • DOB: ${DateFormat('yyyy-MM-dd').format(animal.dateOfBirth!)}' : ''}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 18),
                    onTap: () => context.go('/animal/${animal.animalUuid}'),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildLittersSection() {
    final litters = _matingData?.litters ?? [];
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Litters', litters.length),
            const SizedBox(height: 8),
            if (litters.isEmpty)
              const Text('No litters recorded', style: TextStyle(color: Colors.grey))
            else
              ...litters.map((litter) {
                final males = litter.animals.where((a) => a.sex == SexConstants.male).length;
                final females = litter.animals.where((a) => a.sex == SexConstants.female).length;
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    radius: 16,
                    child: Icon(Icons.pets, size: 16),
                  ),
                  title: Text(
                    litter.litterTag ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    '${litter.dateOfBirth != null ? 'DOB: ${DateFormat('yyyy-MM-dd').format(litter.dateOfBirth!)}' : ''}'
                    '${litter.animals.isNotEmpty ? ' • ${males}M / ${females}F' : ''}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () => context.go('/litter/${litter.litterUuid}'),
                );
              }),
            if (!_isDisbanded) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/litter/new?matingUuid=${_matingUuid}'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Litter'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlugEventsSection() {
    final plugEvents = _matingData?.plugEvents ?? [];
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Plug Events', plugEvents.length),
            const SizedBox(height: 8),
            if (plugEvents.isEmpty)
              const Text('No plug events recorded', style: TextStyle(color: Colors.grey))
            else
              ...plugEvents.map((pe) {
                final edayColor = _edayColor(pe.currentEday, pe.targetEday);
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    pe.female?.physicalTag ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        pe.plugDate.length >= 10 ? pe.plugDate.substring(0, 10) : pe.plugDate,
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (pe.currentEday != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: edayColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'E${pe.currentEday!.toStringAsFixed(1)}',
                            style: TextStyle(
                              color: edayColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      if (pe.outcome != null && pe.outcome!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            pe.outcome!.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' '),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () => context.go('/plug-event/${pe.plugEventUuid}'),
                );
              }),
            if (!_isDisbanded) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/plug-event/new?mating=${_matingUuid}'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Record Plug'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
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
    final isEditing = !isNew;
    final isDisbanded = _isDisbanded;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else if (widget.fromCageGrid) {
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
              // Disbanded banner
              if (isDisbanded) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This mating was disbanded on ${DateFormat('yyyy-MM-dd').format(_matingData!.disbandedDate!)}'
                          '${_matingData!.disbandedBy?.user != null ? ' by ${_matingData!.disbandedBy!.user!.firstName} ${_matingData!.disbandedBy!.user!.lastName}' : ''}',
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              Semantics(
                label: 'Mating Tag',
                textField: true,
                child: TextFormField(
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

              // Related data sections (only for existing matings)
              if (isEditing) ...[
                const SizedBox(height: 24),
                // Parents Section
                _buildParentsSection(),
                const SizedBox(height: 16),
                // Litters Section
                _buildLittersSection(),
                const SizedBox(height: 16),
                // Plug Events Section
                _buildPlugEventsSection(),
                const SizedBox(height: 16),
              ],

              // Disband button (only for existing, non-disbanded matings)
              if (isEditing && !isDisbanded) ...[
                Semantics(
                  label: 'Disband Mating',
                  button: true,
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      onPressed: _showDisbandDialog,
                      child: const Text('Disband Mating'),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              Semantics(
                label: 'Save Mating',
                button: true,
                child: SizedBox(
                  width: double.infinity,
                  child: MoustraButtonPrimary(
                    label: 'Save Mating',
                    onPressed: isDisbanded ? null : _saveMating,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
