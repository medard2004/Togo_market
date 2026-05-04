import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_button_themes.dart';
import 'app_input_themes.dart';
import 'app_shadows.dart';

class AppTheme {
  static final isDarkMode = false.obs;
  static bool get _isDark => isDarkMode.value;

  // Redirects for backwards compatibility
  static const Color primary = AppColors.primary;
  static Color get primaryLight => _isDark ? const Color(0xFF2D1A12) : AppColors.primaryLight;
  static const Color primaryMuted = AppColors.primaryMuted;
  static const Color secondary = AppColors.secondary;
  static const Color secondaryLight = AppColors.secondaryLight;
  
  static Color get background => _isDark ? const Color(0xFF121212) : AppColors.background;
  static Color get foreground => _isDark ? Colors.white : AppColors.foreground;
  static Color get cardColor => _isDark ? const Color(0xFF1E1E1E) : AppColors.card;
  static Color get muted => _isDark ? const Color(0xFF2C2C2C) : AppColors.muted;
  static Color get mutedForeground => _isDark ? Colors.white70 : AppColors.mutedForeground;
  static Color get border => _isDark ? const Color(0xFF333333) : AppColors.border;
  
  static const Color destructive = AppColors.destructive;
  static const Color success = AppColors.success;
  static const Color green = AppColors.green;
  static const Color error = AppColors.error;
  static const Color red = AppColors.red;

  static List<BoxShadow> get shadowCard => AppShadows.shadowMd;
  static List<BoxShadow> get shadowCardLg => AppShadows.shadowLg;
  static List<BoxShadow> get shadowSm => AppShadows.shadowSm;
  static List<BoxShadow> get shadowPrimary => AppShadows.shadowPrimary;

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
                canvasColor: AppColors.card,
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.card,
          modalBackgroundColor: AppColors.card,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.card,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.mutedForeground,
        ),
        popupMenuTheme: const PopupMenuThemeData(
          color: AppColors.card,
        ),
        scaffoldBackgroundColor: AppColors.background,
        cardColor: AppColors.card,
        textTheme: AppTypography.textTheme,
        
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: const IconThemeData(color: AppColors.foreground),
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
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: Color(0xFF1A1A1A),
          error: AppColors.destructive,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
        ),
                canvasColor: const Color(0xFF1E1E1E),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Color(0xFF1E1E1E),
          modalBackgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1E1E1E),
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.white70,
        ),
        popupMenuTheme: const PopupMenuThemeData(
          color: Color(0xFF1E1E1E),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        textTheme: AppTypography.textTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF121212),
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: AppTypography.appBarTitle,
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFF2C2C2C),
          thickness: 1,
        ),
      );
}
