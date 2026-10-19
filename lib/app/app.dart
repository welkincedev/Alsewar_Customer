import 'package:carwashapp/features/home/screens/customer_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/screens/customer_login_screen.dart';
import '../features/auth/viewmodels/auth_viewmodel.dart';
import 'screens/splashscreen.dart';
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
    );
  }
}
