import 'package:flutter/material.dart';

// Define multiple color palettes
final List<Map<String, Color>> colorPalettes = [
  {
    'primary': const Color(0xFFFF99C8), // Pink
    'secondary': const Color(0xFFFCF6BD), // Soft Yellow
    'accent': const Color(0xFFD0F4DE), // Green
    'background': const Color(0xFFA9DEF9), // Light Blue
    'card': const Color(0xFFE4C1F9), // Soft Purple
  },
  {
    'primary': const Color(0xFF264653), // Deep Blue
    'secondary': const Color(0xFF2A9D8F), // Teal
    'accent': const Color(0xFFE9C46A), // Gold
    'background': const Color(0xFFF4A261), // Orange
    'card': const Color(0xFFE76F51), // Coral
  },
  {
    'primary': const Color(0xFF3D348B), // Dark Purple
    'secondary': const Color(0xFF8675A9), // Lavender
    'accent': const Color(0xFF5DB7DE), // Sky Blue
    'background': const Color(0xFFF6E7CB), // Beige
    'card': const Color(0xFFEC91A3), // Soft Pink
  },
  // 8e9aaf,cbc0d3,efd3d7,feeafa,dee2ff
  {
    'primary': const Color(0xFF8e9aaf), // Gray
    'secondary': const Color(0xFFcbc0d3), // Lavender
    'accent': const Color(0xFFefd3d7), // Pink
    'background': const Color(0xFFfeeafa), // Cream
    'card': const Color(0xFFdee2ff), // Light Blue
  },
  // f6bd60,f7ede2,f5cac3,84a59d,f28482
  {
    'primary': const Color(0xFFf6bd60), // Orange
    'secondary': const Color(0xFFf7ede2), // Cream
    'accent': const Color(0xFFf5cac3), // Pink
    'background': const Color(0xFF84a59d), // Teal
    'card': const Color(0xFFf28482), // Coral
  },
  // 6b9080,a4c3b2,cce3de,eaf4f4,f6fff8
  {
    'primary': const Color(0xFF6b9080), // Green
    'secondary': const Color(0xFFa4c3b2), // Sage
    'accent': const Color(0xFFcce3de), // Aqua
    'background': const Color(0xFFeaf4f4), // Light Blue
    'card': const Color(0xFFf6fff8), // Mint
  },
];

// Manually select a theme here
const int selectedThemeIndex = 5; // Change this to 1 or 2 for different themes

// Get selected theme based on the index
Map<String, Color> getSelectedPalette() {
  return colorPalettes[selectedThemeIndex];
}
