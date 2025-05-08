import 'package:lucent/src/markup/markup.dart';
import 'package:test/test.dart';

void main() {
  group('tokenizeMarkup', () {
    test('plain text without tags', () {
      final tokens = tokenizeMarkup('Hello world');
      expect(tokens, hasLength(1));
      expect(tokens[0].type, 'text');
      expect(tokens[0].value, 'Hello world');
    });

    test('explicit open and close tags', () {
      final tokens = tokenizeMarkup('[bold]Hello[/bold]');
      expect(tokens, hasLength(3));
      expect(tokens[0].type, 'tag_open');
      expect(tokens[0].value, 'bold');
      expect(tokens[1].type, 'text');
      expect(tokens[1].value, 'Hello');
      expect(tokens[2].type, 'tag_close');
      expect(tokens[2].value, 'bold');
    });

    test('shorthand closing tag', () {
      final tokens = tokenizeMarkup('[italic]Hi[/]');
      expect(tokens, hasLength(3));
      expect(tokens[0].type, 'tag_open');
      expect(tokens[0].value, 'italic');
      expect(tokens[1].type, 'text');
      expect(tokens[1].value, 'Hi');
      expect(tokens[2].type, 'tag_close');
      expect(tokens[2].value, '');
    });

    test('multiple tags and text segments', () {
      final tokens = tokenizeMarkup('Foo [red]Bar[/] Baz');
      expect(tokens.map((t) => t.type).toList(), [
        'text',
        'tag_open',
        'text',
        'tag_close',
        'text',
      ]);
      expect(tokens.map((t) => t.value).toList(), [
        'Foo ',
        'red',
        'Bar',
        '',
        ' Baz',
      ]);
    });

    test('tag with multiple words', () {
      final tokens = tokenizeMarkup('[bold red on color(11)]X[/]');
      expect(tokens[0].type, 'tag_open');
      expect(tokens[0].value, 'bold red on color(11)');
      expect(tokens[1].type, 'text');
      expect(tokens[1].value, 'X');
      expect(tokens[2].type, 'tag_close');
      expect(tokens[2].value, '');
    });

    test('white spaces', () {
      final tokens = tokenizeMarkup('[ bold red ]X[/]');
      expect(tokens[0].type, 'tag_open');
      expect(tokens[0].value, 'bold red');
      expect(tokens[1].type, 'text');
      expect(tokens[1].value, 'X');
      expect(tokens[2].type, 'tag_close');
      expect(tokens[2].value, '');
    });

    test('white spaces 2', () {
      final tokens = tokenizeMarkup('[ color( 123 ) on #ff00ff ]X[/]');
      expect(tokens[0].type, 'tag_open');
      expect(tokens[0].value, 'color( 123 ) on #ff00ff');
      expect(tokens[1].type, 'text');
      expect(tokens[1].value, 'X');
      expect(tokens[2].type, 'tag_close');
      expect(tokens[2].value, '');
    });
  });
}
