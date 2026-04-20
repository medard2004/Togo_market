import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_button_themes.dart';
import 'app_input_themes.dart';
import 'app_shadows.dart';

class AppTheme {
  // ── Redirects for backwards compatibility ──────────────────────────────────
  static const Color primary = AppColors.primary;
  static const Color primaryLight = AppColors.primaryLight;
  static const Color primaryMuted = AppColors.primaryMuted;
  static const Color secondary = AppColors.secondary;
  static const Color secondaryLight = AppColors.secondaryLight;
  static const Color background = AppColors.background;
  static const Color foreground = AppColors.foreground;
  static const Color cardColor = AppColors.card;
  static const Color muted = AppColors.muted;
  static const Color mutedForeground = AppColors.mutedForeground;
  static const Color border = AppColors.border;
  static const Color destructive = AppColors.destructive;
  static const Color success = AppColors.success;
  static const Color green = AppColors.green;
  static const Color error = AppColors.error;
  static const Color red = AppColors.red;

  static List<BoxShadow> shadowCard = AppShadows.shadowMd;
  static List<BoxShadow> shadowCardLg = AppShadows.shadowLg;
  static List<BoxShadow> shadowSm = AppShadows.shadowSm;
  static List<BoxShadow> shadowPrimary = AppShadows.shadowPrimary;

  static ThemeData get theme => lightTheme;

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.card,
          error: AppColors.destructive,
          onPrimary: AppColors.white,
          onSecondary: AppColors.white,
          onSurface: AppColors.foreground,
        ),
        scaffoldBackgroundColor: AppColors.background,
        cardColor: AppColors.card,
        textTheme: AppTypography.textTheme,
        
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: AppColors.foreground),
          titleTextStyle: AppTypography.appBarTitle,
        ),
        
        elevatedButtonTheme: AppButtonThemes.elevatedButtonTheme,
        outlinedButtonTheme: AppButtonThemes.outlinedButtonTheme,
        textButtonTheme: AppButtonThemes.textButtonTheme,
        
        inputDecorationTheme: AppInputThemes.inputDecorationTheme,
        
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 1,
        ),
        
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      );

  // You can easily add a darkTheme here in the future
  static ThemeData get darkTheme => lightTheme.copyWith(
    brightness: Brightness.dark,
    // Add dark mode overrides here
  );
}
