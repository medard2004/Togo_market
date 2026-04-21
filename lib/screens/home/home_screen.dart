import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../controllers/app_controller.dart';
import '../../Api/provider/auth_controller.dart';
import 'widgets/home_top_bar.dart';
import 'widgets/home_body.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            GetBuilder<AppController>(builder: (ctrl) => HomeTopBar(ctrl: ctrl)),
            Obx(() {
              final authCtrl = Get.find<AuthController>();
              final user = authCtrl.currentUser.value;

              final needsName = user == null || user.nom == null || user.nom!.isEmpty;
              final needsPhone = user == null || user.telephone.isEmpty || user.telephone.startsWith('tmp_');
              final isFirstTime = authCtrl.isFirstTime.value;

              // Show prompt if any essential profile piece is missing or onboarding not completed
              if (user != null && (needsName || needsPhone || isFirstTime)) {
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
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}
