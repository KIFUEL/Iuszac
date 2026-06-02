import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LawTheme {
  static const primaryColor = Color(0xFF1A237E); // Navy Blue
  static const accentColor = Color(0xFFC5A059);  // Gold/Bronze
  static const backgroundColor = Color(0xFFF5F5F5);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: accentColor,
        surface: Colors.white,
      ),
      textTheme: GoogleFonts.latoTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: primaryColor,
        selectedIconTheme: IconThemeData(color: accentColor),
        unselectedIconTheme: IconThemeData(color: Colors.white70),
        selectedLabelTextStyle: TextStyle(color: accentColor),
        unselectedLabelTextStyle: TextStyle(color: Colors.white70),
      ),
    );
  }
}
