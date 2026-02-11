import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'colony_wizard_constants.dart';
import 'state/wizard_state.dart';
import 'steps/welcome_step.dart';
import 'steps/strains_genotypes_step.dart';
import 'steps/racks_step.dart';
import 'steps/cages_animals_step.dart';
import 'steps/review_step.dart';
import 'widgets/wizard_stepper.dart';
import 'widgets/undo_snackbar.dart';

class ColonyWizardScreen extends StatefulWidget {
  const ColonyWizardScreen({super.key});

  @override
  State<ColonyWizardScreen> createState() => _ColonyWizardScreenState();
}

class _ColonyWizardScreenState extends State<ColonyWizardScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: wizardState.activeStep);
    wizardState.addListener(_onWizardStateChanged);
  }

  @override
  void dispose() {
    wizardState.removeListener(_onWizardStateChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onWizardStateChanged() {
    if (mounted) {
      setState(() {});
      // Sync page controller with wizard state
      if (_pageController.hasClients &&
          _pageController.page?.round() != wizardState.activeStep) {
        _pageController.animateToPage(
          wizardState.activeStep,
          duration: ColonyWizardConstants.stepTransitionDuration,
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _onStepTapped(int step) {
    wizardState.goToStep(step);
  }

  void _onClose() {
    context.go('/cage/grid');
  }

  void _onBack() {
    wizardState.previousStep();
  }

  void _onNext() {
    wizardState.nextStep();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeStep = wizardState.activeStep;
    final progress = wizardState.progressPercentage;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: SafeArea(
        bottom: false, // We'll handle bottom padding manually
        child: Column(
          children: [
            // Top bar
            _buildTopBar(theme, progress),

            // Progress bar
            LinearProgressIndicator(
              value: progress / 100,
              minHeight: 4,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),

            // Stepper
            WizardStepper(
              activeStep: activeStep,
              onStepTapped: _onStepTapped,
            ),

            // Step content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  if (wizardState.activeStep != index) {
                    wizardState.goToStep(index);
                  }
                },
                children: const [
                  WelcomeStep(),
                  StrainsGenotypesStep(),
                  RacksStep(),
                  CagesAnimalsStep(),
                  ReviewStep(),
                ],
              ),
            ),

            // Bottom navigation (hidden on step 0)
            if (activeStep > 0)
              _buildBottomBar(theme, activeStep, bottomPadding)
            else
              SizedBox(height: bottomPadding), // Add padding on step 0
          ],
        ),
      ),
      // Undo snackbar overlay
      bottomSheet: wizardState.lastUndoAction != null
          ? UndoSnackbarWidget(
              action: wizardState.lastUndoAction!,
              onUndo: () async {
                await wizardState.executeUndo();
              },
              onDismiss: () {
                wizardState.clearUndoStack();
              },
            )
          : null,
    );
  }

  Widget _buildTopBar(ThemeData theme, int progress) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Colony Setup Wizard',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            '$progress% Complete',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _onClose,
            tooltip: 'Exit wizard',
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme, int activeStep, double bottomPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton.icon(
            onPressed: _onBack,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
          ),
          if (activeStep < 4)
            FilledButton.icon(
              onPressed: _onNext,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Next'),
            ),
        ],
      ),
    );
  }
}
