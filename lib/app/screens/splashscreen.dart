import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmPorcelain,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/logos/AlSewarlogo-nobg.png",
                width: 190,
                height: 190,
                errorBuilder: (_, _, _) =>
                    const SizedBox(width: 190, height: 190),
              ),
              const SizedBox(height: 16),
              Text(
                "AL SEWAR AUTO CENTER",
                style: AppTextStyles.heading.copyWith(
                  fontFamily: AppTextStyles.headingFont,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  color: AppColors.deepCharcoal,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "EXCELLENCE IN AUTOMOTIVE CARE",
                style: AppTextStyles.caption.copyWith(
                  fontFamily: AppTextStyles.bodyFont,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: AppColors.champagneGold,
                ),
              ),
              const SizedBox(height: 36),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.champagneGold,
                ),
                strokeWidth: 2.5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
