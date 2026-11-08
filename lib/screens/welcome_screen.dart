import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onLogin;

  const WelcomeScreen({
    super.key,
    required this.onGetStarted,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(),

              // Banking illustration
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 20,
                      right: 25,
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: AppColors.secondary.withValues(
                          alpha: 0.15,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 25,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_balance_rounded,
                          color: Colors.white,
                          size: 85,
                        ),
                        SizedBox(height: 18),
                        Text(
                          'Your Money, Your Control',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 42),

              const Text(
                'Welcome to NovaBank',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                'Manage your money, make secure transfers, '
                'and stay in control of your finances — all in one place.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),

              const Spacer(),

              // Get Started button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: onGetStarted,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Login button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: onLogin,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'I Already Have an Account',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'SECURE  •  SIMPLE  •  SMART',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
