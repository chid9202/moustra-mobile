import 'dart:async';

import 'package:flutter/material.dart';

import 'package:moustra/widgets/cage/cage_interactive_view.dart';
import 'package:go_router/go_router.dart';
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
import 'package:moustra/widgets/cage/empty_cage_slot.dart';
import 'package:moustra/helpers/snackbar_helper.dart';
import 'package:moustra/services/clients/event_api.dart';
import 'package:moustra/helpers/rack_utils.dart';
import 'package:moustra/stores/cage_store.dart';

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

  /// Refetch when returning to this tab; shell navigation may reuse [State]
  /// without calling [initState] again (e.g. Cages → Racks in the drawer).
  GoRouter? _router;
  VoidCallback? _shellLocationListener;
  String? _lastKnownLocationForRefetch;
  bool _shellRouteDelegatePrimed = false;

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
    eventApi.trackEvent('view_cage_grid');
    _transformationController.addListener(_onTransformationChanged);
    _initializeScreen();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attachShellLocationListener();
    });
  }

  void _attachShellLocationListener() {
    if (!mounted) return;
    final router = GoRouter.maybeOf(context);
    if (router == null) return;
    _detachShellLocationListener();
    _router = router;
    _shellRouteDelegatePrimed = false;
    _lastKnownLocationForRefetch = null;
    _shellLocationListener = _onShellLocationChanged;
    router.routerDelegate.addListener(_shellLocationListener!);
  }

  void _detachShellLocationListener() {
    if (_router != null && _shellLocationListener != null) {
      _router!.routerDelegate.removeListener(_shellLocationListener!);
    }
    _router = null;
    _shellLocationListener = null;
  }

  void _onShellLocationChanged() {
    if (!mounted || _router == null) return;
    final path = _router!.state.uri.path;
    // First notification syncs state only — avoids a second rack fetch right
    // after [initState] (delegate often fires once when the listener attaches).
    if (!_shellRouteDelegatePrimed) {
      _shellRouteDelegatePrimed = true;
      _lastKnownLocationForRefetch = path;
      return;
    }
    final previous = _lastKnownLocationForRefetch;
    _lastKnownLocationForRefetch = path;
    if (path == '/cage/grid' && previous != '/cage/grid') {
      _initializeScreen();
    }
  }

  Future<void> _initializeScreen() async {
    final preservedMatrix = rackStore.value?.transformationMatrix;
    final rackUuid = rackStore.value?.rackData.rackUuid;
    await _loadRackData(
      rackUuid: rackUuid,
      preservedMatrix: preservedMatrix,
      silent: true,
    );
    await _restoreSavedPosition();
  }

  Future<void> _loadRackData({
    String? rackUuid,
    List<double>? preservedMatrix,
    bool silent = false,
  }) async {
    if (!silent && mounted) {
      setState(() {
        _isLoadingRack = true;
      });
    }
    try {
      await useRackStore();
      final newRackData = await rackApi.getRack(rackUuid: rackUuid);
      rackStore.value = RackStoreDto(
        rackData: newRackData,
        transformationMatrix:
            preservedMatrix ?? rackStore.value?.transformationMatrix,
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
        showAppSnackBar(context, 'Error loading rack: ${e.toString()}', isError: true);
      }
    }
  }

  Future<void> _switchRack(RackSimpleDto rack) async {
    setState(() {
      _selectedRack = rack;
    });
    await _loadRackData(rackUuid: rack.rackUuid);
    // Reset view position (zoom and pan) to default when switching racks
    if (!mounted) return;
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
    _detachShellLocationListener();
    _transformationController.removeListener(_onTransformationChanged);
    _saveMatrixTimer?.cancel();
    _rebuildTimer?.cancel();
    _transformationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTransformationChanged() {
    // Debounce saveTransformationMatrix to avoid updating store on every frame
    _saveMatrixTimer?.cancel();
    _saveMatrixTimer = Timer(
      const Duration(milliseconds: CagesGridConstants.saveMatrixTimerMs),
      () {
        saveTransformationMatrix(_transformationController.value);
      },
    );

    // Update zoom level less frequently (only for UI display, not view switching)
    // Since compact view is disabled, we don't need frequent updates
    _rebuildTimer?.cancel();
    _rebuildTimer = Timer(
      const Duration(
        milliseconds: 200,
      ), // Increased from 50ms for better performance
      () {
        if (mounted) {
          final currentZoomLevel = UtilHelper.getScaleFromMatrix(
            _transformationController.value,
          );
          // Only rebuild if zoom level changed significantly (for floating bar display)
          if ((currentZoomLevel - _currentZoomLevel).abs() > 0.05) {
            setState(() {
              _currentZoomLevel = currentZoomLevel;
            });
          }
        }
      },
    );
  }

  Future<void> _restoreSavedPosition() async {
    // First try to load from SharedPreferences (persisted across app restarts)
    Matrix4? savedMatrix = await getSavedTransformationMatrixFromStorage();

    if (!mounted) return;

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

    // Calculate grid view width based on rack width and cage width
    final rackWidth = data.rackWidth ?? CagesGridConstants.defaultRackWidth;
    final gridViewWidth = CagesGridConstants.getGridViewWidth(rackWidth);
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
          // Invalidate rack store before refetching
          final preservedMatrix = rackStore.value?.transformationMatrix;
          rackStore.value = null;
          await _loadRackData(
            rackUuid: rackUuid,
            preservedMatrix: preservedMatrix,
          );
        },
      ),
    );
  }

  Future<void> _handleAddCage({required int x, required int y}) async {
    final rackUuid = data.rackUuid;
    if (rackUuid == null) {
      showAppSnackBar(context, 'Rack UUID is required', isError: true);
      return;
    }

    try {
      final rackName = data.rackName;
      final tag = generateCageTag(rackName, RackGridPosition(x: x, y: y)) ?? 'New Cage';
      await cageApi.createCageInRack(
        cageTag: tag,
        rackUuid: rackUuid,
        xPosition: x,
        yPosition: y,
      );
      // Refresh stores after creation
      await _loadRackData(rackUuid: rackUuid);
      await refreshCageStore();
      if (mounted) {
        showAppSnackBar(context, 'Cage created successfully', isSuccess: true);
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, 'Error creating cage: ${e.toString()}', isError: true);
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
        final gridViewWidth = CagesGridConstants.getGridViewWidth(rackWidth);

        return Column(
          children: [
            // Bar at the top (not floating)
            CagesGridFloatingBar(
              racks: data.racks,
              selectedRack: _selectedRack,
              onRackSelected: _switchRack,
              onAddRack: () => _showRackDialog(isEdit: false),
              onEditRack: () => _showRackDialog(isEdit: true),
              onOpenRack: () {
                if (_selectedRack != null) {
                  context.push('/rack/${_selectedRack!.rackUuid}');
                }
              },
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
            // Interactive viewer area
            Expanded(
              child: Stack(
                children: [
                  InteractiveViewer(
                    boundaryMargin: const EdgeInsets.all(24),
                    constrained: false,
                    transformationController: _transformationController,
                    minScale: CagesGridConstants.minScale,
                    maxScale: CagesGridConstants.maxScale,
                    scaleEnabled: true,
                    panEnabled: true,
                    trackpadScrollCausesScale: true,
                    // Wrap in RepaintBoundary to isolate repaints during pan/zoom
                    child: RepaintBoundary(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: SizedBox(
                          width: gridViewWidth,
                          height: CagesGridConstants.gridViewHeight,
                          child: GridView.builder(
                            controller: _scrollController,
                            itemCount: maxCages,
                            physics: const NeverScrollableScrollPhysics(),
                            // Performance optimizations
                            addAutomaticKeepAlives: false,
                            addRepaintBoundaries: true,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: rackWidth,
                                  crossAxisSpacing:
                                      CagesGridConstants.crossAxisSpacing,
                                  mainAxisSpacing:
                                      CagesGridConstants.mainAxisSpacing,
                                  childAspectRatio:
                                      CagesGridConstants.childAspectRatio,
                                ),
                            itemBuilder: (context, index) {
                              // Calculate x, y from index
                              final x = index % rackWidth;
                              final y = index ~/ rackWidth;
                              
                              // Check if cages have xPosition/yPosition set
                              final cages = data.cages ?? [];
                              final hasPositions = cages.isNotEmpty && 
                                  cages.any((c) => c.xPosition != null && c.yPosition != null);
                              
                              // Find cage by position if available, otherwise use index
                              RackCageDto? resultItem;
                              if (hasPositions) {
                                resultItem = cages.cast<RackCageDto?>().firstWhere(
                                  (c) => c?.xPosition == x && c?.yPosition == y,
                                  orElse: () => null,
                                );
                              } else {
                                resultItem = index < cages.length ? cages[index] : null;
                              }
                              
                              // Show empty slot for any position without a cage
                              if (resultItem == null) {
                                return ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight: CagesGridConstants.maxCageHeight,
                                  ),
                                  child: EmptyCageSlot(
                                    onTap: () => _handleAddCage(x: x, y: y),
                                  ),
                                );
                              }
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
                  ),
                  // FAB menu
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
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
