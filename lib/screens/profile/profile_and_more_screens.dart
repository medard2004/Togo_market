import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/common_widgets.dart';
import '../../controllers/app_controller.dart';
import '../../data/mock_data.dart';

// ── Profile Screen ────────────────────────────────────────────────────────────
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
                    ),
                    child: const Text('Modifier le profil'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Stats
            Row(
              children: [
                _StatCard('3', 'Annonces'),
                const SizedBox(width: 10),
                _StatCard('12', 'Ventes'),
                const SizedBox(width: 10),
                _StatCard('4.8★', 'Note'),
              ],
            ),
            const SizedBox(height: 16),
            // Menu
            _MenuItem(
              icon: Icons.favorite_border,
              label: 'Mes favoris',
              onTap: () => Get.toNamed('/favorites'),
            ),
            _MenuItem(
              icon: Icons.shopping_bag_outlined,
              label: 'Mes commandes',
              onTap: () => Get.toNamed('/orders'),
            ),
            _MenuItem(
              icon: Icons.store_outlined,
              label: 'Espace vendeur',
              onTap: () => Get.toNamed('/dashboard'),
            ),
            _MenuItem(
              icon: Icons.settings_outlined,
              label: 'Paramètres',
              onTap: () => Get.toNamed('/settings'),
            ),
            _MenuItem(
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
                  border: Border.all(color: AppTheme.destructive.withOpacity(0.3)),
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

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard(this.value, this.label);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.shadowCard,
          ),
          child: Column(
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.mutedForeground)),
            ],
          ),
        ),
      );
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.shadowCard,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: AppTheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(label,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600))),
              const Icon(Icons.chevron_right, color: AppTheme.mutedForeground),
            ],
          ),
        ),
      );
}

// ── Notifications Screen ──────────────────────────────────────────────────────
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: const BackButton(),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: mockNotifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final notif = mockNotifications[i];
          IconData icon;
          Color iconColor;
          switch (notif.type) {
            case 'message':
              icon = Icons.chat_bubble_outline;
              iconColor = AppTheme.primary;
              break;
            case 'order':
              icon = Icons.shopping_bag_outlined;
              iconColor = AppTheme.secondary;
              break;
            default:
              icon = Icons.favorite_border;
              iconColor = Colors.red;
          }
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: notif.isRead ? AppTheme.cardColor : AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(16),
              border: notif.isRead
                  ? Border.all(color: AppTheme.border)
                  : Border.all(
                      color: AppTheme.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notif.title,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(notif.body,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.mutedForeground)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    Text(notif.time,
                        style: const TextStyle(
                            fontSize: 10, color: AppTheme.mutedForeground)),
                    if (!notif.isRead)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: AppTheme.primary, shape: BoxShape.circle),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Favorites Screen ──────────────────────────────────────────────────────────
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AppController>();
    return Scaffold(
        resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Mes Favoris'),
        leading: const BackButton(),
      ),
      body: Obx(() {
        final favs = ctrl.favorites;
        if (favs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('❤️', style: TextStyle(fontSize: 48)),
                SizedBox(height: 12),
                Text('Aucun favori pour l\'instant',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.65,
          ),
          itemCount: favs.length,
          itemBuilder: (_, i) => ProductCard(product: favs[i]),
        );
      }),
    );
  }
}

// ── Settings Screen ───────────────────────────────────────────────────────────
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifs = true;
  bool _location = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Paramètres'),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _SettingsTile(
              icon: Icons.person_outline,
              label: 'Modifier le profil',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.lock_outline,
              label: 'Confidentialité',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              trailing: Switch.adaptive(
                value: _notifs,
                activeColor: AppTheme.primary,
                onChanged: (v) => setState(() => _notifs = v),
              ),
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.location_on_outlined,
              label: 'Localisation',
              trailing: Switch.adaptive(
                value: _location,
                activeColor: AppTheme.primary,
                onChanged: (v) => setState(() => _location = v),
              ),
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.language,
              label: 'Langue',
              subtitle: 'Français',
              onTap: () {},
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Get.offAllNamed('/auth'),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.destructive.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppTheme.destructive.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.destructive.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.logout,
                          color: AppTheme.destructive, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text('Se déconnecter',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.destructive)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Togo_Market v1.0.0 — 🇹🇬 Fait au Togo',
                style: TextStyle(
                    fontSize: 12, color: AppTheme.mutedForeground)),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.shadowCard,
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: AppTheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    if (subtitle != null)
                      Text(subtitle!,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.mutedForeground)),
                  ],
                ),
              ),
              trailing ??
                  const Icon(Icons.chevron_right,
                      color: AppTheme.mutedForeground),
            ],
          ),
        ),
      );
}

