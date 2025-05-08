import 'package:lucent/src/markup/markup.dart';
import 'package:test/test.dart';
import 'package:lucent/src/markup/parser.dart';
import 'package:lucent/src/text_styles.dart';
import 'package:lucent/src/named_colors.dart';

void main() {
  group('Edge case parsing in parseTokens', () {
    test('plain text', () {
      final spans = parseTokens(tokenizeMarkup('Just some text'));
      expect(spans, hasLength(1));
      expect(spans[0].text, 'Just some text');
      expect(spans[0].style.toString(), TextStyle().toString());
    });

    test('unknown tag ignored', () {
      final spans = parseTokens(tokenizeMarkup('[foo]bar[/foo]'));
      expect(spans, hasLength(1));
      expect(spans[0].text, 'bar');
      expect(spans[0].style.toString(), TextStyle().toString());
    });

    test('just on tag ignored', () {
      final spans = parseTokens(tokenizeMarkup('[on]A[/]'));
      expect(spans, hasLength(1));
      expect(spans[0].text, 'A');
      expect(spans[0].style.toString(), TextStyle().toString());
    });

    test('mixed-case tag', () {
      final spans = parseTokens(tokenizeMarkup('[BoLd]X[/bOlD]'));
      expect(spans, hasLength(1));
      expect(spans[0].text, 'X');
      expect(spans[0].style.bold, isTrue);
    });

    test('missing closing tag', () {
      final spans = parseTokens(tokenizeMarkup('[italic]Hello'));
      expect(spans, hasLength(1));
      expect(spans[0].text, 'Hello');
      expect(spans[0].style.italic, isTrue);
    });

    test('shorthand closing only', () {
      final spans = parseTokens(tokenizeMarkup('[underline]Hi[/]'));
      expect(spans, hasLength(1));
      expect(spans[0].text, 'Hi');
      expect(spans[0].style.underline, isTrue);
    });

    test('nested mismatched closes', () {
      final spans = parseTokens(tokenizeMarkup('[bold][red]X[/bold][/red]'));
      expect(spans, hasLength(1));
      final style = spans[0].style;
      expect(style.bold, isTrue);
      expect(style.fgRgb, equals(namedColors['red']));
    });

    test('interleaved text + tags', () {
      final spans = parseTokens(tokenizeMarkup('A[bold]B[/]C'));
      expect(spans.map((s) => s.text).toList(), ['A', 'B', 'C']);
      expect(spans[1].style.bold, isTrue);
    });

    test('multiple on contexts', () {
      final spans = parseTokens(tokenizeMarkup('[on red on blue]X[/]'));
      expect(spans, hasLength(1));
      expect(spans[0].style.bgRgb, equals(namedColors['blue']));
    });

    test('mixing order on contexts', () {
      final spans = parseTokens(tokenizeMarkup('[on red bold underline]X[/]'));
      expect(spans, hasLength(1));
      expect(spans[0].style.bgRgb, equals(namedColors['red']));
      expect(spans[0].style.bold, isTrue);
      expect(spans[0].style.underline, isTrue);
    });

    test('8-bit overflow ignored', () {
      final spans = parseTokens(tokenizeMarkup('[color(300)]OOB[/]'));
      expect(spans, hasLength(1));
      expect(spans[0].style.fg256, isNull);
    });

    test('rgb overflow/negative ignored', () {
      final spans = parseTokens(tokenizeMarkup('[rgb(256,-1,128)]Edge[/]'));
      expect(spans, hasLength(1));
      expect(spans[0].style.fgRgb, isNull);
    });

    test('hex uppercase vs lowercase', () {
      final spans1 = parseTokens(tokenizeMarkup('[#AaBbCc]Hx[/]'));
      final spans2 = parseTokens(tokenizeMarkup('[#AABBCC]Hx[/]'));
      expect(spans1[0].style.fgRgb, equals([170, 187, 204]));
      expect(spans2[0].style.fgRgb, equals([170, 187, 204]));
    });

    test('adjacent empty tags', () {
      final spans = parseTokens(tokenizeMarkup('[bold][/bold]'));
      expect(spans, isEmpty);
    });

    test('complex mix of styles', () {
      final spans = parseTokens(
        tokenizeMarkup('[bold red on rgb(0,128,255) underline]Mix[/]'),
      );
      expect(spans, hasLength(1));
      final style = spans[0].style;
      expect(style.bold, isTrue);
      expect(style.underline, isTrue);
      expect(style.fgRgb, equals(namedColors['red']));
      expect(style.bgRgb, equals([0, 128, 255]));
    });

    test('multiple closing tags', () {
      final spans = parseTokens(tokenizeMarkup('[/][/][/bold]A[/]'));
      expect(spans[0].text, 'A');
      expect(spans[0].style.bold, isFalse);
    });

    test('explicit close mismatches', () {
      final spans = parseTokens(
        tokenizeMarkup('[italic][bold]X[/italic][/bold]'),
      );
      expect(spans[0].text, 'X');
      expect(spans[0].style.bold, isTrue);
    });

    test('whitespaces in tags', () {
      final spans = parseTokens(
        tokenizeMarkup('[bold color( 123 ) on #ff00ff ]X[/]'),
      );
      expect(spans, hasLength(1));
      expect(spans[0].text, 'X');
      expect(spans[0].style.bold, isTrue);
      expect(spans[0].style.fg256, equals(123));
      expect(spans[0].style.bgRgb, equals([255, 0, 255]));
    });
  });
}
