import 'package:flutter/material.dart';

class AppTheme {
  // Palet Warna Citrus Fresh
  static const Color citrusOrange = Color(0xFFFF8C00); // Oranye Terang
  static const Color brightYellow = Color(0xFFFFD700); // Kuning Cerah
  static const Color leafGreen = Color(0xFF4CAF50); // Hijau Daun untuk Aksen
  static const Color ivoryWhite = Color(0xFFFFFFF0); // Putih Gading (Background)
  static const Color darkOrange = Color(0xFFE67E22); // Oranye Tua untuk Kontras
  static const Color darkGray = Color(0xFF424242);
  static const Color lightGray = Color(0xFFFAF9F6); // Putih gading terang

  // Alias untuk backward compatibility
  static const Color limeGreen = leafGreen;
  static const Color cleanWhite = ivoryWhite;
  static const Color lightGreen = leafGreen;
  static const Color darkGreen = leafGreen;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: citrusOrange,
      scaffoldBackgroundColor: ivoryWhite,
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: leafGreen,
        foregroundColor: ivoryWhite,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: ivoryWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brightYellow,
          foregroundColor: darkGray,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: citrusOrange,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ivoryWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: citrusOrange, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: leafGreen, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: citrusOrange, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2.5),
        ),
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        labelStyle: const TextStyle(color: citrusOrange, fontWeight: FontWeight.w500),
      ),

      // Text Themes
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: citrusOrange,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: darkOrange,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: darkGray,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: darkGray,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
      ),

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: citrusOrange,
        secondary: brightYellow,
        tertiary: leafGreen,
        surface: ivoryWhite,
        error: Colors.red,
      ),
    );
  }
}
