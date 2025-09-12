import 'package:flutter/material.dart';
import 'package:moustra/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:moustra/app/router.dart';

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
      print('login_screen_initState 111 ------>');
      if (!mounted) return;
      print('login_screen_initState 222 ------>');
      // Stop spinner on any auth state change
      setState(() {
        _loading = false;
      });
      print('login_screen_initState 333 ------> ${authService.isLoggedIn}');
      if (authService.isLoggedIn) context.go('/dashboard');
    };
    authState.addListener(_authListener!);

    // If already authenticated (e.g., after deep link resume), navigate immediately
    print('login_screen_initState 555 ------> ${authService.isLoggedIn}');
    // if (authService.isLoggedIn) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     if (!mounted) return;
    //     print('login_screen_initState 666 ------>');
    //     context.go('/dashboard');
    //   });
    // }
  }

  @override
  void dispose() {
    print('login_screen_dispose 111 ------>');
    WidgetsBinding.instance.removeObserver(this);
    if (_authListener != null) {
      print('login_screen_dispose 222 ------>');
      authState.removeListener(_authListener!);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      print('login_screen_didChangeAppLifecycleState 111 ------>');
      await authService.init();
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
      print(
        'login_screen_didChangeAppLifecycleState 333 ------> ${authService.isLoggedIn}',
      );
      if (authService.isLoggedIn) context.go('/dashboard');
    }
  }

  Future<void> _handleLogin() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final creds = await authService.login();
      if (!mounted) return;
      if ((creds?.accessToken ?? '').isNotEmpty) {
        context.go('/dashboard');
      }
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
