import 'package:flutter/material.dart';

/// Utilitaires responsives — usage:
///   final r = R(context);
///   r.s(16)   → valeur scalée proportionnellement à la largeur
///   r.fs(14)  → fontSize adaptée
///   r.cardW   → largeur carte dans scroll horizontal

class R {
  final double _screenW;
  final double _screenH;
  final double _scale;

  R(BuildContext context)
      : _screenW = MediaQuery.of(context).size.width,
        _screenH = MediaQuery.of(context).size.height,
        // Base design 390px (iPhone 14). Scale entre 0.78 et 1.25
        _scale = (MediaQuery.of(context).size.width / 390).clamp(0.78, 1.25);

  double get screenW => _screenW;
  double get screenH => _screenH;

  /// Valeur scalée (padding, margin, taille icône…)
  double s(double value) => value * _scale;

  /// FontSize scalée — légèrement clampée
  double fs(double size) =>
      (size * _scale).clamp(size * 0.82, size * 1.18);

  /// Border radius scalé
  double rad(double radius) => (radius * _scale).clamp(4, 32);

  // ── Dimensions fréquentes ─────────────────────────────────────────────────

  /// Hauteur image dans un scroll horizontal
  double get cardImageH => (_screenH * 0.17).clamp(100, 160);

  /// Largeur carte dans scroll horizontal
  double get cardW => (_screenW * 0.40).clamp(128, 175);

  /// Hauteur grille produit (ratio 4/3 de la largeur d'une colonne)
  double get gridCardH {
    final colW = (_screenW - 16 * 2 - 12) / 2; // 2 cols, padding 16, gap 12
    return colW * (4 / 3) + 58; // image + info zone
  }

  /// Hauteur BottomNav
  double get bottomNavH => (_screenH * 0.075).clamp(56, 72);

  /// Padding horizontal standard
  double get hPad => s(16);

  /// Padding vertical entre sections
  double get vGap => s(16);
}
