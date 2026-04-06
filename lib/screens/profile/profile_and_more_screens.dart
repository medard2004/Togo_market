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
                  : Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
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
                  color: AppTheme.destructive.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: AppTheme.destructive.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.destructive.withValues(alpha: 0.1),
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
                                    ? Colors.amber.withValues(alpha: 0.15)
                                    : Colors.green.withValues(alpha: 0.15),
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

// ── Store Configuration Screen ───────────────────────────────────────────────
class StoreConfigurationScreen extends StatefulWidget {
  const StoreConfigurationScreen({super.key});

  @override
  State<StoreConfigurationScreen> createState() =>
      _StoreConfigurationScreenState();
}

class _StoreConfigurationScreenState extends State<StoreConfigurationScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _sloganCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  TimeOfDay? _openingTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay? _closingTime = const TimeOfDay(hour: 18, minute: 0);
  String _zone = 'Tokoin';
  String _categoryId = 'friperie'; // Default category
  final List<String> _days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  final List<String> _selectedDays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven']; // Default

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

  Future<void> _pickTime(bool isOpening) async {
    final initialTime = isOpening
        ? (_openingTime ?? const TimeOfDay(hour: 8, minute: 0))
        : (_closingTime ?? const TimeOfDay(hour: 18, minute: 0));

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: isOpening ? 'Heure d\'ouverture' : 'Heure de fermeture',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              onSurface: AppTheme.foreground,
              surface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primary,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w400, // Plus fin
                  fontSize: 14,
                ),
              ),
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppTheme.border.withValues(alpha: 0.3), width: 0.5),
              ),
              hourMinuteColor: AppTheme.primary.withValues(alpha: 0.08), // Couleur de fond très légère
              hourMinuteTextColor: AppTheme.primary,
              dayPeriodTextColor: AppTheme.primary,
              dayPeriodColor: AppTheme.primary.withValues(alpha: 0.15),
              dialBackgroundColor: AppTheme.primary.withValues(alpha: 0.1),
              dialHandColor: AppTheme.primary,
              dialTextColor: AppTheme.foreground,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isOpening) {
          _openingTime = picked;
        } else {
          _closingTime = picked;
        }
      });
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '--:--';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _toggleDay(String day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        if (_selectedDays.length > 1) _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  bool get _isFormValid {
    return _nameCtrl.text.isNotEmpty &&
        _phoneCtrl.text.isNotEmpty &&
        _selectedDays.isNotEmpty &&
        _openingTime != null &&
        _closingTime != null;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _sloganCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Paramètres boutique'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Get.back();
            } else {
              Get.offNamed('/home');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover & Avatar
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    width: double.infinity,
                    height: 140,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                      image: const DecorationImage(
                        image: CachedNetworkImageProvider(
                          'https://images.unsplash.com/photo-1556740738-b6a63e27c4df?q=80&w=600&auto=format&fit=crop',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.white.withValues(alpha: 0.4),
                          child: const Icon(
                            Icons.camera_alt,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -40,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppTheme.background,
                        shape: BoxShape.circle,
                      ),
                      child: const CircleAvatar(
                        radius: 40,
                        backgroundImage: CachedNetworkImageProvider(
                          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=200&auto=format&fit=crop',
                        ),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: AppTheme.primary,
                            child: Icon(Icons.edit, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),

            const Text(
              'Nom de la boutique *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(hintText: 'Ex: Ma Super Boutique'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Slogan (Optionnel)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _sloganCtrl,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(hintText: 'Motto de votre boutique...'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Catégorie de produits *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.border),
                borderRadius: BorderRadius.circular(16),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _categoryId,
                  isExpanded: true,
                  items: mockCategories
                      .where((c) => c.id != 'all')
                      .map(
                        (c) => DropdownMenuItem(
                          value: c.id,
                          child: Text('${c.emoji} ${c.label}'),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _categoryId = v!),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Description',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Ex: Produits de qualité et livraison rapide.',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Téléphone *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(hintText: 'Ex: +228 90 00 00 00'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Jours d\'ouverture',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _days.map((day) {
                final isSelected = _selectedDays.contains(day);
                return GestureDetector(
                  onTap: () => _toggleDay(day),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary : AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : AppTheme.border,
                      ),
                    ),
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? Colors.white : AppTheme.foreground,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Horaires d\'ouverture',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickTime(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.wb_sunny_outlined, size: 18, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text(
                            _formatTime(_openingTime),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'à',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.mutedForeground,
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickTime(false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.nights_stay_outlined, size: 18, color: Colors.indigo),
                          const SizedBox(width: 8),
                          Text(
                            _formatTime(_closingTime),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Localisation *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.border),
                borderRadius: BorderRadius.circular(16),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _zone,
                  isExpanded: true,
                  items: _zones
                      .map((z) => DropdownMenuItem(value: z, child: Text(z)))
                      .toList(),
                  onChanged: (v) => setState(() => _zone = v!),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Opacity(
            opacity: _isFormValid ? 1.0 : 0.5,
            child: AppButton(
              label: 'Créer ma boutique',
              icon: Icons.storefront_outlined,
              onTap: _isFormValid
                  ? () {
                      Get.offNamed('/dashboard');
                    }
                  : () {},
            ),
          ),
        ),
      ),
    );
  }
}

// ── Dashboard Screen (maquette « Mon espace vendeur ») ────────────────────────
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _tabIndex = 0; // 0: Articles, 1: Commandes, 2: Messages

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   _buildCircleBtn(
                    Icons.arrow_back,
                    Colors.black,
                    Colors.white,
                    onTap: () => Get.back(),
                  ),
                  const Text(
                    'Mon Espace Vendeur',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.foreground,
                    ),
                  ),
                  _buildCircleBtn(
                    Icons.settings_outlined,
                    AppTheme.primary,
                    AppTheme.primaryLight,
                    onTap: () => Get.toNamed('/shop-settings'),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Shop Card ──────────────────────────────────────────────
                    _buildShopCard(),
                    const SizedBox(height: 24),

                    // ── Tab Navigation ────────────────────────────────────────
                    _buildTabSelector(),
                    const SizedBox(height: 24),

                    // ── Tab Content ───────────────────────────────────────────
                    Column(
                      key: ValueKey(_tabIndex),
                      children: [
                        if (_tabIndex == 0) ...[
                          _buildAddButton(),
                          const SizedBox(height: 24),
                          _buildArticlesTab(),
                        ] else if (_tabIndex == 1)
                          _buildOrdersTab()
                        else
                          _buildMessagesTab(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleBtn(IconData icon, Color iconColor, Color bg, {VoidCallback? onTap}) {
    return TogoPressableScale(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          boxShadow: bg == Colors.white ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ] : null,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  Widget _buildShopCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppTheme.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.storefront_outlined,
                color: AppTheme.primary, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kofi Tech Shop',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.foreground,
                  ),
                ),
                Row(
                  children: const [
                    Icon(Icons.location_on_outlined,
                        size: 14, color: AppTheme.mutedForeground),
                    Text(' Tokoin, Lomé',
                        style:
                            TextStyle(fontSize: 13, color: AppTheme.mutedForeground)),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: const [
                    Text('3 articles',
                        style:
                            TextStyle(fontSize: 13, color: AppTheme.primary)),
                    Text(' • ',
                        style:
                            TextStyle(fontSize: 13, color: AppTheme.primary)),
                    Icon(Icons.star, size: 14, color: Colors.amber),
                    Text(' 4.8',
                        style:
                            TextStyle(fontSize: 13, color: AppTheme.primary)),
                  ],
                ),
              ],
            ),
          ),
          TogoPressableScale(
            onTap: () => Get.toNamed('/store-config'),
            child: const Text(
              'Modifier',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      height: 72,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        children: [
          _buildTabItem(0, Icons.grid_view_outlined, 'Articles'),
          _buildTabItem(1, Icons.inventory_2_outlined, 'Commandes'),
          _buildTabItem(2, Icons.chat_bubble_outline_outlined, 'Messages'),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label) {
    bool isActive = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 20,
                  color: isActive ? Colors.white : AppTheme.mutedForeground),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppTheme.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () => Get.to(() => const AddProductScreen()),
      child: Container(
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          color: AppTheme.primaryLight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.add, color: AppTheme.primary),
              SizedBox(width: 8),
              Text(
                'Ajouter un article',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArticlesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TogoSlideUp(
          child: const Text(
            '3 articles actifs',
            style: TextStyle(
              fontSize: 15,
              color: AppTheme.mutedForeground,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 12),
        TogoSlideUp(
          delay: const Duration(milliseconds: 100),
          child: _buildProductTile(
            'iPhone 13 Pro Max 256Go',
            '350 000 F',
            'Occasion',
            'https://images.unsplash.com/photo-1632661674596-df8be070a5c5?w=400&h=400&fit=crop',
          ),
        ),
        TogoSlideUp(
          delay: const Duration(milliseconds: 200),
          child: _buildProductTile(
            'Canapé 3 places cuir',
            '85 000 F',
            'Occasion',
            'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400&h=400&fit=crop',
          ),
        ),
        TogoSlideUp(
          delay: const Duration(milliseconds: 300),
          child: _buildProductTile(
            'Laptop HP EliteBook',
            '220 000 F',
            'Occasion',
            'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=400&h=400&fit=crop',
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersTab() {
    return Column(
      children: [
        TogoSlideUp(
          child: _buildOrderTile(
            'iPhone 13 Pro Max 256Go',
            'Kafui A.',
            '350 000 F',
            'https://images.unsplash.com/photo-1632661674596-df8be070a5c5?w=200&h=200&fit=crop',
            'En attente',
            isPending: true,
          ),
        ),
        TogoSlideUp(
          delay: const Duration(milliseconds: 100),
          child: _buildOrderTile(
            'Canapé 3 places cuir',
            'Mawuli K.',
            '85 000 F',
            'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=200&h=200&fit=crop',
            'Acceptée',
            isPending: false,
          ),
        ),
      ],
    );
  }

  Widget _buildMessagesTab() {
    return Column(
      children: [
        TogoSlideUp(
          child: _buildMessageTile(
            'Kofi Mensah',
            'Oui, il est toujours disponible !',
            '10:32',
            'iPhone 13 Pro Max 256Go',
            'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=200&auto=format&fit=crop',
            unreadCount: 2,
          ),
        ),
        TogoSlideUp(
          delay: const Duration(milliseconds: 100),
          child: _buildMessageTile(
            'Ama Koffi',
            'Je peux faire 13 000 FCFA',
            'Hier',
            'Robe Ankara colorée',
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format&fit=crop',
          ),
        ),
      ],
    );
  }

  Widget _buildOrderTile(
      String title, String buyer, String price, String img, String status,
      {bool isPending = true}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                    imageUrl: img,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isPending
                                ? AppTheme.primaryLight
                                : Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isPending ? AppTheme.primary : Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text('Acheteur: $buyer',
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.mutedForeground)),
                    const SizedBox(height: 2),
                    Text(price,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary)),
                  ],
                ),
              ),
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TogoPressableScale(
                    onTap: () {},
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.check_circle_outline,
                              color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text('Accepter',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TogoPressableScale(
                    onTap: () {},
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.destructive.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.cancel_outlined,
                              color: AppTheme.destructive, size: 20),
                          SizedBox(width: 8),
                          Text('Refuser',
                              style: TextStyle(
                                  color: AppTheme.destructive,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageTile(String name, String message, String time,
      String product, String avatar,
      {int unreadCount = 0}) {
    return TogoPressableScale(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: CachedNetworkImageProvider(avatar),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800)),
                      Text(time,
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.mutedForeground)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          style: const TextStyle(
                              fontSize: 13, color: AppTheme.mutedForeground),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                              color: AppTheme.primary, shape: BoxShape.circle),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined,
                          size: 14, color: AppTheme.primary),
                      const SizedBox(width: 4),
                      Text(product,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductTile(
      String title, String price, String cond, String img) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl: img,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.foreground,
                  ),
                ),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.muted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    cond,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.mutedForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              TogoPressableScale(
                onTap: () {},
                child: _buildActionBtn(Icons.edit_outlined),
              ),
              const SizedBox(width: 8),
              TogoPressableScale(
                onTap: () {},
                child: _buildActionBtn(Icons.delete_outline, isDelete: true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, {bool isDelete = false}) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: AppTheme.primaryLight,
        shape: BoxShape.circle,
      ),
      child: Icon(icon,
          size: 18, color: isDelete ? AppTheme.destructive : AppTheme.primary),
    );
  }
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
              TogoSlideUp(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        TogoPressableScale(
                          onTap: () {},
                          child: Container(
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
                        ),
                        ...List.generate(
                          4,
                          (i) => TogoSlideUp(
                            delay: Duration(milliseconds: 100 + (i * 50)),
                            child: Container(
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
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Title
              TogoSlideUp(
                delay: const Duration(milliseconds: 200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Titre',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    const TextField(
                      decoration: InputDecoration(hintText: 'Ex: iPhone 13 128GB '),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Price + Category
              TogoSlideUp(
                delay: const Duration(milliseconds: 300),
                child: Row(
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
              ),
              const SizedBox(height: 16),
              // Price type toggle
              TogoSlideUp(
                delay: const Duration(milliseconds: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Type de prix',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (final t in [('Fixe', '⚡'), ('Négociable', '🤝')])
                          Expanded(
                            child: TogoPressableScale(
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
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Condition
              TogoSlideUp(
                delay: const Duration(milliseconds: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('État',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (final c in ['Neuf', 'Occasion'])
                          Expanded(
                            child: TogoPressableScale(
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
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Description
              TogoSlideUp(
                delay: const Duration(milliseconds: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Description',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Décrivez votre produit en détail...',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Zones
              TogoSlideUp(
                delay: const Duration(milliseconds: 700),
                child: Column(
                  children: [
                    TogoPressableScale(
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
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: _showZones
                          ? Column(
                              children: [
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
                                      .map((z) => TogoPressableScale(
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
                                              duration:
                                                  const Duration(milliseconds: 200),
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: _selectedZones.contains(z)
                                                    ? AppTheme.primary
                                                    : AppTheme.cardColor,
                                                borderRadius:
                                                    BorderRadius.circular(20),
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
                                                        size: 12,
                                                        color: Colors.white),
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
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
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

// ── Shop Settings Screen (maquette « Paramètres boutique ») ──────────────────
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
                      color: Colors.black.withValues(alpha: 0.05),
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
                          decoration: BoxDecoration(
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
                  onTap: () {},
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
                  onTap: () {},
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
                    color: AppTheme.destructive.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                        color: AppTheme.destructive.withValues(alpha: 0.15)),
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
            color: Colors.black.withValues(alpha: 0.03),
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
              decoration: BoxDecoration(
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

