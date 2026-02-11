import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../state/wizard_state.dart';

class WelcomeStep extends StatefulWidget {
  const WelcomeStep({super.key});

  @override
  State<WelcomeStep> createState() => _WelcomeStepState();
}

class _WelcomeStepState extends State<WelcomeStep> {
  final _cageCountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (wizardState.totalExpectedCages > 0) {
      _cageCountController.text = wizardState.totalExpectedCages.toString();
    }
  }

  @override
  void dispose() {
    _cageCountController.dispose();
    super.dispose();
  }

  void _onSkip() {
    context.go('/dashboard');
  }

  void _onGetStarted() {
    final count = int.tryParse(_cageCountController.text) ?? 0;
    wizardState.setTotalExpectedCages(count);
    wizardState.nextStep();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 600;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 32),

              // Science icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.science_outlined,
                  size: 40,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Welcome to the Colony Wizard',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                'Set up your colony in 3 easy steps. Add strains, organize racks, and populate cages with animals.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Preview cards
              _buildPreviewCards(theme, isWide),
              const SizedBox(height: 32),

              // Cage count input
              _buildCageCountInput(theme),
              const SizedBox(height: 32),

              // Action buttons
              _buildActionButtons(theme),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCards(ThemeData theme, bool isWide) {
    final cards = [
      _PreviewCardData(
        icon: Icons.pets,
        title: 'Strains & Genes',
        description: 'Add mouse strains and genotypes',
      ),
      _PreviewCardData(
        icon: Icons.grid_on,
        title: 'Racks & Cages',
        description: 'Organize racks and add cages with animals',
      ),
      _PreviewCardData(
        icon: Icons.check_circle_outline,
        title: 'Review & Finish',
        description: 'Review your setup and go to dashboard',
      ),
    ];

    if (isWide) {
      return Row(
        children: cards
            .map((card) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: _buildPreviewCard(theme, card),
                  ),
                ))
            .toList(),
      );
    }

    return Column(
      children: cards
          .map((card) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildPreviewCard(theme, card),
              ))
          .toList(),
    );
  }

  Widget _buildPreviewCard(ThemeData theme, _PreviewCardData data) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              data.icon,
              size: 32,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              data.title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              data.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCageCountInput(ThemeData theme) {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: _cageCountController,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: const InputDecoration(
          labelText: 'How many cages do you have?',
          hintText: 'Enter a number',
          border: OutlineInputBorder(),
          helperText: 'Used to track your setup progress',
        ),
        onChanged: (value) {
          final count = int.tryParse(value) ?? 0;
          wizardState.setTotalExpectedCages(count);
        },
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: _onSkip,
          child: const Text('Skip for now'),
        ),
        const SizedBox(width: 16),
        FilledButton.icon(
          onPressed: _onGetStarted,
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Get Started'),
        ),
      ],
    );
  }
}

class _PreviewCardData {
  final IconData icon;
  final String title;
  final String description;

  _PreviewCardData({
    required this.icon,
    required this.title,
    required this.description,
  });
}
