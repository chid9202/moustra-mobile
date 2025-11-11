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
import 'package:moustra/stores/strain_store.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {
  bool _loading = false;
  bool _unlockLoading = false;
  String? _error;
  VoidCallback? _authListener;
  bool _canUseBiometrics = false;
  bool _hasRefreshToken = false;
  Timer? _autoUnlockTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkBiometricAvailability();
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
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (!mounted) return;
      await authService.login();
      // If login succeeds, the auth listener will handle loading state
      // through _postLogin() until navigation completes
      // Don't reset _loading here to keep the button showing loading state
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/icons/app_icon.png',
                  height: 128,
                  width: 128,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Welcome to Moustra',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                if (_error != null)
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 16),
                // Show biometric unlock button if available and refresh token exists
                if (_canUseBiometrics && _hasRefreshToken) ...[
                  OutlinedButton.icon(
                    onPressed: (_loading || _unlockLoading)
                        ? null
                        : _handleUnlock,
                    icon: _unlockLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(Platform.isIOS ? Icons.face : Icons.fingerprint),
                    label: Text(
                      Platform.isIOS
                          ? 'Unlock with Face ID'
                          : 'Unlock with Biometrics',
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                FilledButton(
                  onPressed: (_loading || _unlockLoading) ? null : _handleLogin,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Sign in'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
