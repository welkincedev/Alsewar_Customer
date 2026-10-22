/// Development-only configuration for UI preview mode.
///
/// When [isPreviewEnabled] is `true`:
/// - The app runs completely offline without requiring a live backend server.
/// - Isolated sample mock data is injected into Riverpod providers.
/// - Developers can preview and refine all UI screens, theme colors, typography,
///   animations, and layouts.
///
/// When [isPreviewEnabled] is `false`:
/// - The app connects to the real backend APIs via existing production services.
/// - Zero mock data is loaded into Riverpod providers.
///
/// How to toggle preview mode:
/// 1. In code: set [manualOverride] to `false` or call [PreviewConfig.disable()]
/// 2. Via CLI flag: `flutter run --dart-define=PREVIEW_MODE=true` (or `false`)
class PreviewConfig {
  /// CLI environment flag: pass `--dart-define=PREVIEW_MODE=true|false`
  static const bool _fromEnvironment = bool.fromEnvironment(
    'PREVIEW_MODE',
    defaultValue: false,
  );

  /// Manual development toggle. Set to `true` to enable preview mode while
  /// the backend server is offline; set to `false` when connecting to live backend.
  static bool manualOverride = false;

  /// Effective preview mode flag.
  static bool get isPreviewEnabled => _fromEnvironment || manualOverride;

  /// Convenience helper to enable preview mode programmatically.
  static void enable() => manualOverride = true;

  /// Convenience helper to disable preview mode programmatically.
  static void disable() => manualOverride = false;
}
