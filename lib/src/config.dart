import 'dart:io';

/// Whether ANSI styling is currently enabled.
///
/// Determined at startup by detecting terminal capabilities
/// (e.g. `TERM` environment, TTY support), but can be
/// overridden using [enableStyling] or [disableStyling].
bool isStylingEnabled = _detectStylingSupport();

bool _warned = false;
bool _silent = false;

/// Detects if the current terminal supports ANSI styling.
///
/// - Checks `TERM` environment variable for `"dumb"`.
/// - Ensures `stdout` is a TTY.
/// - Prints a one-time warning to `stderr` when styling is disabled,
///   unless [silentMode] has been invoked.
/// Returns `true` if styling should be enabled, `false` otherwise.
bool _detectStylingSupport() {
  final term = Platform.environment['TERM'] ?? '';
  final hasTerminal = stdout.hasTerminal;

  final isDumb = term.toLowerCase() == 'dumb' || !hasTerminal;

  if (isDumb && !_warned && !_silent) {
    stderr.writeln(
      '[lucent] ⚠ Styling disabled: TERM=$term, tty=${hasTerminal ? "yes" : "no"}',
    );
    _warned = true;
  }

  return !isDumb;
}

/// Enables or disables ANSI styling programmatically.
///
/// Passing `false` to this function will disable all styling
/// regardless of terminal detection.
void enableStyling([bool enabled = true]) {
  isStylingEnabled = enabled;
}

/// Convenience to disable ANSI styling.
///
/// Equivalent to calling `enableStyling(false)`.
void disableStyling() => enableStyling(false);

/// Suppresses the one-time warning message when styling is disabled.
///
/// Useful in CI environments or scripts where you do not want
/// the `[lucent] ⚠ Styling disabled…` message to appear.
void silentMode() {
  _silent = true;
}
