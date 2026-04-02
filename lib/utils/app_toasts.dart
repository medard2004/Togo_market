import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class AppToasts {
  static void success(BuildContext context, String title, String description) {
    toastification.dismissAll();
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      description: Text(description),
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 4),
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      borderRadius: BorderRadius.circular(12),
      boxShadow: highModeShadow,
      showProgressBar: true,
      dragToClose: true,
      closeButtonShowType: CloseButtonShowType.onHover,
    );
  }

  static void error(BuildContext context, String title, String description) {
    toastification.dismissAll();
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      description: Text(description),
      alignment: Alignment.bottomCenter,
      autoCloseDuration: const Duration(seconds: 4),
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      borderRadius: BorderRadius.circular(12),
      boxShadow: highModeShadow,
      showProgressBar: true,
      dragToClose: true,
      closeButtonShowType: CloseButtonShowType.onHover,
    );
  }

  static void info(BuildContext context, String title, String description) {
    toastification.dismissAll();
    toastification.show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.flat,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      description: Text(description),
      alignment: Alignment.bottomCenter,
      autoCloseDuration: const Duration(seconds: 4),
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      borderRadius: BorderRadius.circular(12),
      boxShadow: highModeShadow,
      showProgressBar: true,
      dragToClose: true,
      closeButtonShowType: CloseButtonShowType.onHover,
    );
  }

  static void warning(BuildContext context, String title, String description) {
    toastification.dismissAll();
    toastification.show(
      context: context,
      type: ToastificationType.warning,
      style: ToastificationStyle.flat,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      description: Text(description),
      alignment: Alignment.bottomCenter,
      autoCloseDuration: const Duration(seconds: 4),
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      borderRadius: BorderRadius.circular(12),
      boxShadow: highModeShadow,
      showProgressBar: true,
      dragToClose: true,
      closeButtonShowType: CloseButtonShowType.onHover,
    );
  }
}
