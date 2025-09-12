import 'package:flutter/material.dart';
import 'package:moustra/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/app/router.dart';
import 'package:moustra/services/profile_service.dart';
import 'package:moustra/services/dtos/profile_dto.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {
  bool _loading = false;
  String? _error;
  VoidCallback? _authListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authListener = () {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
      if (authService.isLoggedIn) {
        final req = ProfileRequestDto(
          email: authService.user?.email ?? '',
          firstName: authService.user?.givenName ?? '',
          lastName: authService.user?.familyName ?? '',
        );
        profileService
            .getProfile(req)
            .then((profile) {
              profileState.value = profile;
              context.go('/dashboard');
            })
            .catchError((_) {});
      }
    };
    authState.addListener(_authListener!);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_authListener != null) {
      authState.removeListener(_authListener!);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await authService.init();
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _handleLogin() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await authService.login();
      if (!mounted) return;
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
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
                const Text(
                  'Use Auth0 hosted login to sign in.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (_error != null)
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _loading ? null : _handleLogin,
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
