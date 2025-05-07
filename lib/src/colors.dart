enum AnsiColor {
  black(30),
  red(31),
  green(32),
  yellow(33),
  blue(34),
  magenta(35),
  cyan(36),
  white(37),
  defaultColor(39),
  brightBlack(90),
  brightRed(91),
  brightGreen(92),
  brightYellow(93),
  brightBlue(94),
  brightMagenta(95),
  brightCyan(96),
  brightWhite(97);

  final int code;
  const AnsiColor(this.code);
}
