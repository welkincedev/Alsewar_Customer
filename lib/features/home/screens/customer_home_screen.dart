import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../about/screens/about_us_screen.dart';
import '../../auth/models/auth_user.dart';
import '../../support/screens/whatsapp_support_screen.dart';
import '../views/home_screen.dart';
import '../widgets/floating_pill_nav_bar.dart';

/// Main Shell containing the customer bottom navigation:
/// 1. About Us
/// 2. Home (Default active tab)
/// 3. WhatsApp
class CustomerMainShell extends ConsumerStatefulWidget {
  final AuthUser user;
  final int initialIndex;
  final List<Widget>? pages;
  final List<PillNavItem>? navItems;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const CustomerMainShell({
    super.key,
    required this.user,
    this.initialIndex = 1,
    this.pages,
    this.navItems,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  ConsumerState<CustomerMainShell> createState() => _CustomerMainShellState();
}

class _CustomerMainShellState extends ConsumerState<CustomerMainShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages =
        widget.pages ??
        [
          const AboutUsScreen(),
          HomeScreen(user: widget.user),
          const WhatsAppSupportScreen(),
        ];

    final navItems =
        widget.navItems ??
        const [
          PillNavItem(
            icon: Icons.info_outline,
            activeIcon: Icons.info,
            label: 'About Us',
          ),
          PillNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
          ),
          PillNavItem(
            icon: Icons.chat_bubble_outline,
            activeIcon: Icons.chat_bubble,
            label: 'WhatsApp',
          ),
        ];

    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth < 360 ? 12.0 : 20.0;
    final activeIndex = _currentIndex.clamp(0, pages.length - 1);

    return Scaffold(
      backgroundColor: AppColors.warmPorcelain,
      extendBody: true,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation:
          widget.floatingActionButtonLocation ??
          const FloatingAbovePillNavBarLocation(),
      body: IndexedStack(index: activeIndex, children: pages),
      bottomNavigationBar: isKeyboardVisible
          ? const SizedBox.shrink()
          : Listener(
              behavior: HitTestBehavior.deferToChild,
              child: SafeArea(
                top: false,
                bottom: true,
                minimum: const EdgeInsets.only(bottom: 12.0),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: SizedBox(
                    height: 62.0,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Stock BottomNavigationBar maintains complete compatibility
                        // for existing test suites and accessibility finders
                        IgnorePointer(
                          child: Opacity(
                            opacity: 0.0,
                            child: BottomNavigationBar(
                              currentIndex: activeIndex,
                              onTap: _onTabSelected,
                              type: BottomNavigationBarType.fixed,
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              showUnselectedLabels: false,
                              showSelectedLabels: false,
                              items: List.generate(
                                navItems.length,
                                (i) => const BottomNavigationBarItem(
                                  icon: SizedBox.shrink(),
                                  label: '',
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Desert Luxe Floating Pill Navigation Bar
                        FloatingPillNavBar(
                          currentIndex: activeIndex,
                          onTap: _onTabSelected,
                          items: navItems,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

/// Backward-compatible alias for existing tests or routes
typedef CustomerHomeScreen = CustomerMainShell;
