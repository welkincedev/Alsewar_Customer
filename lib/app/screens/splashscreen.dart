import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

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
