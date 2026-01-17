import 'package:flutter/material.dart';

class AppColors {
  // Predefined theme colors
  static const List<ColorOption> themeColors = [
    ColorOption(name: 'Purple', color: Color(0xFF6750A4)),
    ColorOption(name: 'Blue', color: Color(0xFF1976D2)),
    ColorOption(name: 'Green', color: Color(0xFF388E3C)),
    ColorOption(name: 'Orange', color: Color(0xFFF57C00)),
    ColorOption(name: 'Red', color: Color(0xFFD32F2F)),
    ColorOption(name: 'Teal', color: Color(0xFF00796B)),
    ColorOption(name: 'Pink', color: Color(0xFFC2185B)),
    ColorOption(name: 'Indigo', color: Color(0xFF303F9F)),
  ];

  static Color getColorFromValue(int value) {
    return Color(value);
  }
}

class ColorOption {
  final String name;
  final Color color;

  const ColorOption({required this.name, required this.color});
}
