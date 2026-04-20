import 'package:flutter/material.dart';
import '../../utils/responsive.dart';
import '../../animations/togo_animation_system.dart';
import '../app_theme.dart';
import '../app_radius.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool outlined;
  final IconData? icon;
  final bool isLoading;
  final Color? color;

  const AppButton({
    super.key,
    required this.label,
    required this.onTap,
    this.outlined = false,
    this.icon,
    this.isLoading = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    final bg = color ?? AppTheme.primary;

    final box = Container(
      width: double.infinity,
      height: r.s(54).clamp(46.0, 62.0),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : bg,
        borderRadius: BorderRadius.circular(r.rad(AppRadius.lg)),
        border: outlined ? Border.all(color: bg, width: 2) : null,
        boxShadow: outlined ? null : AppTheme.shadowPrimary,
      ),
      child: Center(
        child: isLoading
            ? SizedBox(
                width: r.s(22),
                height: r.s(22),
                child: const CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: outlined ? bg : Colors.white, size: r.s(18)),
                    SizedBox(width: r.s(8)),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: r.fs(15),
                        fontWeight: FontWeight.w700,
                        color: outlined ? bg : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );

    if (isLoading) {
      return box;
    }
    return TogoPressableScale(onTap: onTap, child: box);
  }
}
