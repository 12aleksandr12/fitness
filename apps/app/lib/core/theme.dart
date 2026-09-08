import 'package:flutter/material.dart';

const Color seed = Color(0xFF2E7D4F);

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light);
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}

class Breakpoints {
  static const compact = 600.0;
  static const expanded = 900.0;

  static bool isExpanded(BoxConstraints c) => c.maxWidth >= expanded;
}
