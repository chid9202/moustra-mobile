import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moustra/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/services/clients/profile_api.dart';
import 'package:moustra/services/dtos/profile_dto.dart';
import 'package:moustra/stores/account_store.dart';
import 'package:moustra/stores/allele_store.dart';
import 'package:moustra/stores/animal_store.dart';
import 'package:moustra/stores/auth_store.dart';
import 'package:moustra/stores/background_store.dart';
import 'package:moustra/stores/cage_store.dart';
import 'package:moustra/stores/gene_store.dart';
import 'package:moustra/stores/profile_store.dart';
import 'package:moustra/stores/rack_store.dart';
import 'package:moustra/stores/setting_store.dart';
import 'package:moustra/stores/strain_store.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _loading = false;
  String? _error;
  VoidCallback? _authListener;
  bool _obscurePassword = true;

  // Password policy state
  bool _hasMinLength = false;
  bool _hasLowerCase = false;
  bool _hasUpperCase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  int get _characterTypesCount {
    int count = 0;
    if (_hasLowerCase) count++;
    if (_hasUpperCase) count++;
    if (_hasNumber) count++;
    if (_hasSpecialChar) count++;
    return count;
  }

  bool get _hasEnoughCharacterTypes => _characterTypesCount >= 3;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePasswordPolicy);
    _authListener = () {
      if (!mounted) return;
      if (authService.isLoggedIn) {
        setState(() {
          _loading = true;
        });
        final req = ProfileRequestDto(
          email: authService.user?.email ?? '',
          firstName: authService.user?.givenName ?? '',
          lastName: authService.user?.familyName ?? '',
        );
        _postSignup(req);
      } else {
        setState(() {
          _loading = false;
        });
      }
    };
    authState.addListener(_authListener!);
  }

  @override
  void dispose() {
    TextInput.finishAutofillContext();
    _passwordController.removeListener(_validatePasswordPolicy);
    if (_authListener != null) {
      authState.removeListener(_authListener!);
    }
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _validatePasswordPolicy() {
    final password = _passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasLowerCase = password.contains(RegExp(r'[a-z]'));
      _hasUpperCase = password.contains(RegExp(r'[A-Z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  void _postSignup(ProfileRequestDto request) {
    profileService
        .getProfile(request)
        .then((profile) {
          profileState.value = profile;
          // Initialize all stores in parallel without awaiting
          useAccountStore();
          useAnimalStore();
          useCageStore();
          useStrainStore();
          useGeneStore();
          useAlleleStore();
          useRackStore();
          useBackgroundStore();
          useSettingStore();
        })
        .catchError((e) {
          print(e);
          if (mounted) {
            setState(() {
              _loading = false;
              _error = 'Failed to load profile: $e';
            });
          }
        })
        .then((_) async {
          if (mounted) {
            await Future.delayed(const Duration(milliseconds: 300));
            if (mounted) {
              setState(() {
                _loading = false;
              });
              context.go('/dashboard');
            }
          }
        });
  }

  Future<void> _handleSignup() async {
    // Validate form first
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check password policy
    if (!_hasMinLength || !_hasEnoughCharacterTypes) {
      setState(() {
        _error = 'Please meet all password requirements';
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      if (!mounted) return;
      await authService.signUpWithPassword(email, password);
      // Notify the system to save credentials for autofill
      TextInput.finishAutofillContext(shouldSave: true);
      // If signup succeeds, the auth listener will handle loading state
      // through _postSignup() until navigation completes
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        // Clean up the error message
        print(errorMessage);
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring(11);
        }
        setState(() {
          _error = errorMessage;
          _loading = false;
        });
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: AutofillGroup(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo
                        Image.asset(
                          'assets/icons/app_icon.png',
                          height: 100,
                          width: 100,
                        ),
                        const SizedBox(height: 24),

                        // Title
                        Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),

                        // Subtitle
                        Text(
                          'Sign up to get started',
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Error message
                        if (_error != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Icon(
                                    Icons.error_outline,
                                    color: colorScheme.onErrorContainer,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: TextStyle(
                                      color: colorScheme.onErrorContainer,
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Email field
                        TextFormField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autocorrect: false,
                          enabled: !_loading,
                          autofillHints: const [AutofillHints.email],
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter your email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.3),
                          ),
                          validator: _validateEmail,
                          onFieldSubmitted: (_) {
                            _passwordFocusNode.requestFocus();
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          enabled: !_loading,
                          autofillHints: const [AutofillHints.newPassword],
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.3),
                          ),
                          validator: _validatePassword,
                          onFieldSubmitted: (_) => _handleSignup(),
                        ),
                        const SizedBox(height: 12),

                        // Password Policy Widget
                        _PasswordPolicyWidget(
                          hasMinLength: _hasMinLength,
                          hasLowerCase: _hasLowerCase,
                          hasUpperCase: _hasUpperCase,
                          hasNumber: _hasNumber,
                          hasSpecialChar: _hasSpecialChar,
                          hasEnoughCharacterTypes: _hasEnoughCharacterTypes,
                        ),
                        const SizedBox(height: 24),

                        // Sign up button
                        FilledButton(
                          onPressed: _loading ? null : _handleSignup,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 24),

                        // Link to login
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: _loading
                                  ? null
                                  : () => context.go('/login'),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Log in',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Password policy validation widget
class _PasswordPolicyWidget extends StatelessWidget {
  final bool hasMinLength;
  final bool hasLowerCase;
  final bool hasUpperCase;
  final bool hasNumber;
  final bool hasSpecialChar;
  final bool hasEnoughCharacterTypes;

  const _PasswordPolicyWidget({
    required this.hasMinLength,
    required this.hasLowerCase,
    required this.hasUpperCase,
    required this.hasNumber,
    required this.hasSpecialChar,
    required this.hasEnoughCharacterTypes,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your password must contain:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _PolicyItem(text: 'At least 8 characters', isValid: hasMinLength),
          const SizedBox(height: 8),
          _PolicyItem(
            text: 'At least 3 of the following:',
            isValid: hasEnoughCharacterTypes,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Column(
              children: [
                const SizedBox(height: 4),
                _PolicyItem(
                  text: 'Lower case letters (a-z)',
                  isValid: hasLowerCase,
                ),
                const SizedBox(height: 4),
                _PolicyItem(
                  text: 'Upper case letters (A-Z)',
                  isValid: hasUpperCase,
                ),
                const SizedBox(height: 4),
                _PolicyItem(text: 'Numbers (0-9)', isValid: hasNumber),
                const SizedBox(height: 4),
                _PolicyItem(
                  text: 'Special characters (e.g. !@#\$%^&*)',
                  isValid: hasSpecialChar,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual policy item with checkmark or bullet
class _PolicyItem extends StatelessWidget {
  final String text;
  final bool isValid;

  const _PolicyItem({required this.text, required this.isValid});

  @override
  Widget build(BuildContext context) {
    final validColor = Colors.green.shade600;
    final invalidColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      children: [
        if (isValid)
          Icon(Icons.check, size: 18, color: validColor)
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: invalidColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isValid ? validColor : invalidColor,
            ),
          ),
        ),
      ],
    );
  }
}
