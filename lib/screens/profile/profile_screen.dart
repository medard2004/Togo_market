import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../Api/provider/auth_controller.dart';
import '../../widgets/user_avatar.dart';
import '../../controllers/app_controller.dart';
import 'widgets/profile_menu_item.dart';
import 'widgets/profile_stat_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.cardColor,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.08),
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
        ),
        title: const Text(
          'Profil',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: AppTheme.foreground,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () => Get.toNamed('/settings'),
              icon: const Icon(Icons.settings_outlined,
                  color: AppTheme.foreground),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: AppTheme.shadowCard,
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() {
                        final user = authCtrl.currentUser.value;
                        return UserAvatar(
                          url: user?.avatarUrl,
                          name: user?.nom ?? '',
                          radius: 40,
                        );
                      }),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 12),
                            Obx(() {
                              final user = authCtrl.currentUser.value;
                              return Text(user?.nom ?? 'Utilisateur',
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.foreground));
                            }),
                            const SizedBox(height: 6),
                            Obx(() {
                              final user = authCtrl.currentUser.value;
                              final phone = user?.telephone ?? '';
                              final displayPhone = phone.startsWith('tmp_') ? 'Aucun numéro' : phone;
                              final email = user?.email ?? '';

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (email.isNotEmpty)
                                    Text(
                                      email,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: AppTheme.mutedForeground),
                                    ),
                                  if (displayPhone.isNotEmpty)
                                    Text(
                                      displayPhone,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: AppTheme.mutedForeground),
                                    )
                                  else if (email.isEmpty) // Si les deux sont vides
                                    const Text(
                                      'Aucun contact',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: AppTheme.mutedForeground),
                                    )
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Obx(() {
                      final user = authCtrl.currentUser.value;
                      final isIncomplete =
                          user == null || user.needsOnboardingProfile;
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => Get.toNamed(isIncomplete ? '/profile-setup' : '/edit-profile'),
                          icon: Icon(isIncomplete ? Icons.person_add : Icons.edit, size: 18),
                          label: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(isIncomplete ? 'Compléter le profil' : 'Modifier le profil',
                                style: const TextStyle(fontSize: 15)),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'MON COMPTE',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.mutedForeground,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(28),
                boxShadow: AppTheme.shadowCard,
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  ProfileMenuItem(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Mes commandes',
                    badge: '3',
                    onTap: () => Get.toNamed('/orders'),
                    flat: true,
                  ),
                  const Divider(height: 1, color: AppTheme.border),
                  Obx(() {
                    final favCount =
                        Get.find<AppController>().favorites.length;
                    return ProfileMenuItem(
                      icon: Icons.favorite_border,
                      label: 'Mes favoris',
                      badge: '$favCount',
                      onTap: () => Get.toNamed('/favorites'),
                      flat: true,
                    );
                  }),
                  const Divider(height: 1, color: AppTheme.border),
                  ProfileMenuItem(
                    icon: Icons.inventory_2_outlined,
                    label: 'Mes annonces',
                    badge: '12',
                    onTap: () => Get.toNamed('/dashboard'),
                    flat: true,
                  ),
                  const Divider(height: 1, color: AppTheme.border),
                  ProfileMenuItem(
                    icon: Icons.settings_outlined,
                    label: 'Paramètres',
                    onTap: () => Get.toNamed('/settings'),
                    flat: true,
                  ),
                  const Divider(height: 1, color: AppTheme.border),
                  ProfileMenuItem(
                    icon: Icons.help_outline,
                    label: 'Aide & Support',
                    onTap: () => Get.toNamed('/help'),
                    flat: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                Get.dialog(
                  const Center(child: CircularProgressIndicator()),
                  barrierDismissible: false,
                );
                await authCtrl.logout();
                if (Get.isDialogOpen ?? false) Get.back();
                Get.offAllNamed('/auth');
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Text(
                    'Se déconnecter',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
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
