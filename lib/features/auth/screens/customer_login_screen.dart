import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../widgets/login_form.dart';

class CustomerLoginScreen extends StatelessWidget {
  const CustomerLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
                Image.asset(
                  'assets/logos/AlSewarlogo-nobg.png',
                  width: 140,
                  height: 140,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) =>
                      const SizedBox(width: 140, height: 140),
                ),
                // const SizedBox(height: 16),

                // Welcome Subtitle
                Text(
                  'Sign In',
                  style: AppTextStyles.bodySecondary.copyWith(
                    fontFamily: AppTextStyles.bodyFont,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Login Form Container
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppColors.cardShadow,
                    border: Border.all(color: AppColors.sandBeige, width: 1),
                  ),
                  child: const LoginForm(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
