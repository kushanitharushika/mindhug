import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        secondary: AppColors.secondary,
        background: AppColors.background,
        surface: AppColors.surface,
      ),
      
      // Typography
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins().copyWith(fontFamilyFallback: ['Noto Color Emoji', 'Arial']),
        displayMedium: GoogleFonts.poppins().copyWith(fontFamilyFallback: ['Noto Color Emoji', 'Arial']),
        displaySmall: GoogleFonts.poppins().copyWith(fontFamilyFallback: ['Noto Color Emoji', 'Arial']),
        headlineLarge: GoogleFonts.poppins().copyWith(fontFamilyFallback: ['Noto Color Emoji', 'Arial']),
        headlineMedium: GoogleFonts.poppins().copyWith(fontFamilyFallback: ['Noto Color Emoji', 'Arial']),
        headlineSmall: GoogleFonts.poppins().copyWith(fontFamilyFallback: ['Noto Color Emoji', 'Arial']),
        titleLarge: GoogleFonts.poppins().copyWith(fontFamilyFallback: ['Noto Color Emoji', 'Arial']),
        titleMedium: GoogleFonts.poppins().copyWith(fontFamilyFallback: ['Noto Color Emoji', 'Arial']),
        titleSmall: GoogleFonts.poppins().copyWith(fontFamilyFallback: ['Noto Color Emoji', 'Arial']),
        bodyLarge: GoogleFonts.poppins().copyWith(fontFamilyFallback: ['Noto Color Emoji', 'Arial']),
        bodyMedium: GoogleFonts.poppins().copyWith(fontFamilyFallback: ['Noto Color Emoji', 'Arial']),
        bodySmall: GoogleFonts.poppins().copyWith(fontFamilyFallback: ['Noto Color Emoji', 'Arial']),
      ).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      
      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: TextStyle(color: AppColors.textLight.withOpacity(0.8)),
        prefixIconColor: AppColors.textLight,
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: AppColors.primary,
        secondary: AppColors.secondary,
        background: AppColors.backgroundDark,
        surface: AppColors.surfaceDark,
        onSurface: Colors.white,
      ),
      
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.poppins().copyWith(fontFamilyFallback: ['Noto Color Emoji', 'Arial']),
        displayMedium: GoogleFonts.poppins().copyWith(fontFamilyFallback: ['Noto Color Emoji', 'Arial']),
        displaySmall: GoogleFonts.poppins().copyWith(fontFamilyFallback: ['Noto Color Emoji', 'Arial']),
        headlineLarge: GoogleFonts.poppins().copyWith(fontFamilyFallback: ['Noto Color Emoji', 'Arial']),
        headlineMedium: GoogleFonts.poppins().copyWith(fontFamilyFallback: ['Noto Color Emoji', 'Arial']),
        headlineSmall: GoogleFonts.poppins().copyWith(fontFamilyFallback: ['Noto Color Emoji', 'Arial']),
        titleLarge: GoogleFonts.poppins().copyWith(fontFamilyFallback: ['Noto Color Emoji', 'Arial']),
        titleMedium: GoogleFonts.poppins().copyWith(fontFamilyFallback: ['Noto Color Emoji', 'Arial']),
        titleSmall: GoogleFonts.poppins().copyWith(fontFamilyFallback: ['Noto Color Emoji', 'Arial']),
        bodyLarge: GoogleFonts.poppins().copyWith(fontFamilyFallback: ['Noto Color Emoji', 'Arial']),
        bodyMedium: GoogleFonts.poppins().copyWith(fontFamilyFallback: ['Noto Color Emoji', 'Arial']),
        bodySmall: GoogleFonts.poppins().copyWith(fontFamilyFallback: ['Noto Color Emoji', 'Arial']),
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      
       elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
