import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/helpers/account_helper.dart';
import 'package:moustra/helpers/rack_utils.dart';
import 'package:moustra/services/clients/cage_api.dart';
import 'package:moustra/services/clients/event_api.dart';
import 'package:moustra/services/clients/rack_api.dart';
import 'package:moustra/services/dtos/cage_dto.dart';
import 'package:moustra/services/dtos/post_cage_dto.dart';
import 'package:moustra/services/dtos/put_cage_dto.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/services/dtos/stores/account_store_dto.dart';
import 'package:moustra/services/dtos/stores/strain_store_dto.dart';
import 'package:moustra/stores/cage_store.dart';
import 'package:moustra/stores/animal_store.dart';
import 'package:moustra/widgets/shared/button.dart';
import 'package:moustra/widgets/shared/select_date.dart';
import 'package:moustra/widgets/shared/select_owner.dart';
import 'package:moustra/widgets/shared/select_strain.dart';
import 'package:moustra/screens/barcode_scanner_screen.dart';
import 'package:moustra/widgets/note/note_list.dart';
import 'package:moustra/services/dtos/note_entity_type.dart';
import 'package:moustra/widgets/cage/cage_animals_list.dart';
import 'package:moustra/widgets/cage/mating_history_section.dart';
import 'package:moustra/helpers/snackbar_helper.dart';
import 'package:moustra/widgets/rack_cage_grid.dart';

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
  final _barcodeController = TextEditingController();

  StrainStoreDto? _selectedStrain;
  DateTime? _selectedSetUpDate;
  AccountStoreDto? _selectedOwner;
  CageDto? _cageData;
  bool _cageDataLoaded = false;
  bool _cageTagManuallyEdited = false;

  // Rack grid state (create mode)
  RackDto? _selectedRack;
  List<RackSimpleDto> _allRacks = [];
  RackGridPosition? _selectedPosition;
  String? _selectedCageUuidInGrid;
  bool _isLoadingRack = false;

  String? get _cageUuid {
    final state = GoRouterState.of(context);
    return state.pathParameters['cageUuid'];
  }

  bool get _isCreateMode => _cageUuid == null || _cageUuid == 'new';

  bool _rackLoadStarted = false;

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
    if (_isCreateMode && !_rackLoadStarted) {
      _rackLoadStarted = true;
      _loadDefaultRack();
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

  Future<void> _loadDefaultRack() async {
    setState(() => _isLoadingRack = true);
    try {
      final rack = await rackApi.getRack();
      if (mounted) {
        setState(() {
          _selectedRack = rack;
          _allRacks = rack.racks ?? [];
          _isLoadingRack = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading rack: $e');
      if (mounted) {
        setState(() => _isLoadingRack = false);
      }
    }
  }

  Future<void> _switchRack(String rackUuid) async {
    setState(() {
      _isLoadingRack = true;
      _selectedPosition = null;
      _selectedCageUuidInGrid = null;
      if (!_cageTagManuallyEdited) {
        _cageTagController.text = '';
      }
    });
    try {
      final rack = await rackApi.getRack(rackUuid: rackUuid);
      if (mounted) {
        setState(() {
          _selectedRack = rack;
          _allRacks = rack.racks ?? [];
          _isLoadingRack = false;
        });
      }
    } catch (e) {
      debugPrint('Error switching rack: $e');
      if (mounted) {
        setState(() => _isLoadingRack = false);
      }
    }
  }

  void _handlePositionSelected(int x, int y) {
    setState(() {
      _selectedPosition = RackGridPosition(x: x, y: y);
      _selectedCageUuidInGrid = null;
    });
    _autoFillCageTag(x, y);
  }

  void _handleCageSelected(RackCageDto cage) {
    if (cage.xPosition == null || cage.yPosition == null) return;
    setState(() {
      _selectedCageUuidInGrid = cage.cageUuid;
      _selectedPosition = null;
    });
    _autoFillCageTag(cage.xPosition!, cage.yPosition!);
  }

  void _autoFillCageTag(int x, int y) {
    if (_cageTagManuallyEdited) return;
    final tag = generateCageTag(
      _selectedRack?.rackName,
      RackGridPosition(x: x, y: y),
    );
    if (tag != null) {
      _cageTagController.text = tag;
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
          _barcodeController.text = cage.barcode ?? '';
          _selectedStrain = cage.strain != null
              ? StrainStoreDto(
                  strainId: cage.strain!.strainId,
                  strainUuid: cage.strain!.strainUuid,
                  strainName: cage.strain!.strainName,
                  weanAge: cage.strain!.weanAge,
                  genotypes: const [],
                )
              : null;
          _selectedSetUpDate = cage.createdDate;
          _selectedOwner = cage.owner.toAccountStoreDto();
          _cageData = cage;
          _cageDataLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading cage: $e');
      if (mounted) {
        showAppSnackBar(context, 'Error loading cage: $e', isError: true);
      }
      _cageDataLoaded = true;
    }
  }

  @override
  void dispose() {
    _cageTagController.dispose();
    _commentController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    try {
      final String? barcode = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
      );

      if (barcode != null && mounted) {
        setState(() {
          _barcodeController.text = barcode;
        });
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, 'Error scanning barcode: $e', isError: true);
      }
    }
  }

  void _saveCage() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final cageUuid = _cageUuid;
      final owner = _selectedOwner ?? await AccountHelper.getDefaultOwner();

      if (cageUuid == null || cageUuid == 'new') {
        final cage = PostCageDto(
          cageTag: _cageTagController.text,
          owner: owner,
          strain: _selectedStrain?.toStrainSummaryDto(),
          setUpDate: _selectedSetUpDate,
          comment: _commentController.text.isEmpty
              ? null
              : _commentController.text,
          barcode: _barcodeController.text.isEmpty
              ? null
              : _barcodeController.text,
          rack: _selectedRack?.rackUuid,
          xPosition: _selectedPosition?.x,
          yPosition: _selectedPosition?.y,
        );
        await CageApi().createCage(cage);
        eventApi.trackEvent('create_cage');
        await refreshCageStore();
        await refreshAnimalStore();
        if (mounted) {
          showAppSnackBar(context, 'Cage created successfully!', isSuccess: true);
        }
      } else {
        final cageData = _cageData;
        if (cageData == null) {
          if (mounted) {
            showAppSnackBar(context, 'Error: Cage data not loaded', isError: true);
          }
          return;
        }

        await CageApi().putCage(
          cageUuid,
          PutCageDto(
            cageId: cageData.cageId,
            cageUuid: cageUuid,
            cageTag: _cageTagController.text,
            owner: owner,
            strain: _selectedStrain?.toStrainSummaryDto(),
            setUpDate: _selectedSetUpDate,
            comment: _commentController.text.isEmpty
                ? null
                : _commentController.text,
            barcode: _barcodeController.text.isEmpty
                ? null
                : _barcodeController.text,
          ),
        );
        eventApi.trackEvent('update_cage');
        await refreshCageStore();
        await refreshAnimalStore();
        if (mounted) {
          showAppSnackBar(context, 'Cage updated successfully!', isSuccess: true);
        }
      }

      if (mounted) {
        if (widget.fromCageGrid) {
          context.go('/cage/grid');
        } else {
          context.go('/cage/list');
        }
      }
    } catch (e) {
      debugPrint('Error saving cage: $e');
      if (mounted) {
        showAppSnackBar(context, 'Error saving cage: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedOwner == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_cageUuid != null && !_cageDataLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (widget.fromCageGrid) {
              context.go('/cage/grid');
            } else {
              context.go('/cage/list');
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(_isCreateMode ? 'Create Cage' : 'Edit Cage'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rack grid for create mode
              if (_isCreateMode) ...[
                if (_isLoadingRack)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ))
                else if (_selectedRack != null)
                  RackCageGrid(
                    racks: _allRacks,
                    selectedRack: _selectedRack,
                    selectedPosition: _selectedPosition,
                    selectedCageUuid: _selectedCageUuidInGrid,
                    onChangeRack: _switchRack,
                    onSelectCage: _handleCageSelected,
                    onCreateCage: (posLabel, x, y) =>
                        _handlePositionSelected(x, y),
                  ),
                const SizedBox(height: 16),
              ],

              // Cage Tag
              Semantics(
                label: 'Cage Tag',
                textField: true,
                child: TextFormField(
                  controller: _cageTagController,
                  decoration: const InputDecoration(
                    labelText: 'Cage Tag',
                    hintText: 'Enter cage tag',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _saveCage(),
                  onChanged: (_) {
                    _cageTagManuallyEdited = true;
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a cage tag';
                    }
                    return null;
                  },
                ),
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
                hintText: 'Select set up date (optional)',
              ),
              const SizedBox(height: 16),
              Semantics(
                label: 'Barcode',
                textField: true,
                child: TextFormField(
                  controller: _barcodeController,
                  decoration: InputDecoration(
                    labelText: 'Barcode',
                    hintText: 'Enter or scan barcode',
                    border: const OutlineInputBorder(),
                    suffixIcon: Semantics(
                      label: 'Scan barcode',
                      button: true,
                      child: IconButton(
                        icon: const Icon(Icons.qr_code_scanner),
                        onPressed: _scanBarcode,
                        tooltip: 'Scan barcode',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 32),

              // Animals Section
              if (!_isCreateMode && _cageData != null)
                CageAnimalsList(
                  animals: _cageData!.animals,
                  cageUuid: _cageUuid!,
                  fromCageGrid: widget.fromCageGrid,
                ),

              // Mating History Section
              if (!_isCreateMode &&
                  _cageData?.matingHistory != null &&
                  _cageData!.matingHistory!.isNotEmpty)
                MatingHistorySection(matings: _cageData!.matingHistory!),

              // Notes Section
              if (!_isCreateMode)
                NoteList(
                  entityUuid: _cageUuid,
                  entityType: NoteEntityType.cage,
                  initialNotes: _cageData?.notes,
                ),
              Semantics(
                label: 'Save Cage',
                button: true,
                child: SizedBox(
                  width: double.infinity,
                  child: MoustraButtonPrimary(
                    onPressed: _saveCage,
                    label: 'Save Cage',
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
