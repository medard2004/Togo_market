import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Palette principale ──────────────────────────────────────────────────────
  static const Color primary = Color(0xFFF9591F);        // Corail-orange
  static const Color primaryLight = Color(0xFFFEEEE8);   // Primaire clair
  static const Color primaryMuted = Color(0xFFF4A98A);   // Primaire atténué
  static const Color secondary = Color(0xFF5D4A66);      // Prune douce
  static const Color secondaryLight = Color(0xFFEDE8F0); // Secondaire clair
  static const Color background = Color(0xFFFCF9F8);     // Blanc cassé chaud
  static const Color foreground = Color(0xFF1C110D);     // Brun foncé
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFFF3EEE9);
  static const Color mutedForeground = Color(0xFF726660);
  static const Color accent = Color(0xFFFEEEE8);
  static const Color accentForeground = Color(0xFFD4451A);
  static const Color destructive = Color(0xFFE53E3E);
  static const Color green = Color(0xFF16A34A);         // Vert positif
  static const Color red = Color(0xFFEF4444);           // Rouge négatif
  static const Color border = Color(0xFFE8E0DA);

  // ── Ombres ──────────────────────────────────────────────────────────────────
  static List<BoxShadow> shadowCard = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowCardLg = [
    BoxShadow(
      color: Colors.black.withOpacity(0.10),
      blurRadius: 24,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowPrimary = [
    BoxShadow(
      color: const Color(0xFFE8523A).withOpacity(0.25),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // ── ThemeData ────────────────────────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: primary,
          secondary: secondary,
          surface: cardColor,
          error: destructive,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: foreground,
        ),
        scaffoldBackgroundColor: background,
        cardColor: cardColor,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          const TextTheme(
            displayLarge: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: foreground,
            ),
            displayMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
            headlineMedium: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
            titleLarge: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
            titleMedium: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
            bodyLarge: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: foreground,
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: foreground,
            ),
            bodySmall: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: mutedForeground,
            ),
            labelLarge: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: foreground),
          titleTextStyle: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: foreground,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            minimumSize: const Size(double.infinity, 56),
            textStyle: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: const BorderSide(color: primary, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            minimumSize: const Size(double.infinity, 56),
            textStyle: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: muted,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          hintStyle: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            color: mutedForeground,
            fontSize: 14,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: border,
          thickness: 1,
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      );
}
