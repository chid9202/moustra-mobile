import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _loading = false;
  String? _error;
  VoidCallback? _authListener;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
        _postLogin(req);
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
    // Dispose autofill context to ensure credentials are saved
    TextInput.finishAutofillContext();
    WidgetsBinding.instance.removeObserver(this);
    if (_authListener != null) {
      authState.removeListener(_authListener!);
    }
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _postLogin(ProfileRequestDto request) {
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
            // Give time to process the autofill save request before navigating
            await Future.delayed(const Duration(milliseconds: 300));
            if (mounted) {
              // Reset loading before navigation
              setState(() {
                _loading = false;
              });
              context.go('/dashboard');
            }
          }
        });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await authService.init();
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
        _postLogin(req);
      }
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _handleLogin() async {
    // Validate form first
    if (!_formKey.currentState!.validate()) {
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
      await authService.loginWithPassword(email, password);
      // Notify the system to save credentials for autofill
      TextInput.finishAutofillContext(shouldSave: true);
      // If login succeeds, the auth listener will handle loading state
      // through _postLogin() until navigation completes
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        // Clean up the error message
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring(11);
        }
        setState(() {
          _error = errorMessage;
          _loading = false;
        });
      }
      return; // Don't save credentials if login failed
    }
  }

  Future<void> _handleSocialLogin(String connection) async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (!mounted) return;
      await authService.loginWithSocial(connection);
      // If login succeeds, the auth listener will handle loading state
      // through _postLogin() until navigation completes
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        // Clean up the error message
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
    // Allow + in email (for aliasing) and domains without TLD (for local/internal domains)
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
                          'Welcome to Moustra',
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
                          'Sign in to continue',
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
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: colorScheme.onErrorContainer,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: TextStyle(
                                      color: colorScheme.onErrorContainer,
                                      fontSize: 14,
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
                          autofillHints: const [AutofillHints.password],
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
                          onFieldSubmitted: (_) => _handleLogin(),
                        ),
                        const SizedBox(height: 24),

                        // Sign in button
                        FilledButton(
                          onPressed: _loading ? null : _handleLogin,
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
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),

                        // Divider with "or"
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: colorScheme.outlineVariant,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: colorScheme.outlineVariant,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Google Sign In button
                        _SocialLoginButton(
                          onPressed: _loading
                              ? null
                              : () => _handleSocialLogin('google-oauth2'),
                          label: 'Continue with Google',
                          icon: _GoogleIcon(),
                          colorScheme: colorScheme,
                        ),
                        const SizedBox(height: 12),

                        // Microsoft Sign In button
                        _SocialLoginButton(
                          onPressed: _loading
                              ? null
                              : () => _handleSocialLogin('windowslive'),
                          label: 'Continue with Microsoft',
                          icon: _MicrosoftIcon(),
                          colorScheme: colorScheme,
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

/// Custom social login button widget
class _SocialLoginButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final Widget icon;
  final ColorScheme colorScheme;

  const _SocialLoginButton({
    required this.onPressed,
    required this.label,
    required this.icon,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: colorScheme.outline, width: 1),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 20, height: 20, child: icon),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Google logo widget
class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset('assets/icons/google.svg', width: 20, height: 20);
  }
}

/// Microsoft logo widget (4 colored squares)
class _MicrosoftIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.zero,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Container(color: const Color(0xFFF25022)), // Red
          Container(color: const Color(0xFF7FBA00)), // Green
          Container(color: const Color(0xFF00A4EF)), // Blue
          Container(color: const Color(0xFFFFB900)), // Yellow
        ],
      ),
    );
  }
}
