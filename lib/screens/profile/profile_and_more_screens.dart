import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/common_widgets.dart';
import '../../controllers/app_controller.dart';
import '../../data/mock_data.dart';
import '../../Api/provider/auth_controller.dart';
import '../../widgets/app_loader.dart';
import '../../models/models.dart';
import '../../navigation/app_transitions.dart';
import '../../animations/togo_animation_system.dart';

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
              onTap: () async {
                await AppLoader.wrap(
                  context,
                  () => Get.find<AuthController>().logout(),
                  message: 'Déconnexion en cours...',
                );
                Get.offAllNamed('/auth');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: AppTheme.destructive.withOpacity(0.3)),
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
                  : Border.all(color: AppTheme.primary.withOpacity(0.2)),
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
    final r = R(context);
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('❤️', style: TextStyle(fontSize: r.s(52))),
                SizedBox(height: r.s(14)),
                Text(
                  'Aucun favori pour l\'instant',
                  style: TextStyle(
                    fontSize: r.fs(16),
                    fontWeight: FontWeight.w700,
                    color: AppTheme.foreground,
                  ),
                ),
                SizedBox(height: r.s(6)),
                Text(
                  'Appuie sur ❤️ pour sauvegarder\ntes articles préférés',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: r.fs(13),
                    color: AppTheme.mutedForeground,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compteur
            Padding(
              padding: EdgeInsets.fromLTRB(r.hPad, r.s(14), r.hPad, r.s(8)),
              child: Text(
                '${favs.length} article${favs.length > 1 ? 's' : ''} sauvegardé${favs.length > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: r.fs(13),
                  fontWeight: FontWeight.w500,
                  color: AppTheme.mutedForeground,
                ),
              ),
            ),
            // Liste tickets
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(r.hPad, 0, r.hPad, r.s(24)),
                itemCount: favs.length,
                separatorBuilder: (_, __) => SizedBox(height: r.s(10)),
                itemBuilder: (_, i) => FavoriteTicketCard(product: favs[i]),
              ),
            ),
          ],
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
              onTap: () async {
                await AppLoader.wrap(
                  context,
                  () => Get.find<AuthController>().logout(),
                  message: 'Déconnexion en cours...',
                );
                Get.offAllNamed('/auth');
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.destructive.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: AppTheme.destructive.withOpacity(0.2)),
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
                style:
                    TextStyle(fontSize: 12, color: AppTheme.mutedForeground)),
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
                              fontSize: 12, color: AppTheme.mutedForeground)),
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
                        AnimatedSize(
                          duration: TogoMotion.accordion,
                          curve: TogoMotion.accordionCurve,
                          alignment: Alignment.topLeft,
                          clipBehavior: Clip.hardEdge,
                          child: _expanded == i
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    faq.$2,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      height: 1.5,
                                      color: AppTheme.mutedForeground,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
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
                  Expanded(
                      child: _TabPill(
                          'Achats', 0, _tab, (v) => setState(() => _tab = v))),
                  Expanded(
                      child: _TabPill(
                          'Ventes', 1, _tab, (v) => setState(() => _tab = v))),
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
                color:
                    current == index ? Colors.white : AppTheme.mutedForeground,
              ),
            ),
          ),
        ),
      );
}

// ── Dashboard Screen (maquette « Mon espace vendeur ») ────────────────────────
class _SellerMockColors {
  static const Color background = Color(0xFFF9F9F9);
  static const Color primaryOrange = Color(0xFFFF5722);
  static const Color textGray = Color(0xFF707070);
  static const Color editBg = Color(0xFFE8E4F3);
  static const Color editIcon = Color(0xFF7C69AF);
  static const Color deleteBg = Color(0xFFFCE8E8);
  static const Color deleteIcon = Color(0xFFE53935);
  static const Color chipBg = Color(0xFFEDEDED);
  static const Color chipText = Color(0xFF5C5C5C);
}

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
      backgroundColor: _SellerMockColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
              child: Row(
                children: [
                  _SellerBackButton(onPressed: () => Get.back()),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Mon Espace Vendeur',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SellerTabBar(
                selectedIndex: _tab,
                onSelect: (i) {
                  if (i == 1) {
                    Navigator.of(context).push<void>(
                      PageRouteBuilder<void>(
                        settings: const RouteSettings(name: '/add-product'),
                        fullscreenDialog: true,
                        opaque: true,
                        transitionDuration: const Duration(milliseconds: 400),
                        reverseTransitionDuration:
                            const Duration(milliseconds: 340),
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const AddProductScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          final transition = TogoModalLiftTransition();
                          return transition.buildTransition(
                            context,
                            Curves.easeOutCubic,
                            null,
                            animation,
                            secondaryAnimation,
                            child,
                          );
                        },
                      ),
                    );
                    return;
                  }
                  setState(() => _tab = i);
                },
              ),
            ),
            const SizedBox(height: 14),
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
      ),
    );
  }
}

