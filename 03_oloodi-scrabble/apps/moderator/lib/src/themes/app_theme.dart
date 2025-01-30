import 'package:flutter/material.dart';

// Original
class AppTheme123445 {
  static const primaryColor = Color(0xFF1E4B5F);
  static const secondaryColor = Color(0xFF3C7A89);
  static const accentColor = Color(0xFFEBA63F);
  static const backgroundColor = Color(0xFFF5F5F5);
  
  static ThemeData get theme => ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: primaryColor,
      selectedItemColor: accentColor,
      unselectedItemColor: Colors.white70,
    ),
  );
}

// Modern Dark Theme
class AppTheme {
  static const primaryColor = Color(0xFF1A1A2E);
  static const secondaryColor = Color(0xFF16213E);
  static const accentColor = Color(0xFF00FF95);
  static const backgroundColor = Color(0xFF0F0F1A);
  
  static ThemeData get theme => ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: accentColor),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: primaryColor,
      selectedItemColor: accentColor,
      unselectedItemColor: Colors.white54,
    ),
  );
}

// Minimal Light theme 
class AppTheme12345 {
  static const primaryColor = Color(0xFFF8F9FA);
  static const secondaryColor = Color(0xFFE9ECEF);
  static const accentColor = Color(0xFF6C63FF);
  static const backgroundColor = Colors.white;
  
  static ThemeData get theme => ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: accentColor),
      titleTextStyle: TextStyle(
        color: Color(0xFF2D3436),
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: primaryColor,
      selectedItemColor: accentColor,
      unselectedItemColor: Color(0xFF95A5A6),
    ),
  );
}

// Natue-inspired Theme
class AppTheme1234 {
  static const primaryColor = Color(0xFF2D5A27);
  static const secondaryColor = Color(0xFF4A8B3C);
  static const accentColor = Color(0xFFFFC857);
  static const backgroundColor = Color(0xFFF7F7F2);
  
  static ThemeData get theme => ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: primaryColor,
      selectedItemColor: accentColor,
      unselectedItemColor: Colors.white70,
    ),
  );
}
