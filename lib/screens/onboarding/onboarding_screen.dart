import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/screens/onboarding/onboarding_api.dart';
import 'package:moustra/services/dtos/profile_dto.dart';
import 'package:moustra/stores/profile_store.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  bool _submitting = false;

  // Step 0 — Lab
  final _labNameController = TextEditingController();
  bool _isInvitedUser = false;

  // Step 1 — Position
  String? _selectedPosition;
  final _otherPositionController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  // Step 2 — Invites
  final _invite1Controller = TextEditingController();
  final _invite2Controller = TextEditingController();
  final _invite3Controller = TextEditingController();

  // Step 3 — Migration
  String? _selectedMigration;

  static const _positions = [
    'Principal Investigator',
    'Professor',
    'Lab Manager',
    'Scientist',
    'Technician',
    'Student',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final profile = profileState.value;
    if (profile != null) {
      // If user was invited (lab already has a name), mark as invited
      if (profile.labName.isNotEmpty) {
        _isInvitedUser = true;
        _labNameController.text = profile.labName;
      }
      // Pre-fill name fields
      if (profile.firstName.isNotEmpty) {
        _firstNameController.text = profile.firstName;
      }
      if (profile.lastName.isNotEmpty) {
        _lastNameController.text = profile.lastName;
      }
      if (profile.position != null && profile.position!.isNotEmpty) {
        if (_positions.contains(profile.position)) {
          _selectedPosition = profile.position;
        } else {
          _selectedPosition = 'Other';
          _otherPositionController.text = profile.position!;
        }
      }
    }
  }

  @override
  void dispose() {
    _labNameController.dispose();
    _otherPositionController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _invite1Controller.dispose();
    _invite2Controller.dispose();
    _invite3Controller.dispose();
    super.dispose();
  }

  String get _effectivePosition {
    if (_selectedPosition == 'Other') {
      return _otherPositionController.text.trim();
    }
    return _selectedPosition ?? '';
  }

  Future<void> _onComplete() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    try {
      final profile = profileState.value!;

      // PUT lab name (only if user set it, not for invited users)
      if (!_isInvitedUser && _labNameController.text.trim().isNotEmpty) {
        await onboardingApi.putLabName(_labNameController.text.trim());
      }

      // PUT account onboarded
      await onboardingApi.putAccountOnboarded(
        profile.accountUuid,
        position: _effectivePosition,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );

      // POST invites
      for (final controller in [
        _invite1Controller,
        _invite2Controller,
        _invite3Controller,
      ]) {
        final email = controller.text.trim();
        if (email.isNotEmpty) {
          await onboardingApi.inviteUser(email);
        }
      }

      // Update local profile state
      profileState.value = ProfileResponseDto(
        accountUuid: profile.accountUuid,
        firstName: _firstNameController.text.trim().isNotEmpty
            ? _firstNameController.text.trim()
            : profile.firstName,
        lastName: _lastNameController.text.trim().isNotEmpty
            ? _lastNameController.text.trim()
            : profile.lastName,
        email: profile.email,
        labName: _isInvitedUser
            ? profile.labName
            : (_labNameController.text.trim().isNotEmpty
                ? _labNameController.text.trim()
                : profile.labName),
        labUuid: profile.labUuid,
        onboarded: true,
        onboardedDate: DateTime.now(),
        position: _effectivePosition.isNotEmpty
            ? _effectivePosition
            : profile.position,
        role: profile.role,
        plan: profile.plan,
      );

      if (!mounted) return;

      // Navigate based on migration choice
      switch (_selectedMigration) {
        case 'colony-wizard':
          context.go('/colony-wizard');
          break;
        case 'demo-data':
          await onboardingApi.postSampleData();
          if (mounted) context.go('/cage/grid');
          break;
        case 'scratch':
        case 'excel':
        default:
          context.go('/cage/grid');
          break;
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error completing setup: $e')),
        );
      }
    }
  }

  void _next() {
    // Validate current step
    if (_currentStep == 0 && !_isInvitedUser) {
      if (_labNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a lab name')),
        );
        return;
      }
    }

    if (_currentStep == 3) {
      if (_selectedMigration == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a migration method')),
        );
        return;
      }
      _onComplete();
      return;
    }

    setState(() => _currentStep++);
  }

  void _back() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: _submitting
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Step indicator
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Row(
                      children: List.generate(4, (index) {
                        final isActive = index == _currentStep;
                        final isCompleted = index < _currentStep;
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            height: 4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: isActive || isCompleted
                                  ? colorScheme.primary
                                  : colorScheme.surfaceContainerHighest,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Step label
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Step ${_currentStep + 1} of 4',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: _buildStep(),
                    ),
                  ),
                  // Navigation buttons
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Row(
                      children: [
                        if (_currentStep > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _back,
                              child: const Text('Back'),
                            ),
                          ),
                        if (_currentStep > 0) const SizedBox(width: 12),
                        Expanded(
                          flex: _currentStep > 0 ? 2 : 1,
                          child: FilledButton(
                            onPressed: _next,
                            child: Text(
                              _currentStep == 3 ? 'Get Started' : 'Next',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_currentStep) {
      case 0:
        return _buildLabStep();
      case 1:
        return _buildPositionStep();
      case 2:
        return _buildInviteStep();
      case 3:
        return _buildMigrationStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildLabStep() {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Your Lab',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (_isInvitedUser) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.group, color: colorScheme.onPrimaryContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "You're invited to join ${_labNameController.text}",
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Text(
            'Give your lab a name to get started.',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _labNameController,
            decoration: const InputDecoration(
              labelText: 'Lab Name',
              hintText: 'e.g. Smith Lab',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
          ),
        ],
      ],
    );
  }

  Widget _buildPositionStep() {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Tell us who you are',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'This helps us personalize your experience.',
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        DropdownButtonFormField<String>(
          initialValue: _selectedPosition,
          decoration: const InputDecoration(
            labelText: 'Position',
            border: OutlineInputBorder(),
          ),
          items: _positions
              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
              .toList(),
          onChanged: (value) => setState(() => _selectedPosition = value),
        ),
        if (_selectedPosition == 'Other') ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _otherPositionController,
            decoration: const InputDecoration(
              labelText: 'Your Position',
              hintText: 'Enter your position',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
        ],
        const SizedBox(height: 16),
        TextFormField(
          controller: _firstNameController,
          decoration: const InputDecoration(
            labelText: 'First Name',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _lastNameController,
          decoration: const InputDecoration(
            labelText: 'Last Name',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  Widget _buildInviteStep() {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Invite Users',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Invite your teammates to collaborate. You can skip this and invite them later.',
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _invite1Controller,
          decoration: const InputDecoration(
            labelText: 'Email 1',
            hintText: 'colleague@university.edu',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _invite2Controller,
          decoration: const InputDecoration(
            labelText: 'Email 2',
            hintText: 'colleague@university.edu',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _invite3Controller,
          decoration: const InputDecoration(
            labelText: 'Email 3',
            hintText: 'colleague@university.edu',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  Widget _buildMigrationStep() {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Select Migration Method',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'How would you like to set up your colony?',
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        _MigrationCard(
          title: 'Colony Wizard',
          subtitle: 'Step-by-step guided setup for your colony',
          icon: Icons.auto_fix_high,
          isRecommended: true,
          isSelected: _selectedMigration == 'colony-wizard',
          onTap: () => setState(() => _selectedMigration = 'colony-wizard'),
        ),
        const SizedBox(height: 12),
        _MigrationCard(
          title: 'Explore with Demo Data',
          subtitle: 'Try Moustra with sample data to see how it works',
          icon: Icons.science_outlined,
          isSelected: _selectedMigration == 'demo-data',
          onTap: () => setState(() => _selectedMigration = 'demo-data'),
        ),
        const SizedBox(height: 12),
        _MigrationCard(
          title: 'Start from scratch',
          subtitle: 'Begin with an empty colony and add your own data',
          icon: Icons.add_circle_outline,
          isSelected: _selectedMigration == 'scratch',
          onTap: () => setState(() => _selectedMigration = 'scratch'),
        ),
        const SizedBox(height: 12),
        _MigrationCard(
          title: 'Migrate from Excel',
          subtitle: 'Import your existing data from a spreadsheet',
          icon: Icons.table_chart_outlined,
          isSelected: _selectedMigration == 'excel',
          onTap: () => setState(() => _selectedMigration = 'excel'),
        ),
      ],
    );
  }
}

class _MigrationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isRecommended;
  final bool isSelected;
  final VoidCallback onTap;

  const _MigrationCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.isRecommended = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: title,
      button: true,
      selected: isSelected,
      child: Card(
      elevation: isSelected ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? colorScheme.primary
              : isRecommended
                  ? colorScheme.primary.withValues(alpha: 0.5)
                  : colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      color: isSelected
          ? colorScheme.primaryContainer.withValues(alpha: 0.3)
          : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected || isRecommended
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isRecommended) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Recommended',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: colorScheme.primary),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