class _SellerBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SellerBackButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onPressed,
      child: Ink(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              spreadRadius: 0,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.arrow_back, size: 20, color: Colors.black),
      ),
    );
  }
}

class _SellerTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _SellerTabBar({
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _TabEntry(
              label: 'Articles',
              icon: Icons.grid_view_rounded,
              selected: selectedIndex == 0,
              onTap: () => onSelect(0),
            ),
            _TabEntry(
              label: 'Ajouter',
              icon: Icons.add,
              selected: selectedIndex == 1,
              onTap: () => onSelect(1),
            ),
            _TabEntry(
              label: 'Commandes',
              icon: Icons.inventory_2_outlined,
              selected: selectedIndex == 2,
              onTap: () => onSelect(2),
            ),
            _TabEntry(
              label: 'Messages',
              icon: Icons.chat_bubble_outline_rounded,
              selected: selectedIndex == 3,
              onTap: () => onSelect(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabEntry extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TabEntry({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 70),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color:
                selected ? _SellerMockColors.primaryOrange : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: selected ? Colors.white : _SellerMockColors.textGray,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : _SellerMockColors.textGray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArticlesTab extends StatelessWidget {
  final DashboardController ctrl;
  const _ArticlesTab({required this.ctrl});

  @override
  Widget build(BuildContext context) => Obx(() {
        final n = ctrl.myProducts.length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 16, 12),
              child: Text(
                '$n article${n > 1 ? 's' : ''} actif${n > 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _SellerMockColors.textGray,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                itemCount: ctrl.myProducts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (_, i) {
                  final p = ctrl.myProducts[i];
                  return _SellerProductCard(
                    product: p,
                    onEdit: () {},
                    onDelete: () => ctrl.deleteProduct(p.id),
                  );
                },
              ),
            ),
          ],
        );
      });
}

class _SellerProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SellerProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: CachedNetworkImage(
              imageUrl: product.image,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  formatPrice(product.price),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _SellerMockColors.primaryOrange,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _SellerMockColors.chipBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    product.condition,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _SellerMockColors.chipText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _RoundIconButton(
                background: _SellerMockColors.editBg,
                iconColor: _SellerMockColors.editIcon,
                icon: Icons.edit_outlined,
                onTap: onEdit,
              ),
              const SizedBox(width: 10),
              _RoundIconButton(
                background: _SellerMockColors.deleteBg,
                iconColor: _SellerMockColors.deleteIcon,
                icon: Icons.delete_outline_rounded,
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final Color background;
  final Color iconColor;
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({
    required this.background,
    required this.iconColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: iconColor),
        ),
      ),
    );
  }
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
                                fontSize: 12, color: AppTheme.mutedForeground)),
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
    'Tokoin',
    'Avépozo',
    'Adidogomé',
    'Bè',
    'Kégué',
    'Nyékonakpoè',
    'Agbalépédo',
    'Amadahomé',
    'Agoè',
    'Legbassito',
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppTheme.background,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
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
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
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
                        border: Border.all(
                            color: AppTheme.border, style: BorderStyle.solid),
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
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const TextField(
                decoration: InputDecoration(hintText: 'Ex: iPhone 13 128GB '),
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
                          decoration: InputDecoration(hintText: '0'),
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
                          padding: const EdgeInsets.symmetric(horizontal: 12),
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
                              onChanged: (v) => setState(() => _category = v!),
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
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final t in [('Fixe', '⚡'), ('Négociable', '🤝')])
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _priceType = t.$1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin:
                              EdgeInsets.only(right: t.$1 == 'Fixe' ? 6 : 0),
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
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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
                        color: AppTheme.primary, fontWeight: FontWeight.w600),
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
                  Navigator.of(context).maybePop();
                },
                icon: Icons.upload_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
