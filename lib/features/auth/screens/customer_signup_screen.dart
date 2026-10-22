import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../widgets/signup_form.dart';

class CustomerSignupScreen extends StatelessWidget {
  const CustomerSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: AppColors.primaryBlack,
        elevation: 0,
      ),
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
                // Header Brand Logo
                Image.asset(
                  'assets/logos/AlSewarlogo-removebg.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) =>
                      const SizedBox(width: 100, height: 100),
                ),
                const SizedBox(height: 12),

                Text(
                  'Al Sewar Auto Center',
                  style: AppTextStyles.heading.copyWith(
                    fontFamily: AppTextStyles.headingFont,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepCharcoal,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),

                Text(
                  'Sign up for customer loyalty rewards',
                  style: AppTextStyles.bodySecondary.copyWith(
                    fontFamily: AppTextStyles.bodyFont,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Form Container
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppColors.cardShadow,
                    border: Border.all(color: AppColors.sandBeige, width: 1),
                  ),
                  child: SignupForm(
                    onSuccess: () {
                      Navigator.pop(
                        context,
                        'Registration successful! Please sign in with your credentials.',
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Link to Login Screen
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTextStyles.bodySecondary,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Sign In',
                        style: AppTextStyles.bodyPrimary.copyWith(
                          color: AppColors.primaryBlack,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
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
    );
  }
}
