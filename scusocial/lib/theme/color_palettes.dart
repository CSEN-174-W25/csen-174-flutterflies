import 'package:flutter/material.dart';

// Define multiple color palettes
final List<Map<String, Color>> colorPalettes = [
  // 6b9080,a4c3b2,cce3de,eaf4f4,f6fff8
  {
    'primary': const Color(0xFF6b9080), // Green
    'secondary': const Color(0xFFa4c3b2), // Sage
    'accent': const Color(0xFFcce3de), // Aqua
    'background': const Color(0xFFeaf4f4), // Light Blue
    'card': const Color(0xFFf6fff8), // Mint
    'textDark': const Color(0xFF000000), // Black
    'textLight': const Color(0xFFFFFFFF), // White
  },
  // ffb5a7,fcd5ce,f8edeb,f9dcc4,fec89a
  {
    'primary': const Color(0xFFffb5a7), // Peach
    'secondary': const Color(0xFFfcd5ce), // Pink
    'accent': const Color(0xFFf8edeb), // Cream
    'background': const Color(0xFFf9dcc4), // Beige
    'card': const Color(0xFFfec89a), // Orange
    'textDark': const Color(0xFF000000), // Black
    'textLight': const Color(0xFFFFFFFF), // White
  },
  // ccd5ae,e9edc9,fefae0,faedcd,d4a373
  {
    'primary': const Color(0xFFccd5ae), // Sage
    'secondary': const Color(0xFFe9edc9), // Light Green
    'accent': const Color(0xFFfefae0), // Cream
    'background': const Color(0xFFfaedcd), // Beige
    'card': const Color(0xFFd4a373), // Tan
    'textDark': const Color(0xFF000000), // Black
    'textLight': const Color(0xFFFFFFFF), // White
  },
  // dad7cd,a3b18a,588157,3a5a40,344e41
  {
    'primary': const Color(0xFFdad7cd), // Gray
    'secondary': const Color(0xFFa3b18a), // Sage
    'accent': const Color(0xFF588157), // Green
    'background': const Color(0xFF3a5a40), // Dark Green
    'card': const Color(0xFF344e41), // Dark Green
    'textDark': const Color(0xFF000000), // Black
    'textLight': const Color(0xFFFFFFFF), // White
  },
  // 0d1b2a,1b263b,415a77,778da9,e0e1dd
  {
    'primary': const Color(0xFF0d1b2a), // Navy
    'secondary': const Color(0xFF1b263b), // Dark Blue
    'accent': const Color(0xFF415a77), // Blue
    'background': const Color(0xFF778da9), // Light Blue
    'card': const Color(0xFFe0e1dd), // Gray
    'textDark': const Color(0xFF000000), // Black
    'textLight': const Color(0xFFFFFFFF), // White
  },
  // 03045e,0077b6,00b4d8,90e0ef,caf0f8
  {
    'primary': const Color(0xFF03045e), // Navy
    'secondary': const Color(0xFF0077b6), // Blue
    'accent': const Color(0xFF00b4d8), // Cyan
    'background': const Color(0xFF90e0ef), // Light Blue
    'card': const Color(0xFFcaf0f8), // Light Blue
    'textDark': const Color(0xFF000000), // Black
    'textLight': const Color(0xFFFFFFFF), // White
  },
  // 72bbce,8dc8d8,a7d5e1,c2e2ea,dceef3
  {
    'primary': const Color(0xFF72bbce), // Light Blue
    'secondary': const Color(0xFF8dc8d8), // Light Blue
    'accent': const Color(0xFFa7d5e1), // Light Blue
    'background': const Color(0xFFc2e2ea), // Light Blue
    'card': const Color(0xFFdceef3), // Light Blue
    'textDark': const Color(0xFF000000), // Black
    'textLight': const Color(0xFFFFFFFF), // White
  },
];

// Manually select a theme here
const int selectedThemeIndex = 0; // Change this to 1 or 2 for different themes

// Get selected theme based on the index
Map<String, Color> getSelectedPalette() {
  return colorPalettes[selectedThemeIndex];
}
