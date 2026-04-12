import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../controllers/app_controller.dart';
import 'widgets/profile_menu_item.dart';
import 'widgets/profile_stat_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AppController>();
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
            // Profile card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.shadowCard,
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundImage:
                        CachedNetworkImageProvider(ctrl.userAvatar.value),
                  ),
                  const SizedBox(height: 12),
                  Obx(() => Text(ctrl.userName.value,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800))),
                  const SizedBox(height: 4),
                  Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on,
                              size: 14, color: AppTheme.mutedForeground),
                          Text(ctrl.userLocation.value,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.mutedForeground)),
                        ],
                      )),
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
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(160, 40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Modifier le profil'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Stats
            const Row(
              children: [
                ProfileStatCard(value: '3', label: 'Annonces'),
                SizedBox(width: 10),
                ProfileStatCard(value: '12', label: 'Ventes'),
                SizedBox(width: 10),
                ProfileStatCard(value: '4.8★', label: 'Note'),
              ],
            ),
            const SizedBox(height: 16),
            // Menu
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
              onTap: () => Get.toNamed('/dashboard'),
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
            GestureDetector(
              onTap: () => Get.offAllNamed('/auth'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: AppTheme.destructive.withValues(alpha: 0.3)),
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
