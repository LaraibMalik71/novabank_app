import 'dart:async';

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const SplashScreen({super.key, required this.onFinished});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    _timer = Timer(const Duration(seconds: 6), () {
      if (mounted) {
        widget.onFinished();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF142B4A),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF13B8A6),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(
                    Icons.account_balance_rounded,
                    color: Colors.white,
                    size: 55,
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'NovaBank',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Banking made simpler.',
                  style: TextStyle(
                    color: Color(0xFFB9D2DD),
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 50),

                const SizedBox(
                  height: 3,
                  width: 45,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xFF13B8A6),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                const Text(
                  'SECURE  •  SIMPLE  •  SMART',
                  style: TextStyle(
                    color: Color(0xFFB9D2DD),
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
