// core/theme/app_theme.dart
// 
// Purpose: Centralized theme configuration for the application.
// Responsibility: Defines the "FUTO Green" color palette and standard widget styles.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF008000); // FUTO Green
  static const Color backgroundLight = Color(0xFFF5F8F8);
  static const Color backgroundDark = Color(0xFF0F2323);
  static const Color textMainLight = Color(0xFF0C1D1D);
  static const Color textMainDark = Color(0xFFE6F4E6);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: primaryColor,
        secondary: primaryColor,
        surface: surfaceLight,
      ),
      textTheme: GoogleFonts.lexendTextTheme().copyWith(
        displayLarge: GoogleFonts.lexend(
          color: textMainLight,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: GoogleFonts.notoSans(
          color: textMainLight,
        ),
        bodyMedium: GoogleFonts.notoSans(
          color: textMainLight,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // rounded-xl generally 12px
          borderSide: BorderSide(color: Color(0xFFCDEAEA)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFCDEAEA)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: EdgeInsets.all(15),
        labelStyle: GoogleFonts.notoSans(color: textMainLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // rounded-lg
          ),
          padding: EdgeInsets.symmetric(vertical: 16),
          textStyle: GoogleFonts.lexend(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      useMaterial3: true,
    );
  }
}
