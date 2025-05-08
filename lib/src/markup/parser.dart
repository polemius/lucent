import '../colors.dart';
import '../named_colors.dart';
import '../text_styles.dart';
import 'lexer.dart';

/// Determines whether subsequent color/style tokens should apply
/// to the foreground or background.
enum _StyleContext { foreground, background }

/// A piece of text along with the [TextStyle] that should be
/// applied when rendering to the terminal.
class StyledSpan {
  /// The literal text content of this span.
  final String text;

  /// The styling to apply to [text].
  final TextStyle style;

  /// Creates a [StyledSpan] with the given [text] and [style].
  StyledSpan(this.text, this.style);
}

/// Parses a list of [Token]s into styled text spans.
///
/// Maintains a stack of [TextStyle]s so that nested tags
/// (`[bold][red]...[/][/]`) work correctly. When a `tag_open`
/// token is encountered, a new style is pushed onto the stack;
/// `tag_close` pops the stack (but never below the base style).
/// Plain `text` tokens are emitted as [StyledSpan]s with the
/// current top-of-stack style.
List<StyledSpan> parseTokens(List<Token> tokens) {
  final spans = <StyledSpan>[];
  final styleStack = <TextStyle>[TextStyle()];

  for (final token in tokens) {
    switch (token.type) {
      case 'tag_open':
        styleStack.add(_parseStyleTag(token.value, styleStack.last));
        break;
      case 'tag_close':
        if (styleStack.length > 1) {
          styleStack.removeLast();
        }
        break;
      case 'text':
        spans.add(StyledSpan(token.value, styleStack.last));
        break;
    }
  }

  return spans;
}

/// Mapping of simple style keywords (e.g. 'bold', 'underline')
/// and ANSI color names (e.g. 'red', 'bright_blue') to functions
/// that apply those modifications to a [TextStyle].
final _styleModifiers = <String, TextStyle Function(TextStyle)>{
  'bold': (style) => style.copyWith(bold: true),
  'dim': (style) => style.copyWith(dim: true),
  'italic': (style) => style.copyWith(italic: true),
  'underline': (style) => style.copyWith(underline: true),
  'reverse': (style) => style.copyWith(reverse: true),
  'conceal': (style) => style.copyWith(conceal: true),
  'strike': (style) => style.copyWith(strike: true),
  'strikethrough': (style) => style.copyWith(strike: true),
  'blink': (style) => style.copyWith(blink: true),
  'overline': (style) => style.copyWith(overline: true),
  'frame': (style) => style.copyWith(frame: true),
  'encircle': (style) => style.copyWith(encircle: true),
  'underline2': (style) => style.copyWith(underline2: true),
  for (var color in AnsiColor.values)
    _normalizeColorName(color.name): (style) => style.copyWith(color: color),
};

/// Parses the contents of a single tag (e.g. `"bold on #ffcc00 color(123)"`)
/// into a new [TextStyle] based on the [parent] style and any RGB/hex/8-bit
/// specifications or keywords.
///
/// Supports:
/// - `on` to switch to background context
/// - `rgb(r,g,b)` and `#rrggbb` for truecolor
/// - `color(n)` for 8-bit color codes
/// - Named CSS colors via [namedColors]
/// - Simple modifiers in [_styleModifiers]
TextStyle _parseStyleTag(String content, TextStyle parent) {
  content = content
      .replaceAll(RegExp(r'\(\s+'), '(')
      .replaceAll(RegExp(r'\s+\)'), ')');

  final parts = content.split(RegExp(r'\s+'));
  var style = parent;
  var context = _StyleContext.foreground;

  for (final raw in parts) {
    final token = raw.toLowerCase();
    if (token == 'on') {
      context = _StyleContext.background;
      continue;
    }

    // Truecolor RGB: rgb(r,g,b)
    final rgbMatch = RegExp(r'^rgb\((\d+),(\d+),(\d+)\)$').firstMatch(token);
    if (rgbMatch != null) {
      final r = int.parse(rgbMatch.group(1)!);
      final g = int.parse(rgbMatch.group(2)!);
      final b = int.parse(rgbMatch.group(3)!);
      // Only accept channels in [0..255]
      if ([r, g, b].every((c) => c >= 0 && c <= 255)) {
        final rgb = [r, g, b];
        style =
            (context == _StyleContext.background)
                ? style.copyWith(bgRgb: rgb)
                : style.copyWith(fgRgb: rgb);
      }
      context = _StyleContext.foreground;
      continue;
    }

    // Hex color: #rrggbb
    final hexRegex = RegExp(r'^#([0-9A-Fa-f]{6})$');
    final hexMatch = hexRegex.firstMatch(token);
    if (hexMatch != null) {
      final rgb = _hexToRgb(hexMatch.group(1)!);
      style =
          (context == _StyleContext.background)
              ? style.copyWith(bgRgb: rgb)
              : style.copyWith(fgRgb: rgb);
      context = _StyleContext.foreground;
      continue;
    }

    // 8-bit color: color(n)
    final codeMatch = RegExp(r'^color\((\d{1,3})\)$').firstMatch(token);
    if (codeMatch != null) {
      final code = int.parse(codeMatch.group(1)!);
      if (code >= 0 && code <= 255) {
        style =
            (context == _StyleContext.background)
                ? style.copyWith(bg256: code)
                : style.copyWith(fg256: code);
      }
      context = _StyleContext.foreground;
      continue;
    }

    // Named color
    if (namedColors.containsKey(token)) {
      final rgb = namedColors[token]!;
      style =
          (context == _StyleContext.background)
              ? style.copyWith(bgRgb: rgb)
              : style.copyWith(fgRgb: rgb);
      context = _StyleContext.foreground;
      continue;
    }

    // Simple modifiers (bold, underline, etc.)
    final modifier = _styleModifiers[token];
    if (modifier != null) {
      style = modifier(style);
    }
  }

  return style;
}

/// Converts a 6-digit hexadecimal color string (`rrggbb`) to an
/// RGB triple `[r, g, b]` with each channel in `0…255`.
List<int> _hexToRgb(String hex) {
  final r = int.parse(hex.substring(0, 2), radix: 16);
  final g = int.parse(hex.substring(2, 4), radix: 16);
  final b = int.parse(hex.substring(4, 6), radix: 16);
  return [r, g, b];
}

/// Converts an [AnsiColor] enum name (e.g. `"brightRed"`) into its
/// snake_case string (e.g. `"bright_red"`), used as a key in
/// the [_styleModifiers] map.
String _normalizeColorName(String name) {
  return name.replaceAllMapped(
    RegExp(r'([A-Z])'),
    (m) => '_${m.group(1)!.toLowerCase()}',
  );
}
