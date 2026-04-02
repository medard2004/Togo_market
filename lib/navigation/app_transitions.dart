import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Style de transition pour [togoPage].
enum TogoRouteStyle {
  /// Glissement léger + fondu + micro-zoom (écrans principaux).
  charm,

  /// Fondu doux + léger décalage vertical (splash, onboarding, auth).
  softFade,

  /// Montée depuis le bas (formulaire plein écran type feuille).
  modalLift,
}

/// 3. Coulissant — translateX(100 %) → 0, léger fondu, 300 ms (pages)
class TogoCharmTransition extends CustomTransition {
  TogoCharmTransition();

  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: curve ?? Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0),
        end: Offset.zero,
      ).animate(curved),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
        child: child,
      ),
    );
  }
}

/// 1. Fondu en entrée (routes) — opacité 0→1, translateY 8 px → 0, 300 ms
class TogoSoftFadeTransition extends CustomTransition {
  TogoSoftFadeTransition();

  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: curve ?? Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final h = MediaQuery.sizeOf(context).height;
    final dy = h > 0 ? 8.0 / h : 0.012;

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, dy),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

/// Transition type feuille modale (bas + fondu + léger scale).
class TogoModalLiftTransition extends CustomTransition {
  TogoModalLiftTransition();

  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: curve ?? Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(curved),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.97, end: 1.0).animate(curved),
          alignment: Alignment.bottomCenter,
          child: child,
        ),
      ),
    );
  }
}

/// Enregistre une route nommée GetX avec une transition Togo.
GetPage<dynamic> togoPage(
  String name,
  GetPageBuilder page, {
  TogoRouteStyle style = TogoRouteStyle.charm,
  bool fullscreenDialog = false,
}) {
  switch (style) {
    case TogoRouteStyle.softFade:
      return GetPage(
        name: name,
        page: page,
        customTransition: TogoSoftFadeTransition(),
        transitionDuration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        fullscreenDialog: fullscreenDialog,
      );
    case TogoRouteStyle.modalLift:
      return GetPage(
        name: name,
        page: page,
        customTransition: TogoModalLiftTransition(),
        transitionDuration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        fullscreenDialog: true,
      );
    case TogoRouteStyle.charm:
      return GetPage(
        name: name,
        page: page,
        customTransition: TogoCharmTransition(),
        transitionDuration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        fullscreenDialog: fullscreenDialog,
      );
  }
}
