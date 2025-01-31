// lib/src/themes/app_themes.dart

import 'package:flutter/material.dart';
import 'package:oloodi_scrabble_end_user_app/src/providers/settings_provider.dart';

// Static access to theme instances
class AppTheme {
  static final dark = DarkTheme();
  static final light = LightTheme();
  static final nature = NatureTheme();

  static ThemeData getThemeData(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.dark:
        return dark.theme;
      case AppThemeMode.light:
        return light.theme;
      case AppThemeMode.nature:
        return nature.theme;
    }
  }
}

abstract class AppThemeBase {
  // Abstract getters that all themes must implement
  Color get primaryColor;
  Color get secondaryColor;
  Color get accentColor;
  Color get backgroundColor;

  // Common theme data builder
  ThemeData get theme => ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: accentColor),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: primaryColor,
          selectedItemColor: accentColor,
          unselectedItemColor: Colors.white54,
        ),
        // Add more common theme properties
        cardColor: primaryColor,
        dividerColor: Colors.white24,
        colorScheme: ColorScheme.dark(
          primary: primaryColor,
          secondary: secondaryColor,
          tertiary: accentColor,
          background: backgroundColor,
        ),
      );
}

// Dark Theme (Modern & High Contrast)
class DarkTheme extends AppThemeBase {
  @override
  Color get primaryColor => const Color(0xFF1E1E2D); // Darker navy

  @override
  Color get secondaryColor => const Color(0xFF2D2D44); // Deep purple-grey

  @override
  Color get accentColor => const Color(0xFF00E5FF); // Bright cyan

  @override
  Color get backgroundColor => const Color(0xFF15151F); // Very dark navy

  @override
  ThemeData get theme => ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        cardColor: secondaryColor,
        dividerColor: const Color(0xFF3F3F5F),
        colorScheme: ColorScheme.dark(
          primary: primaryColor,
          secondary: secondaryColor,
          tertiary: accentColor,
          background: backgroundColor,
          surface: const Color(0xFF252537),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white,
        ),
      );
}

// Light Theme (Clean & Professional)
class LightTheme extends AppThemeBase {
  @override
  Color get primaryColor => const Color(0xFFFFFFFF); // Pure white

  @override
  Color get secondaryColor => const Color(0xFFF5F5F7); // Light grey

  @override
  Color get accentColor => const Color(0xFF2563EB); // Royal blue

  @override
  Color get backgroundColor => const Color(0xFFFAFAFA); // Off-white

  @override
  ThemeData get theme => ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        cardColor: primaryColor,
        dividerColor: const Color(0xFFE5E7EB),
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          secondary: secondaryColor,
          tertiary: accentColor,
          background: backgroundColor,
          surface: const Color(0xFFFFFFFF),
          onPrimary: const Color(0xFF1F2937), // Dark grey
          onSecondary: const Color(0xFF1F2937),
          onSurface: const Color(0xFF1F2937),
          onBackground: const Color(0xFF1F2937),
        ),
      );
}

// Nature Theme (Forest & Fresh)
class NatureTheme extends AppThemeBase {
  @override
  Color get primaryColor => const Color(0xFF1B4332); // Deep forest green

  @override
  Color get secondaryColor => const Color(0xFF2D6A4F); // Rich emerald

  @override
  Color get accentColor => const Color(0xFFFBB91C); // Golden yellow

  @override
  Color get backgroundColor => const Color(0xFF081C15); // Dark forest

  @override
  ThemeData get theme => ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        cardColor: secondaryColor,
        dividerColor: const Color(0xFF40916C),
        colorScheme: ColorScheme.dark(
          primary: primaryColor,
          secondary: secondaryColor,
          tertiary: accentColor,
          background: backgroundColor,
          surface: const Color(0xFF2D6A4F),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white,
        ),
      );
}
