import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../theme/app_theme.dart';
import '../../theme/app_colors.dart';
import '../../animations/togo_animation_system.dart';
import '../../utils/responsive.dart';
import '../../controllers/boutique_controller.dart';

class SellChoiceSheet extends StatelessWidget {
  const SellChoiceSheet({super.key});

  static void show() {
    Get.bottomSheet(
      const SellChoiceSheet(),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      elevation: 0,
      enterBottomSheetDuration: const Duration(milliseconds: 300),
      exitBottomSheetDuration: const Duration(milliseconds: 200),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = R(context);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: r.hPad),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(r.rad(45)),
            topRight: Radius.circular(r.rad(45)),
          ),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: r.s(16)),
              Container(
                width: r.s(36),
                height: r.s(4),
                decoration: BoxDecoration(
                  color: AppColors.foreground.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: r.s(28)),

              TogoSlideUp(
                child: Text(
                  'Que souhaitez-vous faire ?',
                  style: TextStyle(
                    fontSize: r.fs(22),
                    fontWeight: FontWeight.w900,
                    color: AppColors.foreground,
                    letterSpacing: -0.8,
                  ),
                ),
              ),
              SizedBox(height: r.s(32)),

              // ── Quick Actions Grid ─────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: TogoSlideUp(
                      delay: const Duration(milliseconds: 100),
                      child: _GlassActionTile(
                        title: 'Particulier',
                        subtitle: 'Vendre un objet',
                        icon: Icons.person_rounded,
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFFFFA07A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () {
                          Get.back();
                          Get.toNamed('/add-product');
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: r.s(16)),
                  Expanded(
                    child: TogoSlideUp(
                      delay: const Duration(milliseconds: 200),
                      child: _GlassActionTile(
                        title: 'Professionnel',
                        subtitle: 'Ma boutique',
                        icon: Icons.storefront_rounded,
                        gradient: const LinearGradient(
                          colors: [AppColors.secondary, Color(0xFF7E6B8F)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () async {
                          Get.back();
                          await Get.find<BoutiqueController>().goToMyBoutique();
                        },
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: r.s(40)),
              
              const TogoFadeInEntry(
                delay: Duration(milliseconds: 300),
                child: Text(
                  'Togo Market • L\'économie locale dans votre poche',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mutedForeground,
                    letterSpacing: 1.0,
                  ),
                ),
              ),

              SizedBox(height: r.s(24)),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _GlassActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = R(context);

    return TogoPressableScale(
      onTap: onTap,
      child: Container(
        height: r.s(180),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(r.rad(35)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(r.s(18)),
              decoration: BoxDecoration(
                gradient: gradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (gradient as LinearGradient).colors.first.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Icon(icon, color: Colors.white, size: r.s(32)),
            ),
            SizedBox(height: r.s(20)),
            Text(
              title,
              style: TextStyle(
                fontSize: r.fs(16),
                fontWeight: FontWeight.w900,
                color: AppColors.foreground,
              ),
            ),
            SizedBox(height: r.s(4)),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: r.fs(11),
                fontWeight: FontWeight.w600,
                color: AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
