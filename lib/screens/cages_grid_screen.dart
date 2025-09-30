import 'package:flutter/material.dart';

import 'package:moustra/screens/cage/cage_interactive_view.dart';
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

  double zoomLevel = 0.0;

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
    _transformationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTransformationChanged() {
    setState(() {
      zoomLevel = _transformationController.value.entry(0, 0);
    });
    // Save the current transformation matrix to the store
    saveTransformationMatrix(_transformationController.value);
  }

  void _restoreSavedPosition() {
    // Restore the saved transformation matrix if available
    final savedMatrix = getSavedTransformationMatrix();
    if (savedMatrix != null) {
      _transformationController.value = savedMatrix;
      zoomLevel = savedMatrix.entry(0, 0);
    } else {
      // Set default position if no saved position exists
      _transformationController.value.scaleByDouble(1, 1, 1, 1);
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

        return InteractiveViewer(
          constrained: false,
          transformationController: _transformationController,
          minScale: 0.1,
          maxScale: 2.0,
          scaleEnabled: true,
          panEnabled: true,
          trackpadScrollCausesScale: true,
          child: SizedBox(
            width: 2000,
            height: 5500,
            child: GridView.builder(
              controller: _scrollController,
              itemCount: data.cages?.length ?? 0,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (context, index) {
                final resultItem = data.cages?[index];
                if (resultItem == null) return Container();
                return CageInteractiveView(
                  cage: resultItem,
                  detailLevel: zoomLevel.ceil(),
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
