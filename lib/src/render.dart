import 'markup/markup.dart';
import 'markup/parser.dart';

/// Parses Lucent markup tags in [input] and returns a fully ANSI-styled string.
///
/// This function:
/// 1. Tokenizes the raw [input] into a sequence of `Token`s via `tokenizeMarkup`.
/// 2. Converts those tokens into a list of `StyledSpan`s (text + `TextStyle`) via `parseTokens`.
/// 3. Applies each span’s style to its text and concatenates the results.
///
/// Supports nested tags, color tags (4-bit, 8-bit, truecolor, hex, named), background styling,
/// and text decorations like bold, italic, underline, blink, etc.
///
/// Example:
/// ```dart
/// final output = renderText('[bold red]Error:[/] Something went wrong.');
/// stdout.writeln(output);
/// ```
String renderText(String input) {
  final tokens = tokenizeMarkup(input);
  final spans = parseTokens(tokens);
  return spans.map((s) => s.style.apply(s.text)).join();
}
