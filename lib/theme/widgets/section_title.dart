import 'package:flutter/material.dart';
import '../../utils/responsive.dart';
import '../app_theme.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;
  final Color? iconColor;

  const SectionTitle({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: r.fs(18), color: iconColor ?? AppTheme.foreground),
                SizedBox(width: r.s(8)),
              ],
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: r.fs(16),
                      fontWeight: FontWeight.w700,
                      color: AppTheme.foreground),
                ),
              ),
            ],
          ),
        ),
        if (actionLabel != null) ...[
          SizedBox(width: r.s(8)),
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: TextStyle(
                  fontSize: r.fs(13),
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary),
            ),
          ),
        ],
      ],
    );
  }
}
