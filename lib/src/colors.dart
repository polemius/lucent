/// Standard ANSI 4-bit color codes, including bright variants.
///
/// Each value corresponds to its ANSI escape code for setting the
/// foreground color in terminals that support ANSI coloring.
enum AnsiColor {
  /// Black (ANSI code 30).
  black(30),

  /// Red (ANSI code 31).
  red(31),

  /// Green (ANSI code 32).
  green(32),

  /// Yellow (ANSI code 33).
  yellow(33),

  /// Blue (ANSI code 34).
  blue(34),

  /// Magenta (ANSI code 35).
  magenta(35),

  /// Cyan (ANSI code 36).
  cyan(36),

  /// White (ANSI code 37).
  white(37),

  /// Default terminal foreground color (ANSI code 39).
  defaultColor(39),

  /// Bright Black (ANSI code 90).
  brightBlack(90),

  /// Bright Red (ANSI code 91).
  brightRed(91),

  /// Bright Green (ANSI code 92).
  brightGreen(92),

  /// Bright Yellow (ANSI code 93).
  brightYellow(93),

  /// Bright Blue (ANSI code 94).
  brightBlue(94),

  /// Bright Magenta (ANSI code 95).
  brightMagenta(95),

  /// Bright Cyan (ANSI code 96).
  brightCyan(96),

  /// Bright White (ANSI code 97).
  brightWhite(97);

  /// The underlying ANSI escape code for this color.
  final int code;

  /// Creates an [AnsiColor] with the given ANSI [code].
  const AnsiColor(this.code);
}
