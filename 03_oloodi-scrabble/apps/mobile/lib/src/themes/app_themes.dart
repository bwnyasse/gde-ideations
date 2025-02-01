// lib/src/themes/app_themes.dart

import 'package:flutter/material.dart';
import 'package:oloodi_scrabble_end_user_app/src/providers/settings_provider.dart';

// Static access to theme instances
class AppTheme {
  static final dark = DarkAppleTheme();
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

class EmberTheme extends AppThemeBase {
  @override
  Color get primaryColor => const Color(0xFF0C0C0C);

  @override
  Color get secondaryColor => const Color(0xFF481E14);

  @override
  Color get accentColor => const Color(0xFF9B3922);

  @override
  Color get backgroundColor =>
      const Color(0xFFF2613F); // Very distinctive background

  @override
  ThemeData get theme => ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        cardColor: secondaryColor, // Or a slightly lighter version
        dividerColor: const Color(0xFF7A2A18), // Adjusted divider color
        colorScheme: ColorScheme.dark(
          // Dark scheme because of the primary color
          primary: primaryColor,
          secondary: secondaryColor,
          tertiary: accentColor,
          background: backgroundColor,
          surface: primaryColor, // Or secondary
          onPrimary: Colors.white, // White text on primary
          onSecondary: Colors.white, // White text on secondary
          onSurface: Colors.white, // White text on surface
          onBackground: Colors.white, // Text on background
        ),
      );
}

class FireTheme extends AppThemeBase {
  @override
  Color get primaryColor => const Color(0xFF1D1616);

  @override
  Color get secondaryColor => const Color(0xFF8E1616);

  @override
  Color get accentColor => const Color(0xFFD84040);

  @override
  Color get backgroundColor => const Color(0xFFEEEEEE);

  @override
  ThemeData get theme => ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        cardColor: Colors.white, // Or a very light version of secondaryColor
        dividerColor: const Color(0xFFC8C8C8), // A bit darker than background
        colorScheme: ColorScheme.light(
          // Light scheme because background is light
          primary: primaryColor,
          secondary: secondaryColor,
          tertiary: accentColor,
          background: backgroundColor,
          surface: Colors.white,
          onPrimary: Colors.white, // Text on primary
          onSecondary: Colors.white, // Text on secondary
          onSurface: primaryColor, // Dark text on surface
          onBackground: primaryColor, // Dark text on background
        ),
      );
}

class NatureSecondTheme extends AppThemeBase {
  @override
  Color get primaryColor => const Color(0xFF123524); // Deep forest green

  @override
  Color get secondaryColor => const Color(0xFF3E7B27); // Rich emerald

  @override
  Color get accentColor => const Color(0xFF85A947); // Golden yellow/Light Green

  @override
  Color get backgroundColor => const Color(0xFFEFE3C2); // Off-white/Light Beige

  @override
  ThemeData get theme => ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        cardColor: secondaryColor,
        dividerColor: const Color(0xFF6AA759), // Adjusted divider color
        colorScheme: ColorScheme.light(
          // Light color scheme for this theme
          primary: primaryColor,
          secondary: secondaryColor,
          tertiary: accentColor,
          background: backgroundColor,
          surface: Colors.white, // Or a very light version of primaryColor
          onPrimary: Colors.white, // White text on primary
          onSecondary: Colors.white, // White text on secondary
          onSurface: const Color(0xFF123524), // Dark text on surface
          onBackground: const Color(0xFF123524), // Dark text on background
        ),
      );
}

class DarkAppleTheme extends AppThemeBase {
  @override
  Color get primaryColor =>
      const Color(0xFF161618); // Closest to Apple's #161618

  @override
  Color get secondaryColor => const Color(0xFF212124); // Apple's #212124

  @override
  Color get accentColor =>
      const Color(0xFF00E5FF); // Keep your existing accent, or choose a new one

  @override
  Color get backgroundColor => Colors.black; // Apple's #000000

  @override
  ThemeData get theme => ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        cardColor: secondaryColor, // Use secondary for cards
        dividerColor: const Color(
            0xFF333336), // A bit lighter than secondary for dividers
        colorScheme: ColorScheme.dark(
          primary: primaryColor,
          secondary: secondaryColor,
          tertiary: accentColor,
          background: backgroundColor,
          surface:
              primaryColor, // Or secondary, experiment to see what looks best.
          onPrimary: Colors.white, // Apple uses white text on these backgrounds
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white,
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
