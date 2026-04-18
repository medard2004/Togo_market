import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_radius.dart';

class AppButtonThemes {
  static ElevatedButtonThemeData get elevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 27, 226, 43),
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          minimumSize: const Size(double.infinity, 56),
          textStyle: AppTypography.buttonText,
        ),
      );

  static OutlinedButtonThemeData get outlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 31, 249, 107),
          side: const BorderSide(
              color: Color.fromARGB(255, 31, 249, 34), width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          minimumSize: const Size(double.infinity, 56),
          textStyle: AppTypography.buttonText,
        ),
      );

  static TextButtonThemeData get textButtonTheme => TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 82, 249, 31),
          textStyle: AppTypography.buttonText.copyWith(fontSize: 14),
        ),
      );
}
