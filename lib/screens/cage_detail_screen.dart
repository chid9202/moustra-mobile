import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/helpers/account_helper.dart';
import 'package:moustra/services/clients/cage_api.dart';
import 'package:moustra/services/dtos/cage_dto.dart';
import 'package:moustra/services/dtos/post_cage_dto.dart';
import 'package:moustra/services/dtos/put_cage_dto.dart';
import 'package:moustra/services/dtos/stores/account_store_dto.dart';
import 'package:moustra/services/dtos/stores/strain_store_dto.dart';
import 'package:moustra/widgets/shared/button.dart';
import 'package:moustra/widgets/shared/select_date.dart';
import 'package:moustra/widgets/shared/select_owner.dart';
import 'package:moustra/widgets/shared/select_strain.dart';

class CageDetailScreen extends StatefulWidget {
  final bool fromCageGrid;

  const CageDetailScreen({super.key, this.fromCageGrid = false});

  @override
  State<CageDetailScreen> createState() => _CageDetailScreenState();
}

class _CageDetailScreenState extends State<CageDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cageTagController = TextEditingController();
  final _commentController = TextEditingController();

  StrainStoreDto? _selectedStrain;
  DateTime? _selectedSetUpDate;
  AccountStoreDto? _selectedOwner;
  CageDto? _cageData;
  bool _cageDataLoaded = false;

  String? get _cageUuid {
    final state = GoRouterState.of(context);
    return state.pathParameters['cageUuid'];
  }

  @override
  void initState() {
    super.initState();
    _loadDefaultOwner();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_cageDataLoaded) {
      _loadCageData();
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

  void _loadCageData() async {
    final cageUuid = _cageUuid;
    if (cageUuid == null || cageUuid == 'new') {
      _cageDataLoaded = true;
      return;
    }
    try {
      final cage = await CageApi().getCage(cageUuid);
      if (mounted) {
        setState(() {
          _cageTagController.text = cage.cageTag;
          _commentController.text = cage.comment ?? '';
          _selectedStrain = cage.strain != null
              ? StrainStoreDto(
                  strainId: cage.strain!.strainId,
                  strainUuid: cage.strain!.strainUuid,
                  strainName: cage.strain!.strainName,
                  weanAge: cage.strain!.weanAge,
                  genotypes: const [],
                )
              : null;
          _selectedSetUpDate =
              cage.createdDate; // Using createdDate as setUpDate
          _selectedOwner = cage.owner.toAccountStoreDto();
          _cageData = cage;
          _cageDataLoaded = true;
        });
      }
    } catch (e) {
      print('Error loading cage: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading cage: $e')));
      }
      _cageDataLoaded = true;
    }
  }

  @override
  void dispose() {
    _cageTagController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _saveCage() async {
    if (_formKey.currentState!.validate()) {
      try {
        final cageUuid = _cageUuid;
        if (cageUuid == null || cageUuid == 'new') {
          final cage = PostCageDto(
            cageTag: _cageTagController.text,
            owner: _selectedOwner ?? await AccountHelper.getDefaultOwner(),
            strain: _selectedStrain!.toStrainSummaryDto(),
            setUpDate: _selectedSetUpDate!,
            comment: _commentController.text,
          );
          await CageApi().createCage(cage);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cage created successfully!')),
          );
        } else {
          final cageData = _cageData!;
          await CageApi().putCage(
            cageUuid,
            PutCageDto(
              cageId: cageData.cageId,
              cageUuid: cageUuid,
              cageTag: _cageTagController.text,
              owner: _selectedOwner ?? await AccountHelper.getDefaultOwner(),
              strain: _selectedStrain!.toStrainSummaryDto(),
              setUpDate: _selectedSetUpDate!,
              comment: _commentController.text,
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cage updated successfully!')),
          );
        }
        // Navigate back to the appropriate page based on where we came from
        if (widget.fromCageGrid) {
          context.go('/cages/grid');
        } else {
          context.go('/cages/list');
        }
      } catch (e) {
        print('Error saving cage: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving cage: $e')));
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
        leading: IconButton(
          onPressed: () {
            // Navigate back to the appropriate page based on where we came from
            if (widget.fromCageGrid) {
              context.go('/cages/grid');
            } else {
              context.go('/cages/list');
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          _cageUuid == null || _cageUuid == 'new' ? 'Create Cage' : 'Edit Cage',
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _cageTagController,
                decoration: const InputDecoration(
                  labelText: 'Cage Tag',
                  hintText: 'Enter cage tag',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a cage tag';
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
              SelectStrain(
                selectedStrain: _selectedStrain,
                onChanged: (strain) {
                  setState(() {
                    _selectedStrain = strain;
                  });
                },
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
              SizedBox(
                width: double.infinity,
                child: MoustraButtonPrimary(
                  onPressed: _saveCage,
                  label: 'Save Cage',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
