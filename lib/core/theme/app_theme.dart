import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Soft Boho Color Palette
  static const Color cream = Color(0xFFF4F1DE);
  static const Color terracotta = Color(0xFFE07A5F);
  static const Color deepBlue = Color(0xFF3D405B);
  static const Color sage = Color(0xFF81B29A);
  static const Color warmYellow = Color(0xFFF2CC8F);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: terracotta,
        onPrimary: Colors.white,
        secondary: sage,
        onSecondary: Colors.white,
        tertiary: warmYellow,
        onTertiary: deepBlue,
        error: Color(0xFFD9534F),
        onError: Colors.white,
        surface: cream,
        onSurface: deepBlue,
        surfaceContainerHighest: Color(0xFFEADDCA), // Slightly darker cream for cards
      ),
      scaffoldBackgroundColor: cream,
      
      // Typography
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: deepBlue,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: deepBlue,
        ),
        titleLarge: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: deepBlue,
        ),
        titleMedium: GoogleFonts.lato(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: deepBlue,
        ),
        bodyLarge: GoogleFonts.lato(
          fontSize: 16,
          color: deepBlue,
        ),
        bodyMedium: GoogleFonts.lato(
          fontSize: 14,
          color: deepBlue.withAlpha(200),
        ),
      ),
      
      // Component Themes
      cardTheme: CardTheme(
        color: Colors.white.withAlpha(230), // Slightly transparent white
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: deepBlue.withAlpha(20), width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      ),
      
      appBarTheme: AppBarTheme(
        backgroundColor: cream,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: deepBlue,
        ),
        iconTheme: const IconThemeData(color: deepBlue),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: terracotta,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: terracotta,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: deepBlue.withAlpha(20), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: terracotta, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle: GoogleFonts.lato(color: deepBlue.withAlpha(150)),
      ),
      
      snackBarTheme: SnackBarThemeData(
        backgroundColor: deepBlue,
        contentTextStyle: GoogleFonts.lato(color: cream),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
