import 'dart:async';

import 'package:flutter/material.dart';

import 'package:moustra/widgets/cage/cage_interactive_view.dart';
import 'package:moustra/services/dtos/rack_dto.dart';
import 'package:moustra/services/dtos/stores/rack_store_dto.dart';
import 'package:moustra/stores/rack_store.dart';

class CagesGridScreen extends StatefulWidget {
  const CagesGridScreen({super.key});

  @override
  State<CagesGridScreen> createState() => _CagesGridScreenState();
}

class _CagesGridScreenState extends State<CagesGridScreen> {
  final TransformationController _transformationController =
      TransformationController();
  final ScrollController _scrollController = ScrollController();

  Timer? _saveMatrixTimer;
  int _previousDetailLevel = 0;

  late RackDto data;

  @override
  void initState() {
    super.initState();
    _loadRackData();
    _transformationController.addListener(_onTransformationChanged);
    _restoreSavedPosition();
  }

  Future<void> _loadRackData() async {
    await useRackStore();
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _saveMatrixTimer?.cancel();
    _transformationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTransformationChanged() {
    // Only trigger rebuild if detailLevel actually changes
    final currentZoomLevel = _transformationController.value.entry(0, 0);
    final currentDetailLevel = currentZoomLevel.ceil();

    if (currentDetailLevel != _previousDetailLevel) {
      setState(() {
        _previousDetailLevel = currentDetailLevel;
      });
    }

    // Debounce saveTransformationMatrix to avoid updating store on every frame
    _saveMatrixTimer?.cancel();
    _saveMatrixTimer = Timer(const Duration(milliseconds: 300), () {
      saveTransformationMatrix(_transformationController.value);
    });
  }

  void _restoreSavedPosition() {
    // Restore the saved transformation matrix if available
    final savedMatrix = getSavedTransformationMatrix();
    if (savedMatrix != null) {
      _transformationController.value = savedMatrix;
      final savedZoomLevel = savedMatrix.entry(0, 0);
      _previousDetailLevel = savedZoomLevel.ceil();
    } else {
      // Set default position if no saved position exists
      _transformationController.value.scaleByDouble(1, 1, 1, 1);
      _previousDetailLevel = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Compute zoomLevel directly from transformation controller
    // This avoids storing it in state and triggering unnecessary rebuilds
    final zoomLevel = _transformationController.value.entry(0, 0);
    final detailLevel = zoomLevel.ceil();

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

        return InteractiveViewer(
          constrained: false,
          transformationController: _transformationController,
          minScale: 0.1,
          maxScale: 2.0,
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
                  detailLevel: detailLevel,
                  rackData: data,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
