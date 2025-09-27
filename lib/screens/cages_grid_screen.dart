import 'package:flutter/material.dart';

import 'package:moustra/screens/cage/cage_interactive_view.dart';
import 'package:moustra/services/clients/rack_api.dart';
import 'package:moustra/services/dtos/rack_dto.dart';

class CagesGridScreen extends StatefulWidget {
  const CagesGridScreen({super.key});

  @override
  State<CagesGridScreen> createState() => _CagesGridScreenState();
}

class _CagesGridScreenState extends State<CagesGridScreen> {
  final TransformationController _transformationController =
      TransformationController();
  final ScrollController _scrollController = ScrollController();
  late Future<RackDto> _rackFuture;

  double zoomLevel = 0.0;

  @override
  void initState() {
    super.initState();
    _rackFuture = rackApi.getRack();
    _transformationController.addListener(_onTransformationChanged);
    _transformationController.value.scaleByDouble(1, 1, 1, 1);
    // final zoomFactor = 0.75;
    // final xTranslate = 300.0;
    // final yTranslate = 300.0;
    // _transformationController.value.setEntry(0, 0, zoomFactor);
    // _transformationController.value.setEntry(1, 1, zoomFactor);
    // _transformationController.value.setEntry(2, 2, zoomFactor);
    // _transformationController.value.setEntry(0, 3, -xTranslate);
    // _transformationController.value.setEntry(1, 3, -yTranslate);
    // _transformationController.value.scaleByDouble(sx, sy, sz, sw)
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
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _rackFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${snapshot.error}'),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _rackFuture = rackApi.getRack();
                    });
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        final data = snapshot.data;
        if (data == null) {
          return Center(child: Text('No data received'));
        }

        return InteractiveViewer(
          constrained: false,
          transformationController: _transformationController,
          minScale: 0.1,
          maxScale: 2.0,
          scaleEnabled: true,
          panEnabled: true,
          trackpadScrollCausesScale: true,
          child: SizedBox(
            width: 1500,
            height: 1500,
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
