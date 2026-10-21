import 'package:flutter/material.dart';

/// Both themes come from one seed. The seed is the Material baseline primary,
/// read from the SDK, so lib/ holds no colour literal of its own.
ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: const ColorScheme.light().tertiary,
    brightness: brightness,
  );
  return ThemeData(
    colorScheme: scheme,
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
  );
}
