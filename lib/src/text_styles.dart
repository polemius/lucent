import 'package:lucent/src/colors.dart';
import 'package:lucent/src/config.dart';

/// Represents a set of styling options for terminal text,
/// including colors (4-bit, 8-bit, truecolor), text decorations,
/// and other ANSI attributes.
class TextStyle {
  /// A 4-bit ANSI foreground color.
  final AnsiColor? color;

  /// Whether text is bold (ANSI code 1).
  final bool bold;

  /// Whether text is dim (ANSI code 2).
  final bool italic;

  /// Whether text is italic (ANSI code 3).
  final bool underline;

  /// Whether text is underlined (ANSI code 4).
  final bool dim;

  /// Whether text is inverse/reverse (ANSI code 7).
  final bool reverse;

  /// Whether text is concealed/hidden (ANSI code 8).
  final bool conceal;

  /// Whether text is struck through (ANSI code 9).
  final bool strike;

  /// Whether text blinks (slow blink, ANSI code 5).
  final bool blink;

  /// Whether text is overlined (ANSI code 53).
  final bool overline;

  /// Whether text is framed (ANSI code 51).
  final bool frame;

  /// Whether text is encircled (ANSI code 52).
  final bool encircle;

  /// Whether text uses double underline (ANSI code 21).
  final bool underline2;

  /// A custom 8-bit (256) foreground color code.
  final int? fg256;

  /// A custom 8-bit (256) background color code.
  final int? bg256;

  /// A truecolor (24-bit RGB) foreground triple `[r, g, b]`.
  final List<int>? fgRgb;

  /// A truecolor (24-bit RGB) background triple `[r, g, b]`.
  final List<int>? bgRgb;

  late final String _ansiPrefix = _buildAnsiPrefix();
  static const String _ansiSuffix = '\x1B[0m';

  /// Creates a [TextStyle] with the given properties.
  ///
  /// By default, only [color] is set to [AnsiColor.defaultColor]
  /// and all other decorations are `false`.
  TextStyle({
    this.color = AnsiColor.defaultColor,
    this.fg256,
    this.bg256,
    this.fgRgb,
    this.bgRgb,
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.dim = false,
    this.reverse = false,
    this.conceal = false,
    this.strike = false,
    this.blink = false,
    this.overline = false,
    this.frame = false,
    this.encircle = false,
    this.underline2 = false,
  });

  String _buildAnsiPrefix() {
    if (!isStylingEnabled) return '';
    final codes = <int>[
      if (bold) 1,
      if (dim) 2,
      if (italic) 3,
      if (underline) 4,
      if (blink) 5,
      if (reverse) 7,
      if (conceal) 8,
      if (strike) 9,
      if (frame) 51,
      if (encircle) 52,
      if (overline) 53,
      if (underline2) 21,
      if (fgRgb != null) ...[
        38,
        2,
        ...fgRgb!,
      ] else if (fg256 != null) ...[
        38,
        5,
        fg256!,
      ] else if (color != null)
        color!.code,
      if (bgRgb != null) ...[
        48,
        2,
        ...bgRgb!,
      ] else if (bg256 != null) ...[
        48,
        5,
        bg256!,
      ],
    ];
    return '\x1B[${codes.join(';')}m';
  }

  /// Applies this style to [text], wrapping it in ANSI escape codes
  /// built once per style instance (cached in `_ansiPrefix`).
  ///
  /// - Honors truecolor (RGB), 8-bit, and 4-bit color settings.
  /// - Emits ANSI codes for bold, italic, underline, blink, etc.
  /// - If styling is disabled via [isStylingEnabled], or if this style
  ///   has no codes, returns [text] unchanged.
  String apply(String text) {
    if (_ansiPrefix.isEmpty) return text;
    return '$_ansiPrefix$text$_ansiSuffix';
  }

  /// Returns a new [TextStyle] by overriding the specified properties
  /// on this instance.
  ///
  /// Any parameter set to `null` will preserve the original.
  TextStyle copyWith({
    AnsiColor? color,
    int? fg256,
    int? bg256,
    List<int>? fgRgb,
    List<int>? bgRgb,
    bool? bold,
    bool? italic,
    bool? underline,
    bool? dim,
    bool? reverse,
    bool? conceal,
    bool? strike,
    bool? blink,
    bool? overline,
    bool? frame,
    bool? encircle,
    bool? underline2,
  }) {
    return TextStyle(
      color: color ?? this.color,
      fg256: fg256 ?? this.fg256,
      bg256: bg256 ?? this.bg256,
      fgRgb: fgRgb ?? this.fgRgb,
      bgRgb: bgRgb ?? this.bgRgb,
      bold: bold ?? this.bold,
      italic: italic ?? this.italic,
      underline: underline ?? this.underline,
      dim: dim ?? this.dim,
      reverse: reverse ?? this.reverse,
      conceal: conceal ?? this.conceal,
      strike: strike ?? this.strike,
      blink: blink ?? this.blink,
      overline: overline ?? this.overline,
      frame: frame ?? this.frame,
      encircle: encircle ?? this.encircle,
      underline2: underline2 ?? this.underline2,
    );
  }

  @override
  String toString() {
    final props = <String>[];

    if (bold) props.add('bold');
    if (dim) props.add('dim');
    if (italic) props.add('italic');
    if (underline) props.add('underline');
    if (blink) props.add('blink');
    if (reverse) props.add('reverse');
    if (conceal) props.add('conceal');
    if (strike) props.add('strike');
    if (overline) props.add('overline');
    if (frame) props.add('frame');
    if (encircle) props.add('encircle');
    if (underline2) props.add('underline2');
    if (fg256 != null) {
      props.add('fg256=$fg256');
    } else if (color != null) {
      props.add('color=${color!.name}');
    }
    if (bg256 != null) props.add('bg256=$bg256');
    if (fgRgb != null) props.add('fgRgb=${fgRgb!.join(',')}');
    if (bgRgb != null) props.add('bgRgb=${bgRgb!.join(',')}');

    return 'TextStyle(${props.join(', ')})';
  }
}
