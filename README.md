<div align="center">
  <img src="https://raw.githubusercontent.com/polemius/lucent/main/assets/logo_s.png" alt="Lucent Logo" width="150">
</div>

**Lucent** is a powerful and expressive terminal styling library for Dart, inspired by Python's Rich. It allows you to style terminal output with ease, supporting nested styles, truecolor, and intelligent fallbacks for terminals with limited capabilities.

---

![Lucent Example Screenshot](https://raw.githubusercontent.com/polemius/lucent/main/assets/image.png)

## ✨ Features

- **Rich Markup Syntax** – Use tags like `[bold red]Error:[/]` for styled output.
- **Truecolor Support** – Use 24-bit RGB with `[color(#ff33aa)]` or `[on rgb(255, 255, 0)]`.
- **256-Color & 4-Bit Fallbacks** – Automatically converts to nearest match based on terminal.
- **Named Colors** – CSS-like color names: `[color(tomato)]`, `[on slategray]`, etc.
- **Style Nesting** – Combine `[bold underline red]` and more.
- **Dumb Terminal Detection** – Automatically disables styling for `TERM=dumb`.
- **Manual Styling Control** – Enable/disable styling and silence warnings.

---

## 🚀 Getting Started

### Installation

Add to `pubspec.yaml`:

```yaml
dependencies:
  lucent: ^0.1.0
```

Then install:

```bash
dart pub get
```

### Basic Usage

```dart
import 'package:lucent/lucent.dart';

void main() {
  Console.print('[bold green]Success:[/] Operation completed.');
}
```

---

## 🎨 Advanced Styling

### Nested Styles

```dart
Console.print('[bold red]Error: [underline]File not found[/][/]');
```

### Truecolor (24-bit)

```dart
Console.print('[color(#ff33aa)]Pink Text[/]');
Console.print('[on rgb(255, 255, 0)]Yellow Background[/]');
```

### Named Colors

```dart
Console.print('[color(tomato)]Tomato Text[/]');
Console.print('[on slategray]Slate Gray Background[/]');
```

---

## 🧠 Terminal Compatibility

Lucent automatically detects and adapts to the terminal:

| Terminal         | Output                     |
|------------------|----------------------------|
| TERM=dumb        | No styling (safe)          |
| 4-bit (ANSI)     | 16 colors                  |
| 8-bit (xterm-256)| 256-color palette          |
| Truecolor        | Full 24-bit RGB            |

Manually override behavior:

```dart
enableStyling();       // Force styling on
disableStyling();      // Disable all styling
silentMode();          // Suppress warnings
```

---

## 📦 API Reference

- `Console.print(String markup)`
- `enableStyling([bool enabled = true])`
- `disableStyling()`
- `silentMode()`

---

## 🧪 Examples

```dart
Console.print('[bold blue]Info:[/] App started');
Console.print('[italic yellow]Warning:[/] Low disk space');
Console.print('[underline red]Error:[/] Connection failed');

Console.print('[bold color(tomato) on gold] Tasty styled message [/]');
```

---

Lucent is inspired by the [Rich](https://github.com/Textualize/rich) Python library.
