import 'dart:io';

bool isStylingEnabled = _detectStylingSupport();

bool _warned = false;
bool _silent = false;

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

void enableStyling([bool enabled = true]) {
  isStylingEnabled = enabled;
}

void disableStyling() => enableStyling(false);

void silentMode() {
  _silent = true;
}
