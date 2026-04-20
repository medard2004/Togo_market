import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/responsive.dart';
import '../app_theme.dart';

class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  const AppBackButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    return GestureDetector(
      onTap: onTap ?? Get.back,
      child: Container(
        width: r.s(40), height: r.s(40),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          shape: BoxShape.circle,
          boxShadow: AppTheme.shadowCard,
        ),
        child: Icon(Icons.arrow_back_ios_new, size: r.s(17), color: AppTheme.foreground),
      ),
    );
  }
}
