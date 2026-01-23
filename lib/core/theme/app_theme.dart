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
      
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      
      // Typography
      textTheme: TextTheme(
        // Branding / Hero
        displayLarge: GoogleFonts.dmSerifDisplay(
          fontSize: 42,
          fontWeight: FontWeight.bold,
          color: deepBlue,
        ),
        // Major Page Titles
        displayMedium: GoogleFonts.dmSerifDisplay(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: deepBlue,
        ),
        // Section Headers / Secondary Page Titles
        displaySmall: GoogleFonts.dmSerifDisplay(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: deepBlue,
        ),
        // Card Titles / Modal Headers
        headlineMedium: GoogleFonts.dmSerifDisplay(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: deepBlue,
        ),
        // Subsections
        titleLarge: GoogleFonts.dmSerifDisplay(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: deepBlue,
        ),
        // Input Labels / List Items
        titleMedium: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: deepBlue,
        ),
        // Standard Text
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: deepBlue,
        ),
        // Secondary Text
        bodyMedium: GoogleFonts.inter(
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
        titleTextStyle: GoogleFonts.dmSerifDisplay(
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
          textStyle: GoogleFonts.inter(
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
        labelStyle: GoogleFonts.inter(color: deepBlue.withAlpha(150)),
      ),
      
      snackBarTheme: SnackBarThemeData(
        backgroundColor: deepBlue,
        contentTextStyle: GoogleFonts.inter(color: cream),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      chipTheme: ChipThemeData(
        backgroundColor: sage.withAlpha(30),
        disabledColor: Colors.grey[200],
        selectedColor: sage,
        secondarySelectedColor: terracotta,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: GoogleFonts.inter(color: deepBlue, fontWeight: FontWeight.bold),
        secondaryLabelStyle: GoogleFonts.inter(color: Colors.white),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
