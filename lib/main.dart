import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'dev/preview/preview_config.dart';
import 'dev/preview/preview_providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      overrides: PreviewConfig.isPreviewEnabled ? previewOverrides : const [],
      child: const CarWashApp(),
    ),
  );
}
