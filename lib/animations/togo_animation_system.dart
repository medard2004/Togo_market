import 'package:flutter/material.dart';

/// Constantes du design system d'animation — Togo_Market
abstract class TogoMotion {
  TogoMotion._();

  /// Fondu en entrée — sections, textes
  static const Duration fadeInEntry = Duration(milliseconds: 300);

  /// Slide up — splash (logo, progression, slogan)
  static const Duration slideUp = Duration(milliseconds: 400);

  /// Coulissant — pages, panneaux latéraux
  static const Duration coulissant = Duration(milliseconds: 300);

  /// Accordéon FAQ
  static const Duration accordion = Duration(milliseconds: 200);

  /// Micro-interactions (boutons, états)
  static const Duration microInteraction = Duration(milliseconds: 200);

  /// Dots onboarding (largeur animée)
  static const Duration dotsOnboarding = Duration(milliseconds: 300);

  /// Progress bar : pas visuel entre deux valeurs (%)
  static const Duration progressBarStep = Duration(milliseconds: 100);

  /// Timer chargement splash (+2 % / tick)
  static const Duration progressTickInterval = Duration(milliseconds: 40);

  /// Délais cascade (splash / onboarding)
  static const Duration cascade1 = Duration(milliseconds: 100);
  static const Duration cascade2 = Duration(milliseconds: 200);
  static const Duration cascade3 = Duration(milliseconds: 300);

  /// Décalage Y — fondu en entrée (8 px)
  static const double fadeInOffsetY = 8;

  /// Décalage Y — slide up (20 px)
  static const double slideUpOffsetY = 20;

  /// Accélération progressive (ease-out cubique)
  static const Curve easeProgressive = Curves.easeOutCubic;

  /// Accordéon — sortie douce
  static const Curve accordionCurve = Curves.easeOut;

  /// Barre de progression — linéaire
  static const Curve progressLinear = Curves.linear;

  /// Micro-interaction bouton
  static const double buttonPressedScale = 0.95;
}

/// 1. Fondu en entrée — opacité 0→1, translateY(8px)→0, 300 ms
class TogoFadeInEntry extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final double offsetY;

  const TogoFadeInEntry({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = TogoMotion.fadeInEntry,
    this.curve = TogoMotion.easeProgressive,
    this.offsetY = TogoMotion.fadeInOffsetY,
  });

  @override
  State<TogoFadeInEntry> createState() => _TogoFadeInEntryState();
}

class _TogoFadeInEntryState extends State<TogoFadeInEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration);
    _t = CurvedAnimation(parent: _c, curve: widget.curve);
    Future<void>.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      builder: (context, child) {
        final v = _t.value;
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, widget.offsetY * (1 - v)),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// 2. Slide up — opacité 0→1, translateY(20px)→0, 400 ms + délai optionnel
class TogoSlideUp extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final double offsetY;

  const TogoSlideUp({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = TogoMotion.slideUp,
    this.curve = TogoMotion.easeProgressive,
    this.offsetY = TogoMotion.slideUpOffsetY,
  });

  @override
  State<TogoSlideUp> createState() => _TogoSlideUpState();
}

class _TogoSlideUpState extends State<TogoSlideUp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration);
    _t = CurvedAnimation(parent: _c, curve: widget.curve);
    Future<void>.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      builder: (context, child) {
        final v = _t.value;
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, widget.offsetY * (1 - v)),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// 6. Micro-interaction — scale 0,95 au tap, 200 ms
class TogoPressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration duration;
  final double pressedScale;

  const TogoPressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.duration = TogoMotion.microInteraction,
    this.pressedScale = TogoMotion.buttonPressedScale,
  });

  @override
  State<TogoPressableScale> createState() => _TogoPressableScaleState();
}

class _TogoPressableScaleState extends State<TogoPressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1.0,
        duration: widget.duration,
        curve: TogoMotion.easeProgressive,
        child: widget.child,
      ),
    );
  }
}

/// Barre de progression : largeur animée linéairement entre chaque pas (%).
class TogoAnimatedProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final Color backgroundColor;
  final Color valueColor;
  final BorderRadius? borderRadius;

  const TogoAnimatedProgressBar({
    super.key,
    required this.value,
    this.height = 6,
    this.backgroundColor = const Color(0xFFFEEEE8),
    this.valueColor = const Color(0xFFF9591F),
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(10);
    return LayoutBuilder(
      builder: (context, c) {
        final maxW = c.maxWidth;
        final w = maxW * value.clamp(0.0, 1.0);
        return ClipRRect(
          borderRadius: radius,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                width: maxW,
                height: height,
                color: backgroundColor,
              ),
              AnimatedContainer(
                duration: TogoMotion.progressBarStep,
                curve: TogoMotion.progressLinear,
                width: w,
                height: height,
                color: valueColor,
              ),
            ],
          ),
        );
      },
    );
  }
}
