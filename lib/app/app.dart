import 'package:carwashapp/features/home/screens/customer_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dev/preview/preview_config.dart';
import '../features/auth/screens/customer_login_screen.dart';
import '../features/auth/viewmodels/auth_viewmodel.dart';
import 'screens/splashscreen.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

class CarWashApp extends ConsumerWidget {
  const CarWashApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsyncState = ref.watch(authViewModelProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Al Sewar Carwash',
      theme: AppTheme.lightTheme,
      home: authAsyncState.when(
        data: (authState) {
          if (authState.isAuthenticated && authState.user != null) {
            return CustomerMainShell(user: authState.user!);
          } else {
            return const CustomerLoginScreen();
          }
        },
        loading: () => const SplashScreen(),
        error: (err, stackTrace) => const CustomerLoginScreen(),
      ),
      builder: (context, child) {
        if (PreviewConfig.isPreviewEnabled && child != null) {
          return Banner(
            message: 'PREVIEW',
            location: BannerLocation.topStart,
            color: AppColors.champagneGold,
            textStyle: const TextStyle(
              color: AppColors.deepCharcoal,
              fontSize: 9.0,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
            child: child,
          );
        }
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
