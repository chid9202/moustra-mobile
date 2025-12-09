import 'dart:async';

import 'package:flutter/material.dart';

import 'package:moustra/widgets/cage/cage_interactive_view.dart';
import 'package:moustra/widgets/cages_grid_floating_bar.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/services/dtos/stores/rack_store_dto.dart';
import 'package:moustra/stores/rack_store.dart';
import 'package:moustra/helpers/util_helper.dart';
import 'package:moustra/widgets/movable_fab_menu.dart';
import 'package:moustra/services/clients/rack_api.dart';
import 'package:moustra/services/clients/cage_api.dart';
import 'package:moustra/constants/cages_grid_constants.dart';
import 'package:moustra/widgets/dialogs/add_or_update_rack.dart';
import 'package:moustra/widgets/cage/add_cage_button.dart';

class CagesGridScreen extends StatefulWidget {
  const CagesGridScreen({super.key});

  @override
  State<CagesGridScreen> createState() => _CagesGridScreenState();
}

class _CagesGridScreenState extends State<CagesGridScreen> {
  final TransformationController _transformationController =
      TransformationController();
  final ScrollController _scrollController = ScrollController();
  final MovableFabMenuController _fabController = MovableFabMenuController();

  Timer? _saveMatrixTimer;
  Timer? _rebuildTimer;
  double _currentZoomLevel = CagesGridConstants.defaultZoomLevel;

  // Search state
  String _searchQuery = '';
  String _searchType = CagesGridConstants.searchTypeAnimalTag;

  // Rack selection state
  RackSimpleDto? _selectedRack;
  bool _isLoadingRack = false;

