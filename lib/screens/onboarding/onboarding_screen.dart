import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grid_view/app/router.dart';
import 'package:grid_view/config/api_config.dart';
import 'package:grid_view/models/account.dart';
import 'package:grid_view/screens/onboarding/widgets/invite_step.dart';
import 'package:grid_view/screens/onboarding/widgets/lab_step.dart';
import 'package:grid_view/screens/onboarding/widgets/migration_step.dart';
import 'package:grid_view/screens/onboarding/widgets/profile_step.dart';
import 'package:grid_view/services/account_service.dart';
import 'package:grid_view/services/auth_service.dart';
import 'package:grid_view/services/session_service.dart';

final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _activeStep = 0;
  String _labName = '';
  String _firstName = '';
  String _lastName = '';
  String _position = '';
  String _otherPosition = '';
  List<String> _emails = ['', '', ''];
  AccountDetail? _account;
  bool _loading = true;
  bool _submitting = false;

  String? _labNameError;
  String? _firstNameError;
  String? _lastNameError;

  final List<String> _stepTitles = [
    'Your Lab',
    'Tell us who you are',
    'Invite Users',
    'Get Started',
  ];

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  Future<void> _loadAccount() async {
    try {
      final accountUuid = ApiConfig.accountUuid;
      if (accountUuid != null) {
        final account = await accountService.getAccount(accountUuid);
        setState(() {
          _account = account;
          _labName = account.lab?.labName ?? sessionService.labName ?? '';
          _firstName =
              account.user.firstName ?? sessionService.firstName ?? '';
          _lastName = account.user.lastName ?? sessionService.lastName ?? '';
          _position = account.position ?? sessionService.position ?? '';
          _loading = false;
        });
      } else {
        setState(() {
          _labName = sessionService.labName ?? '';
          _firstName = sessionService.firstName ?? '';
          _lastName = sessionService.lastName ?? '';
          _position = sessionService.position ?? '';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _labName = sessionService.labName ?? '';
        _firstName = sessionService.firstName ?? '';
        _lastName = sessionService.lastName ?? '';
        _position = sessionService.position ?? '';
        _loading = false;
      });
    }
  }

  bool _validateCurrentStep() {
    setState(() {
      _labNameError = null;
      _firstNameError = null;
      _lastNameError = null;
    });

    switch (_activeStep) {
      case 0:
        final hasInvited = _account?.hasInvited ?? false;
        if (!hasInvited && _labName.trim().isEmpty) {
          setState(() => _labNameError = 'Lab name is required');
          return false;
        }
        return true;
      case 1:
        bool valid = true;
        if (_firstName.trim().isEmpty) {
          setState(() => _firstNameError = 'First name is required');
          valid = false;
        }
        if (_lastName.trim().isEmpty) {
          setState(() => _lastNameError = 'Last name is required');
          valid = false;
        }
        return valid;
      case 2:
        return true;
      case 3:
        return true;
      default:
        return true;
    }
  }

  Future<void> _onNext() async {
    if (!_validateCurrentStep()) return;

    if (_activeStep < 3) {
      setState(() => _activeStep++);
    } else {
      await _submit();
    }
  }

  void _onBack() {
    if (_activeStep > 0) {
      setState(() => _activeStep--);
    }
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final accountUuid = ApiConfig.accountUuid!;
      final hasInvited = _account?.hasInvited ?? false;

      if (!hasInvited) {
        await accountService.putLab(_labName.trim());
      }

      final effectivePosition =
          _position == 'Other' ? _otherPosition : _position;
      await accountService.putAccount(accountUuid, {
        'firstName': _firstName.trim(),
        'lastName': _lastName.trim(),
        'position': effectivePosition,
        'onboarded': true,
      });

      final validEmails = _emails
          .where((e) => e.trim().isNotEmpty && _emailRegex.hasMatch(e.trim()))
          .toList();
      for (final email in validEmails) {
        await accountService.postInviteUser(email.trim());
      }

      await sessionService.setOnboarded(true);

      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_stepTitles[_activeStep]),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
              authState.value = false;
            },
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_activeStep + 1) / 4,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildStepContent(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_activeStep > 0)
                  TextButton(
                    onPressed: _submitting ? null : _onBack,
                    child: const Text('Back'),
                  )
                else
                  const SizedBox.shrink(),
                FilledButton(
                  onPressed: _submitting ? null : _onNext,
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_activeStep == 3 ? 'Finish' : 'Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_activeStep) {
      case 0:
        return LabStep(
          labName: _labName,
          onLabNameChanged: (v) => setState(() => _labName = v),
          account: _account,
          error: _labNameError,
        );
      case 1:
        final showNameFields = _firstName.isEmpty || _lastName.isEmpty;
        return ProfileStep(
          firstName: _firstName,
          lastName: _lastName,
          position: _position,
          otherPosition: _otherPosition,
          onFirstNameChanged: (v) => setState(() => _firstName = v),
          onLastNameChanged: (v) => setState(() => _lastName = v),
          onPositionChanged: (v) => setState(() => _position = v),
          onOtherPositionChanged: (v) => setState(() => _otherPosition = v),
          showNameFields: showNameFields,
          firstNameError: _firstNameError,
          lastNameError: _lastNameError,
        );
      case 2:
        return InviteStep(
          emails: _emails,
          onEmailsChanged: (v) => setState(() => _emails = v),
        );
      case 3:
        return const MigrationStep();
      default:
        return const SizedBox.shrink();
    }
  }
}
