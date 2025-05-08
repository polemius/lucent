import 'dart:io';
import 'render.dart';

/// A utility for printing styled text to the terminal.
///
/// Uses [renderText] to parse Lucent markup tags and apply ANSI styling.
/// By default, writes to `stdout` with a trailing newline.
class Console {
  /// Parses [text] for Lucent markup (e.g. `[bold red]Error:[/]`)
  /// and writes the resulting ANSI-styled string to `stdout`.
  ///
  /// The printed output will include any ANSI escape sequences required
  /// to render colors, text decorations, and other styles, then reset
  /// styling at the end of the line.
  static void print(String text) {
    final styledOutput = renderText(text);
    stdout.writeln(styledOutput);
  }
}
