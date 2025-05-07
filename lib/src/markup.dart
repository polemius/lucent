import 'package:lucent/src/named_colors.dart';

import 'colors.dart';
import 'text_styles.dart';

String renderText(String input) {
  final styleStack = <TextStyle>[];
  final buffer = StringBuffer();
  final tagPattern = RegExp(r'\[(\/?[^\[\]]+)\]');

  int lastMatchEnd = 0;

  for (final match in tagPattern.allMatches(input)) {
    final tag = match.group(1);
    if (tag == null) continue;

    final isClosing = tag.startsWith('/');
    final tagName = tag.replaceFirst('/', '').trim().toLowerCase();

    if (match.start > lastMatchEnd) {
      final plain = input.substring(lastMatchEnd, match.start);
      final currentStyle =
          styleStack.isNotEmpty ? styleStack.last : const TextStyle();
      buffer.write(currentStyle.apply(plain));
    }

    if (tagName == 'reset') {
      styleStack.clear();
    } else if (isClosing) {
      if (styleStack.isNotEmpty) {
        styleStack.removeLast();
      }
    } else {
      styleStack.add(_parseStyle(tagName));
    }

    lastMatchEnd = match.end;
  }

  if (lastMatchEnd < input.length) {
    final plain = input.substring(lastMatchEnd);
    final currentStyle =
        styleStack.isNotEmpty ? styleStack.last : const TextStyle();
    buffer.write(currentStyle.apply(plain));
  }

  return buffer.toString();
}

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

TextStyle _parseStyle(String tag) {
  final colorFunc = RegExp(r'(?<!on )color\((\d{1,3})\)');
  final bgFunc = RegExp(r'on color\((\d{1,3})\)');
  final fgRgbFunc = RegExp(
    r'color\(rgb\((\d{1,3}),\s*(\d{1,3}),\s*(\d{1,3})\)\)',
  );
  final bgRgbFunc = RegExp(r'on rgb\((\d{1,3}),\s*(\d{1,3}),\s*(\d{1,3})\)');
  final fgHex = RegExp(r'#([0-9a-fA-F]{6})');
  final bgHex = RegExp(r'on #([0-9a-fA-F]{6})');

  final fgNamed = RegExp(r'color\(([\w]+)\)');
  final bgNamed = RegExp(r'on ([\w]+)');

  var style = const TextStyle();
  var workingTag = tag.toLowerCase();

  final fgNamedMatch = fgNamed.firstMatch(workingTag);
  if (fgNamedMatch != null) {
    final name = fgNamedMatch.group(1)!.toLowerCase();
    if (namedColors.containsKey(name)) {
      style = style.copyWith(fgRgb: namedColors[name]);
      workingTag = workingTag.replaceFirst(fgNamedMatch.group(0)!, '');
    }
  }

  final bgNamedMatch = bgNamed.firstMatch(workingTag);
  if (bgNamedMatch != null) {
    final name = bgNamedMatch.group(1)!.toLowerCase();
    if (namedColors.containsKey(name)) {
      style = style.copyWith(bgRgb: namedColors[name]);
      workingTag = workingTag.replaceFirst(bgNamedMatch.group(0)!, '');
    }
  }

  final bgHexMatch = bgHex.firstMatch(workingTag);
  if (bgHexMatch != null) {
    final hex = bgHexMatch.group(1)!;
    final rgb = _hexToRgb(hex);
    style = style.copyWith(bgRgb: rgb);
    workingTag = workingTag.replaceFirst(bgHexMatch.group(0)!, '');
  }

  final fgHexMatch = fgHex.firstMatch(workingTag);
  if (fgHexMatch != null) {
    final hex = fgHexMatch.group(1)!;
    final rgb = _hexToRgb(hex);
    style = style.copyWith(fgRgb: rgb);
    workingTag = workingTag.replaceFirst(fgHexMatch.group(0)!, '');
  }

  final fgRgbMatch = fgRgbFunc.firstMatch(workingTag);
  if (fgRgbMatch != null) {
    final r = int.parse(fgRgbMatch.group(1)!);
    final g = int.parse(fgRgbMatch.group(2)!);
    final b = int.parse(fgRgbMatch.group(3)!);
    style = style.copyWith(fgRgb: [r, g, b]);
    workingTag = workingTag.replaceFirst(fgRgbMatch.group(0)!, '');
  }

  final bgRgbMatch = bgRgbFunc.firstMatch(workingTag);
  if (bgRgbMatch != null) {
    final r = int.parse(bgRgbMatch.group(1)!);
    final g = int.parse(bgRgbMatch.group(2)!);
    final b = int.parse(bgRgbMatch.group(3)!);
    style = style.copyWith(bgRgb: [r, g, b]);
    workingTag = workingTag.replaceFirst(bgRgbMatch.group(0)!, '');
  }

  final bgMatch = bgFunc.firstMatch(workingTag);
  if (bgMatch != null) {
    final code = int.parse(bgMatch.group(1)!);
    if (code >= 0 && code <= 255) {
      style = style.copyWith(bg256: code);
    }
    workingTag = workingTag.replaceFirst(bgMatch.group(0)!, '');
  }

  final fgMatch = colorFunc.firstMatch(workingTag);
  if (fgMatch != null) {
    final code = int.parse(fgMatch.group(1)!);
    if (code >= 0 && code <= 255) {
      style = style.copyWith(fg256: code);
    }
    workingTag = workingTag.replaceFirst(fgMatch.group(0)!, '');
  }

  final parts = workingTag.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  for (final part in parts) {
    final modifier = _styleModifiers[part];
    if (modifier != null) {
      style = modifier(style);
    }
  }

  return style;
}

String _normalizeColorName(String name) {
  return name.replaceAllMapped(
    RegExp(r'([A-Z])'),
    (m) => '_${m.group(1)!.toLowerCase()}',
  );
}

List<int> _hexToRgb(String hex) {
  final r = int.parse(hex.substring(0, 2), radix: 16);
  final g = int.parse(hex.substring(2, 4), radix: 16);
  final b = int.parse(hex.substring(4, 6), radix: 16);
  return [r, g, b];
}
