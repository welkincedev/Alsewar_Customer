import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/logos/AlSewarlogo-nobg.png",
                width: 180,
                height: 180,
                errorBuilder: (_, _, _) =>
                    const SizedBox(width: 180, height: 180),
              ),

              // const SizedBox(height: 24),
              // Text(
              //   "Al Sewar Carwash",
              //   style: AppTextStyles.title.copyWith(
              //     fontWeight: FontWeight.bold,
              //     fontSize: 22,
              //   ),
              // ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryBlack,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
