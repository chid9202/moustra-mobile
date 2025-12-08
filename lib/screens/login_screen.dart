import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:moustra/services/auth_service.dart';
import 'package:moustra/services/secure_store.dart';
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
  bool _unlockLoading = false;
  String? _error;
  VoidCallback? _authListener;
  bool _canUseBiometrics = false;
  bool _hasRefreshToken = false;
  Timer? _autoUnlockTimer;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkBiometricAvailability();
    _loadSavedCredentials();
    // Attempt automatic biometric unlock on login screen load if available
    _attemptAutoUnlock();
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
    _autoUnlockTimer?.cancel();
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
        .then((_) {
          if (mounted) {
            // Reset loading before navigation
            setState(() {
              _loading = false;
            });
            context.go('/dashboard');
          }
        });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await authService.init();
      await _checkBiometricAvailability();
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

  Future<void> _checkBiometricAvailability() async {
    final canUse = await authService.canUseBiometrics();
    final hasRefresh = await SecureStore.hasRefreshToken();
    if (mounted) {
      setState(() {
        _canUseBiometrics = canUse;
        _hasRefreshToken = hasRefresh;
      });
    }
  }

  /// Load saved credentials from secure storage
  Future<void> _loadSavedCredentials() async {
    final savedEmail = await SecureStore.getSavedEmail();
    final savedPassword = await SecureStore.getSavedPassword();
    if (mounted) {
      setState(() {
        if (savedEmail != null && savedEmail.isNotEmpty) {
          _emailController.text = savedEmail;
        }
        if (savedPassword != null && savedPassword.isNotEmpty) {
          _passwordController.text = savedPassword;
        }
      });
    }
  }

  /// Attempt automatic biometric unlock when login screen loads
  /// Only attempts if biometrics are available and refresh token exists
  Future<void> _attemptAutoUnlock() async {
    // Use post-frame callback to ensure widget is fully rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Wait a brief moment for any animations to complete
      _autoUnlockTimer = Timer(const Duration(milliseconds: 800), () async {
        if (!mounted) return;

        final canUse = await authService.canUseBiometrics();
        final hasRefresh = await SecureStore.hasRefreshToken();
        final isLoggedIn = authService.isLoggedIn;

        if (!mounted) return;

        if (canUse && hasRefresh && !isLoggedIn) {
          // Attempt automatic unlock
          await authService.unlockWithBiometrics();
          // If unlock succeeds, the auth listener will handle navigation
        }
      });
    });
  }

  Future<void> _handleUnlock() async {
    if (!mounted) return;
    setState(() {
      _unlockLoading = true;
      _error = null;
    });
    try {
      if (!mounted) return;
      final creds = await authService.unlockWithBiometrics();
      if (creds == null) {
        // User cancelled or biometric failed - don't show error
        if (mounted) {
          setState(() {
            _unlockLoading = false;
          });
        }
        return;
      }
      // If unlock succeeds, the auth listener will handle loading state
      // through _postLogin() until navigation completes
      // Don't reset _unlockLoading here to keep the button showing loading state
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Biometric unlock failed: ${e.toString()}';
          _unlockLoading = false;
        });
      }
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

    // Save credentials after successful login (separate try-catch so storage
    // failures don't block the login flow)
    try {
      await SecureStore.saveLoginCredentials(email, password);
    } catch (e) {
      // Silently fail - credential saving is a convenience feature,
      // not critical to the login flow
      print('[LoginScreen] Failed to save credentials: $e');
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
                        enabled: !_loading && !_unlockLoading,
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
                        enabled: !_loading && !_unlockLoading,
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
                        onPressed: (_loading || _unlockLoading)
                            ? null
                            : _handleLogin,
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

                      // Biometric unlock section
                      if (_canUseBiometrics && _hasRefreshToken) ...[
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(color: colorScheme.outlineVariant),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'or',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: colorScheme.outlineVariant),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        OutlinedButton.icon(
                          onPressed: (_loading || _unlockLoading)
                              ? null
                              : _handleUnlock,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: colorScheme.outline),
                          ),
                          icon: _unlockLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colorScheme.primary,
                                  ),
                                )
                              : Icon(
                                  Platform.isIOS
                                      ? Icons.face
                                      : Icons.fingerprint,
                                  size: 24,
                                ),
                          label: Text(
                            Platform.isIOS
                                ? 'Unlock with Face ID'
                                : 'Unlock with Biometrics',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
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
