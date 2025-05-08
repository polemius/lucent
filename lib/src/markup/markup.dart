import 'lexer.dart';

/// Splits the input string into a sequence of [Token]s.
///
/// Recognizes `[tag]`, `[/tag]`, and plain text.
/// Returns a list of tokens in the order they appear.
List<Token> tokenizeMarkup(String input) {
  final tokens = <Token>[];
  // Match: '[' + optional spaces +
  //        ( '/'                      <-- shorthand close
  //        | '/?X…' where X ∈ [A-Za-z#] ) <-- open or explicit close
  //        optional spaces + ']'
  final tagPattern = RegExp(r'\[\s*(\/|\/?[#A-Za-z][^\[\]]*)\s*\]');
  int lastEnd = 0;

  for (final match in tagPattern.allMatches(input)) {
    if (match.start > lastEnd) {
      tokens.add(Token('text', input.substring(lastEnd, match.start)));
    }

    final tagContent = match.group(1)!;
    if (tagContent == '/') {
      // shorthand closing
      tokens.add(Token('tag_close', ''));
    } else if (tagContent.startsWith('/')) {
      // explicit closing
      tokens.add(Token('tag_close', tagContent.substring(1).trim()));
    } else {
      // opening tag
      tokens.add(Token('tag_open', tagContent.trim()));
    }

    lastEnd = match.end;
  }

  if (lastEnd < input.length) {
    tokens.add(Token('text', input.substring(lastEnd)));
  }

  return tokens;
}
