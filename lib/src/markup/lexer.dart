/// A lexical token produced by the Lucent markup lexer.
///
/// Tokens represent either plain text or markup tags
/// (opening tags like `[bold red]` or closing tags like `[/]`).
class Token {
  /// The kind of token:
  ///
  /// - `'tag_open'`   — an opening tag (e.g. `bold red on #ffcc00`)
  /// - `'tag_close'`  — a closing tag (e.g. `[/]` or `[/bold red]`)
  /// - `'text'`       — plain text between tags
  final String type;

  /// The raw content of the token.
  ///
  /// For `'text'` tokens, this is the literal text.
  /// For tag tokens, this is the tag payload (without brackets or slash).
  final String value;

  /// Creates a new [Token] of the given [type] with the given [value].
  Token(this.type, this.value);
}
