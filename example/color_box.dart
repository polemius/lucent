import 'dart:io';
import 'package:lucent/src/text_styles.dart';

void main() {
  final width = stdout.hasTerminal ? stdout.terminalColumns : 80;
  final height = 5;

  for (int y = 0; y < height; y++) {
    final lightness = 0.1 + (y / height) * 0.7;
    final line = StringBuffer();

    for (int x = 0; x < width; x++) {
      final hue = x / width;
      final rgb1 = hlsToRgb(hue, lightness, 1.0);
      final rgb2 = hlsToRgb(hue, lightness + 0.7 / 10, 1.0);

      final style = TextStyle(fgRgb: rgbToInt(rgb2), bgRgb: rgbToInt(rgb1));

      line.write(style.apply('▄'));
    }

    print(line);
  }
}

List<double> hlsToRgb(double h, double l, double s) {
  double hueToRgb(double p, double q, double t) {
    if (t < 0) t += 1;
    if (t > 1) t -= 1;
    if (t < 1 / 6) return p + (q - p) * 6 * t;
    if (t < 1 / 2) return q;
    if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
    return p;
  }

  double r, g, b;

  if (s == 0) {
    r = g = b = l;
  } else {
    final q = l < 0.5 ? l * (1 + s) : l + s - l * s;
    final p = 2 * l - q;
    r = hueToRgb(p, q, h + 1 / 3);
    g = hueToRgb(p, q, h);
    b = hueToRgb(p, q, h - 1 / 3);
  }

  return [r, g, b];
}

List<int> rgbToInt(List<double> rgb) =>
    rgb.map((c) => (c * 255).round().clamp(0, 255)).toList();
