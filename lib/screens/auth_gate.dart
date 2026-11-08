import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'splash_screen.dart';
import 'welcome_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _splashFinished = false;
  bool _sessionLoaded = false;
  bool _showLogin = false;
  bool _showSignup = false;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    await context.read<AuthProvider>().loadSession();

    if (!mounted) return;

    setState(() {
      _sessionLoaded = true;
    });
  }

  void _finishSplash() {
    setState(() {
      _splashFinished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!_splashFinished || !_sessionLoaded) {
          return SplashScreen(onFinished: _finishSplash);
        }

        if (authProvider.isLoggedIn) {
          return const HomeScreen();
        }

        if (_showSignup) {
          return SignupScreen(
            onLogin: () {
              setState(() {
                _showSignup = false;
                _showLogin = true;
              });
            },
            onSignupSuccess: () {
              setState(() {
                _showSignup = false;
                _showLogin = true;
              });
            },
          );
        }

        if (_showLogin) {
          return LoginScreen(
            onSignup: () {
              setState(() {
                _showLogin = false;
                _showSignup = true;
              });
            },
            onLoginSuccess: () {
              setState(() {
                _showLogin = false;
              });
            },
          );
        }

        return WelcomeScreen(
          onGetStarted: () {
            setState(() {
              _showSignup = true;
            });
          },
          onLogin: () {
            setState(() {
              _showLogin = true;
            });
          },
        );
      },
    );
  }
}
