import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_colors.dart';
import '../../animations/togo_animation_system.dart';
import '../../utils/responsive.dart';

class SellChoiceSheet extends StatelessWidget {
  const SellChoiceSheet({super.key});

  static void show() {
    Get.bottomSheet(
      const SellChoiceSheet(),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      elevation: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = R(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(r.rad(45))),
      ),
      padding: EdgeInsets.symmetric(horizontal: r.hPad),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: r.s(12)),
            Container(
              width: r.s(40),
              height: r.s(4),
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: r.s(32)),
            
            TogoSlideUp(
              child: Text(
                'Lancer une vente',
                style: TextStyle(
                  fontSize: r.fs(26),
                  fontWeight: FontWeight.w900,
                  color: AppColors.foreground,
                  letterSpacing: -1.0,
                ),
              ),
            ),
            SizedBox(height: r.s(32)),

            // ── Option 1: Particulier ────────────────────────────────────────
            TogoSlideUp(
              delay: const Duration(milliseconds: 100),
              child: _CreativeTile(
                title: 'En tant que particulier',
                subtitle: 'Simple, direct, sans frais',
                btnLabel: 'Publier une annonce',
                icon: Icons.flash_on_rounded,
                color: AppColors.primary,
                onTap: () {
                  Get.back();
                  Get.toNamed('/add-product');
                },
              ),
            ),
            
            SizedBox(height: r.s(20)),

            // ── Option 2: Professionnel ──────────────────────────────────────
            TogoSlideUp(
              delay: const Duration(milliseconds: 200),
              child: _CreativeTile(
                title: 'En tant que professionnel',
                subtitle: 'Visibilité boostée & outils pro',
                btnLabel: 'Ouvrir ma boutique',
                icon: Icons.rocket_launch_rounded,
                color: AppColors.secondary,
                onTap: () {
                  Get.back();
                  Get.toNamed('/store-config');
                },
              ),
            ),

            SizedBox(height: r.s(40)),
          ],
        ),
      ),
    );
  }
}

class _CreativeTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String btnLabel;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CreativeTile({
    required this.title,
    required this.subtitle,
    required this.btnLabel,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = R(context);

    return TogoPressableScale(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(r.s(24)),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(r.rad(35)),
          border: Border.all(color: color.withOpacity(0.15), width: 1.5),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(r.s(12)),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: r.s(22)),
                ),
                SizedBox(width: r.s(16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: r.fs(17),
                          fontWeight: FontWeight.w900,
                          color: AppColors.foreground,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: r.fs(13),
                          fontWeight: FontWeight.w500,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: r.s(20)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: r.s(12)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(r.rad(100)),
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Text(
                btnLabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: r.fs(14),
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
