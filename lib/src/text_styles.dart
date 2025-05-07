import 'package:lucent/src/colors.dart';
import 'package:lucent/src/config.dart';

class TextStyle {
  final AnsiColor? color;
  final bool bold;
  final bool italic;
  final bool underline;
  final bool dim;
  final bool reverse;
  final bool conceal;
  final bool strike;
  final bool blink;
  final bool overline;
  final bool frame;
  final bool encircle;
  final bool underline2;
  final int? fg256;
  final int? bg256;
  final List<int>? fgRgb;
  final List<int>? bgRgb;

  const TextStyle({
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

  String apply(String text) {
    if (!isStylingEnabled) {
      return text;
    }

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

      // Foreground color: priority → RGB > 8-bit > 4-bit
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

      // Background color: priority → RGB > 8-bit
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

    final start = '\x1B[${codes.join(';')}m';
    const end = '\x1B[0m';
    return '$start$text$end';
  }

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

    if (bg256 != null) {
      props.add('bg256=$bg256');
    }
    if (fgRgb != null) {
      props.add('fgRgb=${fgRgb!.join(',')}');
    }
    if (bgRgb != null) {
      props.add('bgRgb=${bgRgb!.join(',')}');
    }

    return 'TextStyle(${props.join(', ')})';
  }
}
