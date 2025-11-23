import 'dart:async';

import 'package:flutter/material.dart';

import 'package:moustra/widgets/cage/cage_interactive_view.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/services/dtos/stores/rack_store_dto.dart';
import 'package:moustra/stores/rack_store.dart';
import 'package:moustra/helpers/util_helper.dart';
import 'package:moustra/widgets/movable_fab_menu.dart';

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
  double _currentZoomLevel = 0.6;

  late RackDto data;

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformationChanged);
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    // Load rack data first
    await _loadRackData();
    // Then restore saved position after data is loaded
    await _restoreSavedPosition();
  }

  Future<void> _loadRackData() async {
    await useRackStore();
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
    _rebuildTimer = Timer(const Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          _currentZoomLevel = currentZoomLevel;
        });
      }
    });

    // Debounce saveTransformationMatrix to avoid updating store on every frame
    _saveMatrixTimer?.cancel();
    _saveMatrixTimer = Timer(const Duration(milliseconds: 300), () {
      saveTransformationMatrix(_transformationController.value);
    });
  }

  Future<void> _restoreSavedPosition() async {
    // First try to load from SharedPreferences (persisted across app restarts)
    Matrix4? savedMatrix = await getSavedTransformationMatrixFromStorage();

    // Fall back to in-memory store if SharedPreferences has no data
    if (savedMatrix == null) {
      savedMatrix = getSavedTransformationMatrix();
    }

    if (savedMatrix != null) {
      _transformationController.value = savedMatrix;
      final savedZoomLevel = UtilHelper.getScaleFromMatrix(savedMatrix);
      setState(() {
        _currentZoomLevel = savedZoomLevel;
      });
    } else {
      // Set default position if no saved position exists
      _transformationController.value.scaleByDouble(0.6, 0.6, 1, 1);
      setState(() {
        _currentZoomLevel = 0.6;
      });
    }
  }

  /// Calculate zoom level to fit all horizontal cages on screen
  void _zoomToFitScreen(BuildContext context) {
    final viewportWidth = MediaQuery.of(context).size.width;

    // GridView child width is 2500px
    // Calculate scale to fit the grid width in viewport with some padding
    const gridViewWidth = 2500.0;
    const paddingMargin = 40.0; // 20px on each side

    final scale = (viewportWidth - paddingMargin) / gridViewWidth;

    // Clamp scale to valid range (minScale: 0.1, maxScale: 2.0)
    final clampedScale = scale.clamp(0.1, 2.0);

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
    _zoomToLevel(0.6);
  }

  /// Zoom to compact view (3.9)
  void _zoomToCompactView() {
    _zoomToLevel(0.39);
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

        final rackWidth = data.rackWidth ?? 5;
        final rackHeight = data.rackHeight ?? 1;
        final maxCages = rackWidth * rackHeight;

        return Stack(
          children: [
            InteractiveViewer(
              constrained: false,
              transformationController: _transformationController,
              minScale: 0.1,
              maxScale: 4.0,
              scaleEnabled: true,
              panEnabled: true,
              trackpadScrollCausesScale: true,
              child: SizedBox(
                width: 2500,
                height: 8000,
                child: GridView.builder(
                  controller: _scrollController,
                  itemCount: maxCages,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: rackWidth,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.0,
                  ),
                  itemBuilder: (context, index) {
                    final resultItem = data.cages?[index];
                    if (resultItem == null) return Container();
                    return CageInteractiveView(
                      cage: resultItem,
                      zoomLevel: _currentZoomLevel,
                      rackData: data,
                    );
                  },
                ),
              ),
            ),
            Positioned.fill(
              child: MovableFabMenu(
                controller: _fabController,
                heroTag: 'cages-grid-zoom-menu',
                margin: const EdgeInsets.only(right: 24, bottom: 24),
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
          ],
        );
      },
    );
  }
}
