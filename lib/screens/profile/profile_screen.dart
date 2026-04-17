import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/boutique_controller.dart';
import '../../Api/provider/auth_controller.dart';
import '../../widgets/user_avatar.dart';
import 'widgets/profile_menu_item.dart';
import 'widgets/profile_stat_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appCtrl = Get.find<AppController>();
    final authCtrl = Get.find<AuthController>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Mon Profil'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Profile card ──────────────────────────────────────────────────
            Obx(() {
              final user = authCtrl.currentUser.value;
              final isComplete = user != null && user.nom != null && user.nom!.isNotEmpty;

              if (!isComplete) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.account_circle, size: 64, color: AppTheme.primary),
                      const SizedBox(height: 12),
                      const Text(
                        'Profil incomplet',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primary),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Veuillez configurer votre profil pour profiter pleinement de l\'application.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: AppTheme.primary),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Get.toNamed('/profile-setup'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(200, 44),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Configurer mon compte'),
                      ),
                    ],
                  ),
                );
              }

              final displayName = user.nom!;
              final displayPhone = user.telephone;

              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.shadowCard,
                ),
                child: Column(
                  children: [
                    UserAvatar(
                      url: user.avatarUrl,
                      name: displayName,
                      radius: 44,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      displayName,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.phone_outlined,
                            size: 14, color: AppTheme.mutedForeground),
                        const SizedBox(width: 4),
                        Text(
                          displayPhone,
                          style: const TextStyle(
                              fontSize: 13, color: AppTheme.mutedForeground),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                          5,
                          (i) => const Icon(Icons.star,
                              size: 14, color: Colors.amber)),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {
                        Get.toNamed('/profile-setup');
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(160, 40),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Modifier le profil'),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),

            // ── Menu ──────────────────────────────────────────────────────────
            ProfileMenuItem(
              icon: Icons.favorite_border,
              label: 'Mes favoris',
              onTap: () => Get.toNamed('/favorites'),
            ),
            ProfileMenuItem(
              icon: Icons.shopping_bag_outlined,
              label: 'Mes commandes',
              onTap: () => Get.toNamed('/orders'),
            ),
            ProfileMenuItem(
              icon: Icons.store_outlined,
              label: 'Espace vendeur',
              onTap: () async {
                if (Get.isRegistered<BoutiqueController>()) {
                  await BoutiqueController.to.goToMyBoutique();
                } else {
                  Get.toNamed('/dashboard');
                }
              },
            ),
            ProfileMenuItem(
              icon: Icons.settings_outlined,
              label: 'Paramètres',
              onTap: () => Get.toNamed('/settings'),
            ),
            ProfileMenuItem(
              icon: Icons.help_outline,
              label: 'Aide & Support',
              onTap: () => Get.toNamed('/help'),
            ),
            const SizedBox(height: 12),

            // ── Logout ────────────────────────────────────────────────────────
            GestureDetector(
              onTap: () async {
                // Affiche un indicateur de chargement superposé qui empêche le spam
                Get.dialog(
                  const Center(child: CircularProgressIndicator()),
                  barrierDismissible: false,
                );

                // Envoie la requête backend et efface le local storage
                await Get.find<AuthController>().logout();

                // Ferme l'indicateur
                if (Get.isDialogOpen == true) {
                  Get.back();
                }

                // Redirige vers auth
                Get.offAllNamed('/auth');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppTheme.destructive.withValues(alpha: 0.3)),
                ),
                child: const Center(
                  child: Text(
                    'Se déconnecter',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.destructive,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
    );
  }
}