// ── Help Screen ───────────────────────────────────────────────────────────────
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int? _expanded;

  final _faqs = [
    (
      'Comment publier une annonce ?',
      'Appuyez sur le bouton "Vendre" en bas de l\'écran, remplissez le formulaire avec les infos du produit et publiez votre annonce gratuitement.'
    ),
    (
      'Comment contacter un vendeur ?',
      'Cliquez sur "Discuter avec le vendeur" depuis la page produit pour démarrer une conversation directe.'
    ),
    (
      'Comment payer en toute sécurité ?',
      'Nous recommandons de payer en personne lors du retrait. N\'envoyez jamais d\'argent avant d\'avoir reçu le produit.'
    ),
    (
      'Comment signaler un problème ?',
      'Utilisez le bouton "Signaler" sur la page du produit ou contactez notre support via le chat d\'aide.'
    ),
    (
      'Comment modifier mon profil ?',
      'Allez dans Profil → Modifier le profil. Vous pouvez changer votre nom, photo et zone de livraison.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Aide & Support'),
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _faqs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final faq = _faqs[i];
                return GestureDetector(
                  onTap: () =>
                      setState(() => _expanded = _expanded == i ? null : i),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.shadowCard,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(faq.$1,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                            ),
                            Icon(
                              _expanded == i
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: AppTheme.mutedForeground,
                            ),
                          ],
                        ),
                        if (_expanded == i) ...[
                          const SizedBox(height: 10),
                          Text(faq.$2,
                              style: const TextStyle(
                                  fontSize: 13, height: 1.5,
                                  color: AppTheme.mutedForeground)),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                16, 0, 16, MediaQuery.of(context).padding.bottom + 16),
            child: AppButton(
              label: '💬 Contacter le support',
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}

// ── Orders Screen ─────────────────────────────────────────────────────────────
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Mes Commandes'),
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          // Tab pills
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.muted,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(child: _TabPill('Achats', 0, _tab, (v) => setState(() => _tab = v))),
                  Expanded(child: _TabPill('Ventes', 1, _tab, (v) => setState(() => _tab = v))),
                ],
              ),
            ),
          ),
          // Orders list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 2,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final product = mockProducts[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.shadowCard,
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: product.image,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.title,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600)),
                            Text(formatPrice(product.price),
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.primary)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: i == 0
                                    ? Colors.amber.withOpacity(0.15)
                                    : Colors.green.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                i == 0 ? 'En attente' : 'Acceptée',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: i == 0 ? Colors.orange : Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.toNamed('/chat/c1'),
                        child: const Icon(Icons.chat_bubble_outline,
                            color: AppTheme.primary),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final int index;
  final int current;
  final Function(int) onTap;

  const _TabPill(this.label, this.index, this.current, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: current == index ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: current == index ? Colors.white : AppTheme.mutedForeground,
              ),
            ),
          ),
        ),
      );
}

// ── Dashboard Screen ──────────────────────────────────────────────────────────
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _tab = 0;
  final _dashCtrl = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Espace Vendeur'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Tabs
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.muted,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  for (final t in ['Articles', 'Ajouter', 'Commandes', 'Messages'])
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (t == 'Ajouter') {
                            Get.toNamed('/add-product');
                          } else {
                            setState(() => _tab = ['Articles', 'Ajouter', 'Commandes', 'Messages'].indexOf(t));
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.all(4),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _tab == ['Articles', 'Ajouter', 'Commandes', 'Messages'].indexOf(t)
                                ? AppTheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              t,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _tab == ['Articles', 'Ajouter', 'Commandes', 'Messages'].indexOf(t)
                                    ? Colors.white
                                    : AppTheme.mutedForeground,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Content
          Expanded(
            child: _tab == 0
                ? _ArticlesTab(ctrl: _dashCtrl)
                : _tab == 2
                    ? _OrdersTab()
                    : _tab == 3
                        ? _MessagesTab()
                        : const SizedBox.shrink(),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}

class _ArticlesTab extends StatelessWidget {
  final DashboardController ctrl;
  const _ArticlesTab({required this.ctrl});

  @override
  Widget build(BuildContext context) => Obx(() => ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: ctrl.myProducts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final p = ctrl.myProducts[i];
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.shadowCard,
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: p.image,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.title,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      Text(formatPrice(p.price),
                          style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      size: 18, color: AppTheme.primary),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: AppTheme.destructive),
                  onPressed: () => ctrl.deleteProduct(p.id),
                ),
              ],
            ),
          );
        },
      ));
}

class _OrdersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 2,
        itemBuilder: (_, i) {
          final p = mockProducts[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.shadowCard,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Acheteur: Kwame A.',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.mutedForeground)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.green.withOpacity(0.3)),
                          ),
                          child: const Center(
                            child: Text('✓ Accepter',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.destructive.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppTheme.destructive.withOpacity(0.3)),
                          ),
                          child: const Center(
                            child: Text('✗ Refuser',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.destructive)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
}

class _MessagesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockConversations.length,
        itemBuilder: (_, i) {
          final c = mockConversations[i];
          final seller = getSellerById(c.sellerId);
          return GestureDetector(
            onTap: () => Get.toNamed('/chat/${c.id}'),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.shadowCard,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: seller != null
                        ? CachedNetworkImageProvider(seller.avatar)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(seller?.shopName ?? '',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                        Text(c.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.mutedForeground)),
                      ],
                    ),
                  ),
                  Text(c.time,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.mutedForeground)),
                ],
              ),
            ),
          );
        },
      );
}

