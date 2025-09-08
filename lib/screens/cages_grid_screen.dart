import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grid_view/detail_item.dart';
import 'package:grid_view/detail_view.dart';

class CagesGridScreen extends StatefulWidget {
  const CagesGridScreen({super.key});

  @override
  State<CagesGridScreen> createState() => _CagesGridScreenState();
}

class _CagesGridScreenState extends State<CagesGridScreen> {
  final TransformationController _transformationController =
      TransformationController();
  final ScrollController _scrollController = ScrollController();
  final int _gridCount = 100;
  double zoomLevel = 1;

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformationChanged);
    _transformationController.value.scaleByDouble(1, 1, 1, 1);
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
    return InteractiveViewer(
      constrained: false,
      transformationController: _transformationController,
      minScale: 0.1,
      maxScale: 4.0,
      scaleEnabled: true,
      panEnabled: true,
      child: SizedBox(
        width: 1500,
        height: 1500,
        child: GridView.builder(
          controller: _scrollController,
          itemCount: _gridCount,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                GoRouter.of(context).go('/rooms/$index');
              },
              child: DetailedItemWidget(
                item: DetailedItem(
                  title: 'Grid $index',
                  detailLevel1: 'detailLevel1',
                  detailLevel2: 'detailLevel2',
                  detailLevel3: 'detailLevel3',
                  detailLevel4: 'detailLevel4',
                  detailLevel5: 'detailLevel5',
                ),
                detailLevel: zoomLevel.ceil(),
              ),
            );
          },
        ),
      ),
    );
  }
}
