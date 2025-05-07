import 'dart:io';
import 'markup.dart';

class Console {
  static void print(String text) {
    final styledOutput = renderText(text);
    stdout.writeln(styledOutput);
  }
}
