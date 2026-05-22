import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../controllers/app_controller.dart';
import '../../Api/provider/auth_controller.dart';
import '../../animations/togo_animation_system.dart';
import '../../utils/responsive.dart';
import 'widgets/home_top_bar.dart';
import 'widgets/home_body.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    return Obx(() => Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                GetBuilder<AppController>(builder: (ctrl) => HomeTopBar(ctrl: ctrl)),
                Obx(() {
                  final authCtrl = Get.find<AuthController>();
                  final user = authCtrl.currentUser.value;

                  // Inclut quartier / zone (API `adresses`) : indispensable après Google+téléphone sans finir l’assistant.
                  final needsProfile = user == null || user.needsOnboardingProfile;

                  if (user != null && needsProfile) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: AppTheme.primary),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Complétez votre profil pour une meilleure expérience.',
                              style: TextStyle(fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Get.toNamed('/profile-setup'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: AppTheme.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              minimumSize: const Size(60, 32),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            child: const Text('Configurer', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                Expanded(
                  child: GetBuilder<AppController>(builder: (ctrl) => HomeBody(ctrl: ctrl)),
                ),
              ],
            ),
            
            // Premium Floating Auth Prompt Banner
            Obx(() {
              final authCtrl = Get.find<AuthController>();
              final appCtrl = Get.find<AppController>();
              if (!authCtrl.isAuthenticated && appCtrl.showAuthPrompt.value) {
                return Positioned(
                  bottom: r.s(16),
                  left: r.s(16),
                  right: r.s(16),
                  child: TogoSlideUp(
                    delay: const Duration(milliseconds: 200),
                    child: _buildAuthPrompt(context, r, appCtrl),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    ));
  }

  Widget _buildAuthPrompt(BuildContext context, R r, AppController appCtrl) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withOpacity(0.85),
        borderRadius: BorderRadius.circular(r.rad(24)),
        border: Border.all(color: AppTheme.border.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(r.rad(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: EdgeInsets.all(r.s(16)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(r.s(8)),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_active_outlined,
                        size: r.s(20),
                        color: AppTheme.primary,
                      ),
                    ),
                    SizedBox(width: r.s(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Rejoignez Togo Market !",
                            style: TextStyle(
                              fontSize: r.fs(15),
                              fontWeight: FontWeight.w900,
                              color: AppTheme.foreground,
                            ),
                          ),
                          SizedBox(height: r.s(4)),
                          Text(
                            "Connectez-vous pour commander et discuter avec les vendeurs.",
                            style: TextStyle(
                              fontSize: r.fs(12.5),
                              fontWeight: FontWeight.w500,
                              color: AppTheme.mutedForeground,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => appCtrl.showAuthPrompt.value = false,
                      child: Container(
                        padding: EdgeInsets.all(r.s(4)),
                        decoration: BoxDecoration(
                          color: AppTheme.muted,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: r.s(16),
                          color: AppTheme.foreground,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: r.s(16)),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Get.toNamed('/auth'),
                        child: Container(
                          height: r.s(40),
                          decoration: BoxDecoration(
                            color: AppTheme.muted,
                            borderRadius: BorderRadius.circular(r.rad(12)),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Center(
                            child: Text(
                              "S'inscrire",
                              style: TextStyle(
                                fontSize: r.fs(13.5),
                                fontWeight: FontWeight.w700,
                                color: AppTheme.foreground,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: r.s(12)),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Get.toNamed('/auth'),
                        child: Container(
                          height: r.s(40),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.85)],
                            ),
                            borderRadius: BorderRadius.circular(r.rad(12)),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "Se connecter",
                              style: TextStyle(
                                fontSize: r.fs(13.5),
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
