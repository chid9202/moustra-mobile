import 'package:flutter/material.dart';
import '../colony_wizard_constants.dart';

class WizardStepper extends StatelessWidget {
  final int activeStep;
  final Function(int) onStepTapped;

  const WizardStepper({
    super.key,
    required this.activeStep,
    required this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          ColonyWizardConstants.stepLabels.length,
          (index) => _buildStepItem(context, index),
        ),
      ),
    );
  }

  Widget _buildStepItem(BuildContext context, int index) {
    final theme = Theme.of(context);
    final isActive = index == activeStep;
    final isCompleted = index < activeStep;
    final label = ColonyWizardConstants.stepLabels[index];

    return InkWell(
      onTap: () => onStepTapped(index),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Step circle
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? theme.colorScheme.primary
                    : isCompleted
                        ? theme.colorScheme.primary.withOpacity(0.8)
                        : theme.colorScheme.surfaceContainerHighest,
                border: Border.all(
                  color: isActive || isCompleted
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                  width: 2,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? Icon(
                        Icons.check,
                        size: 16,
                        color: theme.colorScheme.onPrimary,
                      )
                    : Text(
                        '${index + 1}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isActive
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 8),
            // Step label
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            // Connector line (except for last item)
            if (index < ColonyWizardConstants.stepLabels.length - 1) ...[
              const SizedBox(width: 8),
              Container(
                width: 24,
                height: 2,
                color: isCompleted
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
