import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class AppLoader {
  /// Affiche le loader avec un trait de progression
  static void show(BuildContext context, {String message = 'Chargement...', required Duration duration}) {
    if (Get.isDialogOpen ?? false) return;

    Get.dialog(
      _LoaderWidget(message: message, duration: duration),
      barrierDismissible: false,
      useSafeArea: false,
      barrierColor: Colors.transparent, // Le fond est géré dans le widget
    );
  }

  /// Masque le loader
  static void hide() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  /// Exécute une tâche asynchrone avec le loader.
  /// La barre se remplit progressivement pendant `minDuration`,
  /// et on passe à l'élément suivant une fois remplie.
  static Future<T> wrap<T>(
    BuildContext context, 
    Future<T> Function() task, 
    {
      String message = 'Chargement...', 
      Duration minDuration = const Duration(milliseconds: 1500)
    }
  ) async {
    show(context, message: message, duration: minDuration);
    
    // Démarre la tâche et le minuteur minimal en parallèle
    final taskFuture = task();
    final delayFuture = Future.delayed(minDuration);
    
    try {
      final result = await taskFuture;
      await delayFuture; // On attend que la barre soit bien remplie au minimum
      return result;
    } finally {
      hide();
    }
  }
}

class _LoaderWidget extends StatefulWidget {
  final String message;
  final Duration duration;

  const _LoaderWidget({required this.message, required this.duration});

  @override
  State<_LoaderWidget> createState() => _LoaderWidgetState();
}

class _LoaderWidgetState extends State<_LoaderWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward(); // Remplissage progressif
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppTheme.background, // Prend tout l'écran avec la couleur de fond
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: r.s(40)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: r.fs(16), 
                    fontWeight: FontWeight.w700, 
                    color: AppTheme.foreground
                  )
                ),
                SizedBox(height: r.s(24)),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return LinearProgressIndicator(
                        value: _controller.value, // Valeur déterminée de 0.0 à 1.0
                        backgroundColor: AppTheme.primaryLight,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                        minHeight: r.s(6),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
