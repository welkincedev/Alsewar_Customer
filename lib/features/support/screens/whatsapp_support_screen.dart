import 'package:flutter/material.dart';

import '../../branches/screens/branch_map_screen.dart';

/// Screen rendered for the WhatsApp navigation tab, now hosting the interactive
/// Google Map screen with active branches, coordinate validation, bottom sheet details,
/// and direct WhatsApp chat actions.
class WhatsAppSupportScreen extends StatelessWidget {
  const WhatsAppSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BranchMapScreen();
  }
}
