import 'package:flutter/material.dart';

class AppColors {
  // Primary (Purple/Violate)
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF5A52D5);
  static const Color primaryLight = Color(0xFF8F88FF);

  // Secondary (Teal/Mint - for calmness and action)
  static const Color secondary = Color(0xFF00BFA6);
  static const Color secondaryDark = Color(0xFF008F7A);

  // Backgrounds
  static const Color background = Color(0xFFFAFAFC);
  static const Color surface = Colors.white;
  
  // Dark Mode colors
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);

  // Status
  static const Color error = Color(0xFFFF4D4F);
  static const Color success = Color(0xFF52C41A);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6C63FF),
      Color(0xFF8F88FF),
    ],
  );
  
    static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF3F0FF),
      Color(0xFFFAFAFC),
    ],
  );
}
