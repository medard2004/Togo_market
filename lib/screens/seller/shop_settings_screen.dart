import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../animations/togo_animation_system.dart';

class ShopSettingsScreen extends StatefulWidget {
  const ShopSettingsScreen({super.key});

  @override
  State<ShopSettingsScreen> createState() => _ShopSettingsScreenState();
}

class _ShopSettingsScreenState extends State<ShopSettingsScreen> {
  bool _notifOrders = true;
  bool _notifMessages = true;
  bool _notifPromos = false;
  bool _vacationMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Paramètres boutique'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Shop Header Card ──────────────────────────────────────────────
            TogoSlideUp(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.storefront,
                              color: AppTheme.primary, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Kofi Tech Shop',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.foreground,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: const [
                                  Icon(Icons.location_on_outlined,
                                      size: 14, color: AppTheme.mutedForeground),
                                  Text(' Tokoin, Lomé',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.mutedForeground)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: const [
                                  Icon(Icons.star, size: 14, color: Colors.amber),
                                  Text(' 4.8',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.primary)),
                                  Text('  •  ',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.border)),
                                  Text('3 articles',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.mutedForeground)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Divider(height: 1, color: AppTheme.border),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('3', 'Articles'),
                        _buildStatItem('24', 'Vues/Jour'),
                        _buildStatItem('98%', 'Réponse'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── MA BOUTIQUE ──────────────────────────────────────────────────
            _buildSectionTitle('MA BOUTIQUE'),
            TogoSlideUp(
              delay: const Duration(milliseconds: 100),
              child: _buildSettingsGroup([
                _buildSettingsTile(
                  icon: Icons.storefront,
                  title: 'Informations de la boutique',
                  subtitle: 'Nom, description, logo',
                  onTap: () => Get.toNamed('/shop-information'),
                ),
                _buildSettingsTile(
                  icon: Icons.location_on_outlined,
                  title: 'Zones de couverture',
                  subtitle: 'Tokoin, Adidogomé',
                  onTap: () {},
                ),
                _buildSettingsTile(
                  icon: Icons.access_time,
                  title: 'Horaires d\'ouverture',
                  subtitle: '08h - 18h, Lun-Sam',
                  onTap: () {},
                ),
                _buildSettingsTile(
                  icon: Icons.category_outlined,
                  title: 'Catégories de produits',
                  subtitle: 'Électronique',
                  onTap: () {},
                ),
              ]),
            ),
            const SizedBox(height: 24),

            // ── NOTIFICATIONS ────────────────────────────────────────────────
            _buildSectionTitle('NOTIFICATIONS'),
            TogoSlideUp(
              delay: const Duration(milliseconds: 200),
              child: _buildSettingsGroup([
                _buildSettingsTile(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Nouvelles commandes',
                  hasSwitch: true,
                  switchValue: _notifOrders,
                  onSwitchChanged: (v) => setState(() => _notifOrders = v),
                ),
                _buildSettingsTile(
                  icon: Icons.people_outline,
                  title: 'Messages clients',
                  hasSwitch: true,
                  switchValue: _notifMessages,
                  onSwitchChanged: (v) => setState(() => _notifMessages = v),
                ),
                _buildSettingsTile(
                  icon: Icons.star_border,
                  title: 'Promotions & conseils',
                  hasSwitch: true,
                  switchValue: _notifPromos,
                  onSwitchChanged: (v) => setState(() => _notifPromos = v),
                ),
              ]),
            ),
            const SizedBox(height: 24),

            // ── GESTION ───────────────────────────────────────────────────────
            _buildSectionTitle('GESTION'),
            TogoSlideUp(
              delay: const Duration(milliseconds: 300),
              child: _buildSettingsGroup([
                _buildSettingsTile(
                  icon: Icons.pause_outlined,
                  title: 'Mode vacances',
                  subtitle: 'Masque temporairement votre boutique',
                  hasSwitch: true,
                  switchValue: _vacationMode,
                  onSwitchChanged: (v) => setState(() => _vacationMode = v),
                ),
                _buildSettingsTile(
                  icon: Icons.policy_outlined,
                  title: 'Politique de retour',
                  subtitle: 'Non configurée',
                  onTap: () {},
                ),
                _buildSettingsTile(
                  icon: Icons.bar_chart_outlined,
                  title: 'Statistiques détaillées',
                  subtitle: 'Vues, ventes, performances',
                  onTap: () => Get.toNamed('/seller-stats'),
                ),
              ]),
            ),
            const SizedBox(height: 24),

            // ── AIDE ──────────────────────────────────────────────────────────
            _buildSectionTitle('AIDE'),
            TogoSlideUp(
              delay: const Duration(milliseconds: 400),
              child: _buildSettingsGroup([
                _buildSettingsTile(
                  icon: Icons.help_outline,
                  title: 'Centre d\'aide vendeur',
                  subtitle: 'FAQ, guides, contact support',
                  onTap: () {},
                ),
              ]),
            ),
            const SizedBox(height: 32),

            // ── Deactivate Button ───────────────────────────────────────────
            TogoSlideUp(
              delay: const Duration(milliseconds: 500),
              child: TogoPressableScale(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: AppTheme.destructive.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                        color: AppTheme.destructive.withOpacity(0.15)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout,
                          color: AppTheme.destructive, size: 20),
                      const SizedBox(width: 10),
                      const Text(
                        'Désactiver ma boutique',
                        style: TextStyle(
                            color: AppTheme.destructive,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String val, String lab) {
    return Column(
      children: [
        Text(val,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppTheme.primary)),
        const SizedBox(height: 4),
        Text(lab,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.mutedForeground)),
      ],
    );
  }

  Widget _buildSectionTitle(String t) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        t,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Color(0xFF9E9E9E), // Gris plus neutre comme sur la maquette
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: List.generate(children.length, (index) {
          if (index == children.length - 1) return children[index];
          return Column(
            children: [
              children[index],
              const Divider(height: 1, color: AppTheme.border, indent: 68),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    bool hasSwitch = false,
    bool switchValue = false,
    Function(bool)? onSwitchChanged,
  }) {
    return TogoPressableScale(
      onTap: hasSwitch ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppTheme.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.foreground)),
                  if (subtitle != null)
                    const SizedBox(height: 1),
                  if (subtitle != null)
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.mutedForeground)),
                ],
              ),
            ),
            if (hasSwitch)
              Switch.adaptive(
                value: switchValue,
                activeColor: AppTheme.primary,
                onChanged: onSwitchChanged,
              )
            else
              const Icon(Icons.chevron_right,
                  size: 20, color: Color(0xFFC7C7C7)),
          ],
        ),
      ),
    );
  }
}