// ── Add Product Screen ────────────────────────────────────────────────────────
class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  String _condition = 'Neuf';
  String _priceType = 'Fixe';
  String _category = 'electronique';
  bool _showZones = false;
  final Set<String> _selectedZones = {};

  final _zones = [
    'Tokoin', 'Avépozo', 'Adidogomé', 'Bè', 'Kégué',
    'Nyékonakpoè', 'Agbalépédo', 'Amadahomé', 'Agoè', 'Legbassito',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Ajouter un produit'),
        leading: const BackButton(),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Brouillons',
                style: TextStyle(color: AppTheme.mutedForeground)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photos
            const Text('Photos',
                style:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.primary, style: BorderStyle.solid),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt_outlined,
                          color: AppTheme.primary),
                      const Text('1/5',
                          style: TextStyle(
                              fontSize: 11, color: AppTheme.primary)),
                    ],
                  ),
                ),
                ...List.generate(
                  4,
                  (_) => Container(
                    decoration: BoxDecoration(
                      color: AppTheme.muted,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border, style: BorderStyle.solid),
                    ),
                    child: const Icon(Icons.add,
                        color: AppTheme.mutedForeground),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Title
            const Text('Titre',
                style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(hintText: 'Ex: iPhone 13 128GB'),
            ),
            const SizedBox(height: 16),
            // Price + Category
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Prix (FCFA)',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      const TextField(
                        keyboardType: TextInputType.number,
                        decoration:
                            InputDecoration(hintText: '0'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Catégorie',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.border),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _category,
                            isExpanded: true,
                            items: mockCategories
                                .where((c) => c.id != 'all')
                                .map((c) => DropdownMenuItem(
                                      value: c.id,
                                      child: Text(
                                        '${c.emoji} ${c.label}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _category = v!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Price type toggle
            const Text('Type de prix',
                style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final t in [('Fixe', '⚡'), ('Négociable', '🤝')])
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _priceType = t.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(right: t.$1 == 'Fixe' ? 6 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _priceType == t.$1
                              ? AppTheme.primaryLight
                              : AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _priceType == t.$1
                                ? AppTheme.primary
                                : AppTheme.border,
                            width: _priceType == t.$1 ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${t.$2} ${t.$1}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _priceType == t.$1
                                  ? AppTheme.primary
                                  : AppTheme.foreground,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Condition
            const Text('État',
                style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final c in ['Neuf', 'Occasion'])
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _condition = c),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(right: c == 'Neuf' ? 6 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _condition == c
                              ? AppTheme.primaryLight
                              : AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _condition == c
                                ? AppTheme.primary
                                : AppTheme.border,
                            width: _condition == c ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            c,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _condition == c
                                  ? AppTheme.primary
                                  : AppTheme.foreground,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Description
            const Text('Description',
                style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Décrivez votre produit en détail...',
              ),
            ),
            const SizedBox(height: 16),
            // Zones
            GestureDetector(
              onTap: () => setState(() => _showZones = !_showZones),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: AppTheme.primary),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('Zones de vente',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                    Icon(
                      _showZones
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppTheme.mutedForeground,
                    ),
                  ],
                ),
              ),
            ),
            if (_showZones) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  if (_selectedZones.length == _zones.length) {
                    setState(() => _selectedZones.clear());
                  } else {
                    setState(() => _selectedZones.addAll(_zones));
                  }
                },
                child: Text(
                  _selectedZones.length == _zones.length
                      ? 'Tout désélectionner'
                      : 'Tout sélectionner',
                  style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _zones
                    .map((z) => GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_selectedZones.contains(z)) {
                                _selectedZones.remove(z);
                              } else {
                                _selectedZones.add(z);
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _selectedZones.contains(z)
                                  ? AppTheme.primary
                                  : AppTheme.cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _selectedZones.contains(z)
                                    ? AppTheme.primary
                                    : AppTheme.border,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_selectedZones.contains(z))
                                  const Icon(Icons.check,
                                      size: 12, color: Colors.white),
                                if (_selectedZones.contains(z))
                                  const SizedBox(width: 4),
                                Text(
                                  z,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _selectedZones.contains(z)
                                        ? Colors.white
                                        : AppTheme.foreground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 90),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          boxShadow: AppTheme.shadowCardLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'En publiant, vous acceptez nos Conditions d\'utilisation',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppTheme.mutedForeground),
            ),
            const SizedBox(height: 10),
            AppButton(
              label: 'Publier l\'annonce',
              onTap: () {
                Get.back();
              },
              icon: Icons.upload_outlined,
            ),
          ],
        ),
      ),
    );
  }
}
