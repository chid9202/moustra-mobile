import 'package:flutter/material.dart';
import 'package:moustra/services/dtos/rack_dto.dart';

class CageCompactView extends StatelessWidget {
  final RackCageDto cage;

  const CageCompactView({super.key, required this.cage});

  @override
  Widget build(BuildContext context) {
    final animals = cage.animals ?? [];
    final males = animals.where((e) => e.sex == 'M').length;
    final females = animals.where((e) => e.sex == 'F').length;
    final status = cage.status ?? 'Unknown';

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive sizes based on available space
        final availableHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 300.0;
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 300.0;
        final baseSize = (availableHeight < availableWidth
            ? availableHeight
            : availableWidth);

        // Scale font sizes and dimensions based on available space (with minimum sizes)
        final statusFontSize = (baseSize * 0.08).clamp(8.0, 26.0);
        final iconSize = (baseSize * 0.12).clamp(16.0, 48.0);
        final iconFontSize = (baseSize * 0.08).clamp(10.0, 26.0);
        final spacing = (baseSize * 0.04).clamp(2.0, 20.0);
        final chipPadding = (baseSize * 0.03).clamp(2.0, 16.0);

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.minHeight > 0 ? constraints.minHeight : 0,
              maxHeight: constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : double.infinity,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status badge at the top
                  Center(
                    child: Chip(
                      label: Text(
                        status,
                        style: TextStyle(
                          fontSize: statusFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: _getStatusColor(status),
                      padding: EdgeInsets.symmetric(
                        horizontal: chipPadding,
                        vertical: chipPadding * 0.8,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  SizedBox(height: spacing),
                  // Male count with icon chips
                  Wrap(
                    alignment: WrapAlignment.start,
                    spacing: spacing * 0.5,
                    runSpacing: spacing * 0.5,
                    children: List.generate(
                      males,
                      (index) => Container(
                        width: iconSize,
                        height: iconSize,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            'M',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: iconFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: spacing * 0.8),
                  // Female count with icon chips
                  Wrap(
                    alignment: WrapAlignment.start,
                    spacing: spacing * 0.5,
                    runSpacing: spacing * 0.5,
                    children: List.generate(
                      females,
                      (index) => Container(
                        width: iconSize,
                        height: iconSize,
                        decoration: BoxDecoration(
                          color: Colors.pink,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            'F',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: iconFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('active') || lowerStatus.contains('ok')) {
      return Colors.green.shade100;
    } else if (lowerStatus.contains('error') ||
        lowerStatus.contains('issue') ||
        lowerStatus.contains('problem')) {
      return Colors.red.shade100;
    } else if (lowerStatus.contains('warning') ||
        lowerStatus.contains('caution')) {
      return Colors.orange.shade100;
    }
    return Colors.grey.shade200;
  }
}
