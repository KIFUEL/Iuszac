import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IuzUazTheme {
  // ── Palette ──────────────────────────────────────────────
  // Primary: deep brown  |  Secondary: golden tan
  // Surface : parchment  |  Background: cream white
  static const primaryColor = Color(0xFF63380F); // Deep Brown
  static const accentColor = Color(0xFFE0C69F); // Golden Tan
  static const parchment = Color(0xFFF5E6D2); // Warm Parchment
  static const cream = Color(0xFFFAF6ED); // Cream White

  // Derived helpers
  static const _lightOnPrimary = Colors.white;
  static const _darkPrimary = Color(0xFFDEB887); // BurlyWood – legible on dark bg
  static const _darkSurface = Color(0xFF141414); // Neutral dark gray
  static const _darkCard = Color(0xFF1E1E1E); // Slightly lighter card gray

  // ───────────────────────────────────────────────────────────
  //  LIGHT THEME
  // ───────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        onPrimary: _lightOnPrimary,
        secondary: accentColor,
        onSecondary: const Color(0xFF3E2108),
        tertiary: const Color(0xFF8B6914), // warm gold accent
        surface: cream,
        onSurface: const Color(0xFF2C1A05),
        surfaceContainerHighest: parchment,
      ),
      textTheme: GoogleFonts.outfitTextTheme(),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.4,
        ),
        iconTheme: IconThemeData(color: primaryColor),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: accentColor.withValues(alpha: 0.30)),
        ),
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryColor,
          foregroundColor: _lightOnPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: parchment.withValues(alpha: 0.5),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentColor.withValues(alpha: 0.40)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB00020), width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB00020), width: 1.5),
        ),
        labelStyle: const TextStyle(
          color: Color(0xFF7A5C3A),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: const TextStyle(
          color: primaryColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: parchment,
        selectedColor: accentColor.withValues(alpha: 0.45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: accentColor.withValues(alpha: 0.30)),
        ),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: primaryColor,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: accentColor.withValues(alpha: 0.25),
        thickness: 1,
        space: 1,
      ),
      navigationRailTheme: NavigationRailThemeData(
        elevation: 0,
        backgroundColor: cream,
        indicatorColor: accentColor.withValues(alpha: 0.35),
        selectedIconTheme: const IconThemeData(color: primaryColor),
        unselectedIconTheme: IconThemeData(color: primaryColor.withValues(alpha: 0.45)),
        labelType: NavigationRailLabelType.selected,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cream,
        selectedItemColor: primaryColor,
        unselectedItemColor: primaryColor.withValues(alpha: 0.45),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primaryColor,
        unselectedLabelColor: primaryColor.withValues(alpha: 0.50),
        indicatorColor: primaryColor,
        dividerColor: accentColor.withValues(alpha: 0.20),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: parchment,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF3E2108),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────
  //  DARK THEME
  // ───────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _darkSurface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: _darkPrimary,
        onPrimary: const Color(0xFF141414),
        secondary: accentColor,
        onSecondary: const Color(0xFF141414),
        tertiary: const Color(0xFFD4A853),
        surface: _darkSurface,
        onSurface: const Color(0xFFEDE0D4),
        surfaceContainerHighest: _darkCard,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: Color(0xFFEDE0D4),
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.4,
        ),
        iconTheme: IconThemeData(color: Color(0xFFEDE0D4)),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: accentColor.withValues(alpha: 0.10)),
        ),
        color: _darkCard,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _darkPrimary,
          foregroundColor: const Color(0xFF141414),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _darkPrimary,
          side: BorderSide(color: _darkPrimary.withValues(alpha: 0.6), width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentColor.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCF6679), width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCF6679), width: 1.5),
        ),
        labelStyle: TextStyle(
          color: accentColor.withValues(alpha: 0.6),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: const TextStyle(
          color: _darkPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _darkCard,
        selectedColor: const Color(0xFF2A2520),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: accentColor.withValues(alpha: 0.12)),
        ),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: _darkPrimary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _darkPrimary,
        foregroundColor: Color(0xFF141414),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: accentColor.withValues(alpha: 0.10),
        thickness: 1,
        space: 1,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: _darkSurface,
        indicatorColor: const Color(0xFF2A2520),
        selectedIconTheme: const IconThemeData(color: _darkPrimary),
        unselectedIconTheme: IconThemeData(color: _darkPrimary.withValues(alpha: 0.45)),
        labelType: NavigationRailLabelType.selected,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _darkSurface,
        selectedItemColor: _darkPrimary,
        unselectedItemColor: _darkPrimary.withValues(alpha: 0.45),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: _darkPrimary,
        unselectedLabelColor: _darkPrimary.withValues(alpha: 0.50),
        indicatorColor: _darkPrimary,
        dividerColor: accentColor.withValues(alpha: 0.10),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _darkPrimary,
        linearTrackColor: _darkCard,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFFEDE0D4),
        contentTextStyle: const TextStyle(color: Color(0xFF141414)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _darkCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
