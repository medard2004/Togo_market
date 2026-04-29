import 'package:flutter/material.dart';

class AppColors {
  // ── Palette principale ──────────────────────────────────────────────────────
  static const Color primary = Color(0xFFF9591F);        // Corail-orange
  static const Color primaryLight = Color(0xFFFEEEE8);   // Primaire clair
  static const Color primaryMuted = Color(0xFFF4A98A);   // Primaire atténué
  
  static const Color secondary = Color(0xFF5D4A66);      // Prune douce
  static const Color secondaryLight = Color(0xFFEDE8F0); // Secondaire clair
  
  static const Color background = Color(0xFFFCF9F8);     // Blanc cassé chaud
  static const Color foreground = Color(0xFF1C110D);     // Brun foncé
  
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE8E0DA);
  
  static const Color muted = Color(0xFFF3EEE9);
  static const Color mutedForeground = Color(0xFF726660);
  
  static const Color accent = Color(0xFFFEEEE8);
  static const Color accentForeground = Color(0xFFD4451A);
  
  static const Color destructive = Color(0xFFE53E3E);
  static const Color success = Color(0xFF16A34A);         // Vert positif
  static const Color green = success;
  static const Color error = Color(0xFFEF4444);           // Rouge négatif
  static const Color red = error;
  static const Color warning = Color(0xFFF59E0B);         // Ambre/Alerte
  
  static const Color slate = Color(0xFF94A3B8);           // Gris ardoise
  
  // Neutral colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;

  // ── Gradients ───────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primary,
      Color(0xFFE84D12), // Un peu plus profond
    ],
  );
}
