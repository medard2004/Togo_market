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
                      CircleAvatar(
                        radius: 40,
                        backgroundImage:
                            CachedNetworkImageProvider(ctrl.userAvatar.value),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() => Text(ctrl.userName.value,
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.foreground))),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    size: 14,
                                    color: AppTheme.mutedForeground),
                                const SizedBox(width: 4),
                                Obx(() => Text(ctrl.userLocation.value,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.mutedForeground))),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.email_outlined,
                                    size: 14, color: AppTheme.mutedForeground),
                                const SizedBox(width: 4),
                                Obx(() => Text(ctrl.userEmail.value,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.mutedForeground))),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.phone_outlined,
                                    size: 14, color: AppTheme.mutedForeground),
                                const SizedBox(width: 4),
                                Obx(() => Text(ctrl.userPhone.value,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.mutedForeground))),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLight,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.star,
                                      size: 16, color: AppTheme.primary),
                                  SizedBox(width: 8),
                                  Text('4.8',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.primary)),
                                  SizedBox(width: 12),
                                  Text('Membre depuis Jan 2024',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.mutedForeground)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Obx(() => Text(ctrl.userBio.value,
                      style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.mutedForeground,
                          height: 1.6),
                      textAlign: TextAlign.center)),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Get.toNamed('/edit-profile'),
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text('Modifier le profil',
                                style: TextStyle(fontSize: 15)),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          onPressed: () => Get.toNamed('/share-profile'),
                          icon: const Icon(Icons.share_outlined, color: AppTheme.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: const [
                Expanded(
                  child: ProfileStatCard(
                    icon: Icons.inventory_2_outlined,
                    value: '12',
                    label: 'Annonces',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ProfileStatCard(
                    icon: Icons.shopping_bag_outlined,
                    value: '24',
                    label: 'Ventes',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ProfileStatCard(
                    icon: Icons.star_border,
                    value: '4.8',
                    label: 'Note',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ProfileStatCard(
                    icon: Icons.remove_red_eye_outlined,
                    value: '156',
                    label: 'Vues',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
                  ProfileMenuItem(
                    icon: Icons.favorite_border,
                    label: 'Mes favoris',
                    onTap: () => Get.toNamed('/favorites'),
                    flat: true,
                  ),
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
              onTap: () => Get.offAllNamed('/auth'),
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
