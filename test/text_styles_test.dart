import 'package:lucent/src/text_styles.dart';
import 'package:test/test.dart';
import 'package:lucent/src/colors.dart';
import 'package:lucent/src/config.dart';

void main() {
  group('TextStyle.apply()', () {
    setUp(() {
      // Ensure styling is on for these tests
      enableStyling(true);
    });

    test('default style applies defaultColor', () {
      final style = TextStyle();
      final result = style.apply('hello');
      // Default ANSI 4-bit code for defaultColor is 39
      expect(result, '\x1B[39mhello\x1B[0m');
    });

    test('bold and underline', () {
      final style = TextStyle(bold: true, underline: true);
      final result = style.apply('hi');
      // Codes: 1 (bold), 4 (underline), 39 (defaultColor)
      expect(result, '\x1B[1;4;39mhi\x1B[0m');
    });

    test('8-bit foreground and background', () {
      final style = TextStyle(fg256: 100, bg256: 200);
      final result = style.apply('x');
      // Codes: 38;5;100 (fg), 48;5;200 (bg)
      expect(result, '\x1B[38;5;100;48;5;200mx\x1B[0m');
    });

    test('truecolor RGB foreground and background', () {
      final style = TextStyle(fgRgb: [10, 20, 30], bgRgb: [40, 50, 60]);
      final result = style.apply('y');
      // Codes: 38;2;10;20;30 (fg), 48;2;40;50;60 (bg)
      expect(result, '\x1B[38;2;10;20;30;48;2;40;50;60my\x1B[0m');
    });

    test('color precedence: RGB > 8-bit > 4-bit', () {
      final style = TextStyle(color: AnsiColor.red, fg256: 5, fgRgb: [1, 2, 3]);
      final result = style.apply('p');
      // Should use only the RGB code
      expect(result.contains('38;2;1;2;3'), isTrue);
      expect(result.contains('38;5;'), isFalse);
      expect(result.contains('31'), isFalse); // 31 is red 4-bit
    });

    test('copyWith overrides correctly', () {
      final base = TextStyle(bold: true, color: AnsiColor.green);
      final copy = base.copyWith(bold: false, underline: true);
      expect(copy.bold, isFalse);
      expect(copy.underline, isTrue);
      expect(copy.color, AnsiColor.green);
    });

    test('toString includes active properties', () {
      final style = TextStyle(bold: true, fg256: 123, bgRgb: [1, 2, 3]);
      final str = style.toString();
      expect(str, contains('bold'));
      expect(str, contains('fg256=123'));
      expect(str, contains('bgRgb=1,2,3'));
    });

    test('apply returns raw when styling disabled', () {
      disableStyling();
      final style = TextStyle(bold: true, color: AnsiColor.red);
      final result = style.apply('no');
      expect(result, 'no');
      enableStyling(); // restore
    });
  });
}