  late RackDto data;

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformationChanged);
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    // Load rack data first
    await useRackStore();
    // Set initial selected rack from current data
    if (rackStore.value != null) {
      final rackData = rackStore.value!.rackData;
      if (rackData.racks != null && rackData.racks!.isNotEmpty) {
        final currentRackUuid = rackData.rackUuid;
        if (currentRackUuid != null) {
          setState(() {
            _selectedRack = rackData.racks!.firstWhere(
              (r) => r.rackUuid == currentRackUuid,
              orElse: () => rackData.racks!.first,
            );
          });
        } else {
          setState(() {
            _selectedRack = rackData.racks!.first;
          });
        }
      }
    }
    // Then restore saved position after data is loaded
    await _restoreSavedPosition();
  }

  Future<void> _loadRackData({String? rackUuid}) async {
    if (mounted) {
      setState(() {
        _isLoadingRack = true;
      });
    }
    try {
      await useRackStore();
      final newRackData = await rackApi.getRack(rackUuid: rackUuid);
      rackStore.value = RackStoreDto(
        rackData: newRackData,
        transformationMatrix: rackStore.value?.transformationMatrix,
      );
      // Update selected rack if we have racks list
      if (newRackData.racks != null && newRackData.racks!.isNotEmpty) {
        final currentRackUuid = newRackData.rackUuid;
        if (mounted) {
          setState(() {
            if (currentRackUuid != null) {
              _selectedRack = newRackData.racks!.firstWhere(
                (r) => r.rackUuid == currentRackUuid,
                orElse: () => newRackData.racks!.first,
              );
            } else {
              _selectedRack = newRackData.racks!.first;
            }
            _isLoadingRack = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingRack = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRack = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading rack: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _switchRack(RackSimpleDto rack) async {
    setState(() {
      _selectedRack = rack;
    });
    await _loadRackData(rackUuid: rack.rackUuid);
    // Reset view position (zoom and pan) to default when switching racks
    _resetViewPosition();
  }

  /// Reset view position to default (zoom 0.6, centered at top)
  void _resetViewPosition() {
    final defaultMatrix = Matrix4.identity()
      ..scale(CagesGridConstants.defaultZoomLevel);
    _transformationController.value = defaultMatrix;
    setState(() {
      _currentZoomLevel = CagesGridConstants.defaultZoomLevel;
    });
    // Save the reset transformation matrix
    saveTransformationMatrix(defaultMatrix);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _saveMatrixTimer?.cancel();
    _rebuildTimer?.cancel();
    _transformationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTransformationChanged() {
    final currentZoomLevel = UtilHelper.getScaleFromMatrix(
      _transformationController.value,
    );

    // Update zoom level with debouncing to avoid too many rebuilds
    _rebuildTimer?.cancel();
    _rebuildTimer = Timer(
      const Duration(milliseconds: CagesGridConstants.rebuildTimerMs),
      () {
        if (mounted) {
          setState(() {
            _currentZoomLevel = currentZoomLevel;
          });
        }
      },
    );

    // Debounce saveTransformationMatrix to avoid updating store on every frame
    _saveMatrixTimer?.cancel();
    _saveMatrixTimer = Timer(
      const Duration(milliseconds: CagesGridConstants.saveMatrixTimerMs),
      () {
        saveTransformationMatrix(_transformationController.value);
      },
    );
  }

  Future<void> _restoreSavedPosition() async {
    // First try to load from SharedPreferences (persisted across app restarts)
    Matrix4? savedMatrix = await getSavedTransformationMatrixFromStorage();

    // Fall back to in-memory store if SharedPreferences has no data
    savedMatrix ??= getSavedTransformationMatrix();

    if (savedMatrix != null) {
      _transformationController.value = savedMatrix;
      final savedZoomLevel = UtilHelper.getScaleFromMatrix(savedMatrix);
      setState(() {
        _currentZoomLevel = savedZoomLevel;
      });
    } else {
      // Set default position if no saved position exists
      _transformationController.value.scaleByDouble(
        CagesGridConstants.defaultZoomLevel,
        CagesGridConstants.defaultZoomLevel,
        1,
        1,
      );
      setState(() {
        _currentZoomLevel = CagesGridConstants.defaultZoomLevel;
      });
    }
  }

  /// Calculate zoom level to fit all horizontal cages on screen
  void _zoomToFitScreen(BuildContext context) {
    final viewportWidth = MediaQuery.of(context).size.width;

    // GridView child width is 2500px
    // Calculate scale to fit the grid width in viewport with some padding
    const gridViewWidth = CagesGridConstants.gridViewWidth;
    const paddingMargin =
        CagesGridConstants.zoomFitPaddingMargin; // 20px on each side

    final scale = (viewportWidth - paddingMargin) / gridViewWidth;

    // Clamp scale to valid range (minScale: 0.1, maxScale: 4.0)
    final clampedScale = scale.clamp(
      CagesGridConstants.minScale,
      CagesGridConstants.maxScale,
    );

    _zoomToLevel(clampedScale);
  }

  /// Generic zoom function to set zoom level
  void _zoomToLevel(double zoomLevel) {
    final currentMatrix = _transformationController.value;

    // Get current translation
    final currentTranslationX = currentMatrix.getTranslation().x;
    final currentTranslationY = currentMatrix.getTranslation().y;

    // Create new matrix with desired zoom level
    final newMatrix = Matrix4.identity()
      ..translate(currentTranslationX, currentTranslationY)
      ..scale(zoomLevel);

    _transformationController.value = newMatrix;

    // Update zoom level immediately
    setState(() {
      _currentZoomLevel = zoomLevel;
    });

    // Save transformation matrix
    saveTransformationMatrix(newMatrix);
  }

  /// Zoom to default view (0.6)
  void _zoomToDefaultView() {
    _zoomToLevel(CagesGridConstants.defaultZoomLevel);
  }

  /// Zoom to compact view (3.9)
  void _zoomToCompactView() {
    _zoomToLevel(CagesGridConstants.compactViewZoomLevel);
  }

  void _showRackDialog({bool isEdit = false}) {
    showDialog(
      context: context,
      builder: (context) => AddOrUpdateRackDialog(
        rackData: isEdit ? data : null,
        onSuccess: ({String? rackUuid}) async {
          await _loadRackData(rackUuid: rackUuid);
        },
      ),
    );
  }

  Widget _buildAddCageButton() {
    return AddCageButton(onTap: _handleAddCage);
  }

  Future<void> _handleAddCage() async {
    final rackUuid = data.rackUuid;
    if (rackUuid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rack UUID is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await cageApi.createCageInRack(cageTag: 'New Cage', rackUuid: rackUuid);
      // Fetch the current rack again after successful creation
      await _loadRackData(rackUuid: rackUuid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cage created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating cage: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<RackStoreDto?>(
      valueListenable: rackStore,
      builder: (context, rackStoreValue, child) {
        if (rackStoreValue == null) {
          return Center(child: CircularProgressIndicator());
        }

        data = rackStoreValue.rackData;

        final rackWidth = data.rackWidth ?? CagesGridConstants.defaultRackWidth;
        final rackHeight =
            data.rackHeight ?? CagesGridConstants.defaultRackHeight;
        final maxCages = rackWidth * rackHeight;

        return Stack(
          children: [
            // Loading overlay
            if (_isLoadingRack)
              Positioned.fill(
                child: Container(
                  color: Colors.white.withOpacity(
                    CagesGridConstants.loadingOverlayOpacity,
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            InteractiveViewer(
              constrained: false,
              transformationController: _transformationController,
              minScale: CagesGridConstants.minScale,
              maxScale: CagesGridConstants.maxScale,
              scaleEnabled: true,
              panEnabled: true,
              trackpadScrollCausesScale: true,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: CagesGridConstants.gridTopPadding,
                ),
                child: SizedBox(
                  width: CagesGridConstants.gridViewWidth,
                  height: CagesGridConstants.gridViewHeight,
                  child: GridView.builder(
                    controller: _scrollController,
                    itemCount: maxCages,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: rackWidth,
                      crossAxisSpacing: CagesGridConstants.crossAxisSpacing,
                      mainAxisSpacing: CagesGridConstants.mainAxisSpacing,
                      childAspectRatio: CagesGridConstants.childAspectRatio,
                    ),
                    itemBuilder: (context, index) {
                      // Check if index is within bounds of the cages array
                      final cagesLength = data.cages?.length ?? 0;

                      // Show Plus button in the first empty slot if rack is not full
                      if (index == cagesLength && index < maxCages) {
                        return _buildAddCageButton();
                      }

                      if (index >= cagesLength) {
                        return Container();
                      }
                      final resultItem = data.cages?[index];
                      if (resultItem == null) return Container();
                      return CageInteractiveView(
                        cage: resultItem,
                        zoomLevel: _currentZoomLevel,
                        rackData: data,
                        searchQuery: _searchQuery.isNotEmpty
                            ? _searchQuery
                            : null,
                        searchType: _searchType,
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: MovableFabMenu(
                controller: _fabController,
                heroTag: 'cages-grid-zoom-menu',
                margin: EdgeInsets.only(
                  right: CagesGridConstants.fabMenuMargin,
                  bottom: CagesGridConstants.fabMenuMargin,
                ),
                actions: [
                  FabMenuAction(
                    label: 'Fit to Screen',
                    icon: const Icon(Icons.fit_screen),
                    onPressed: () => _zoomToFitScreen(context),
                  ),
                  FabMenuAction(
                    label: 'Default View',
                    icon: const Icon(Icons.zoom_out_map),
                    onPressed: _zoomToDefaultView,
                  ),
                  FabMenuAction(
                    label: 'Compact View',
                    icon: const Icon(Icons.view_compact),
                    onPressed: _zoomToCompactView,
                  ),
                ],
              ),
            ),
            // Floating bar at the top - placed last to appear on top
            Positioned(
              top: CagesGridConstants.floatingBarMargin,
              left: CagesGridConstants.floatingBarMargin,
              right: CagesGridConstants.floatingBarMargin,
              child: CagesGridFloatingBar(
                racks: data.racks,
                selectedRack: _selectedRack,
                onRackSelected: _switchRack,
                onAddRack: () => _showRackDialog(isEdit: false),
                onEditRack: () => _showRackDialog(isEdit: true),
                searchType: _searchType,
                searchQuery: _searchQuery,
                onSearchTypeChanged: (value) {
                  setState(() {
                    _searchType = value;
                    _searchQuery = ''; // Clear search when switching type
                  });
                },
                onSearchQueryChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                zoomLevel: _currentZoomLevel,
              ),
            ),
          ],
        );
      },
    );
  }
}
