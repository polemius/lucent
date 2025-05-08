import 'dart:io';
import 'package:lucent/lucent.dart';
import 'package:lucent/src/text_styles.dart';

void main() {
  Console.print(
    '[bold]Bold[/] [italic]Italic[/] [underline]Underline[/] [dim]Dim[/] [strike]Strikethrough[/] [reverse]Reverse[/]',
  );
  Console.print('');

  Console.print(
    '[red]Red[/] [green]Green[/] [yellow]Yellow[/] [blue]Blue[/] [magenta]Magenta[/] [cyan]Cyan[/] [white]White[/]',
  );
  Console.print(
    '[bright_red]Bright Red[/] [bright_green]Bright Green[/] [bright_yellow]Bright Yellow[/]',
  );
  Console.print('');

  Console.print(
    '[color(202)]Orange 202[/] [color(129)]Purple 129[/] [on color(236)]On Dark Gray 236[/]',
  );
  Console.print('');

  Console.print(
    '[color(tomato)]Tomato[/] [on slategray]Slate Gray BG[/] [bold white on gold]White on Gold[/]',
  );
  Console.print('');

  Console.print('[color(#ff00ff)]Hex Magenta[/] [on #003366]Dark Blue BG[/]');
  Console.print(
    '[color(rgb(255,165,0)) on rgb(255,255,255)]Orange on white[/]',
  );
  Console.print('');

  if (!isStylingEnabled) {
    Console.print('> Styling disabled — dumb terminal fallback.\n');
  }

  Console.print('[bold underline green]Color Gradient Demo[/]');
  _renderColorBox();
}

void _renderColorBox() {
  final width = stdout.hasTerminal ? stdout.terminalColumns : 80;
  const height = 5;

  for (int y = 0; y < height; y++) {
    final lightness = 0.1 + (y / height) * 0.7;
    final buffer = StringBuffer();

    for (int x = 0; x < width; x++) {
      final hue = x / width;
      final rgb1 = _hlsToRgb(hue, lightness, 1.0);
      final rgb2 = _hlsToRgb(hue, lightness + 0.7 / 10, 1.0);

      final style = TextStyle(fgRgb: _to255(rgb2), bgRgb: _to255(rgb1));

      buffer.write(style.apply('▄'));
    }
    print(buffer.toString());
  }
}

List<double> _hlsToRgb(double h, double l, double s) {
  double hueToRgb(double p, double q, double t) {
    if (t < 0) t += 1;
    if (t > 1) t -= 1;
    if (t < 1 / 6) return p + (q - p) * 6 * t;
    if (t < 1 / 2) return q;
    if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
    return p;
  }

  if (s == 0) return [l, l, l];
  final q = l < 0.5 ? l * (1 + s) : l + s - l * s;
  final p = 2 * l - q;
  return [
    hueToRgb(p, q, h + 1 / 3),
    hueToRgb(p, q, h),
    hueToRgb(p, q, h - 1 / 3),
  ];
}

List<int> _to255(List<double> rgb) =>
    rgb.map((c) => (c * 255).round().clamp(0, 255)).toList();
