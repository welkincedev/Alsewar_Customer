import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../about/screens/about_us_screen.dart';
import '../../auth/models/auth_user.dart';
import '../../support/screens/whatsapp_support_screen.dart';
import '../views/home_screen.dart';

/// Main Shell containing the 3-item customer bottom navigation:
/// 1. About Us
/// 2. Home (Default active tab)
/// 3. WhatsApp
class CustomerMainShell extends ConsumerStatefulWidget {
  final AuthUser user;
  const CustomerMainShell({super.key, required this.user});

  @override
  ConsumerState<CustomerMainShell> createState() => _CustomerMainShellState();
}

class _CustomerMainShellState extends ConsumerState<CustomerMainShell> {
  // Start on Home tab (index 1) by default
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const AboutUsScreen(),
      HomeScreen(user: widget.user),
      const WhatsAppSupportScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.borderLight, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            FocusManager.instance.primaryFocus?.unfocus();
            setState(() => _currentIndex = index);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.secondaryGold,
          unselectedItemColor: AppColors.textLight,
          showUnselectedLabels: false,
          showSelectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          elevation: 8,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.info_outline),
              activeIcon: Icon(Icons.info),
              label: 'About Us',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'WhatsApp',
            ),
          ],
        ),
      ),
    );
  }
}

/// Backward-compatible alias for existing tests or routes
typedef CustomerHomeScreen = CustomerMainShell;
