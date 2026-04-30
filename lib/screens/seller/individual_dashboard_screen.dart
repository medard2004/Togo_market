import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../animations/togo_animation_system.dart';
import '../../widgets/common_widgets.dart';
import '../../utils/responsive.dart';

class IndividualDashboardScreen extends StatefulWidget {
  const IndividualDashboardScreen({super.key});

  @override
  State<IndividualDashboardScreen> createState() => _IndividualDashboardScreenState();
}

class _IndividualDashboardScreenState extends State<IndividualDashboardScreen> {
  // Mock products list for local state management
  final List<Map<String, dynamic>> _myProducts = [
    {
      'id': '1',
      'title': 'iPhone 13 Pro Max',
      'price': '350 000 F',
      'image': 'https://images.unsplash.com/photo-1632661674596-df8be070a5c5?w=400&h=400&fit=crop',
      'isActive': true,
    },
    {
      'id': '2',
      'title': 'Veste en Jean',
      'price': '15 000 F',
      'image': 'https://images.unsplash.com/photo-1576995853123-5a10305d93c0?w=400&h=400&fit=crop',
      'isActive': true,
    },
    {
      'id': '3',
      'title': 'Nike Air Max 270',
      'price': '45 000 F',
      'image': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&h=400&fit=crop',
      'isActive': false,
    },
  ];

  void _deleteProduct(int index) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Supprimer l\'annonce ?', 
          style: TextStyle(color: AppTheme.foreground, fontWeight: FontWeight.w800)),
        content: Text('Cette action est irréversible. Voulez-vous vraiment supprimer cet article ?',
          style: TextStyle(color: AppTheme.mutedForeground)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Annuler', style: TextStyle(color: AppTheme.mutedForeground)),
          ),
          TextButton(
            onPressed: () {
              setState(() => _myProducts.removeAt(index));
              Get.back();
              Get.snackbar(
                'Supprimé', 
                'L\'annonce a été supprimée avec succès',
                backgroundColor: AppTheme.destructive.withOpacity(0.1),
                colorText: AppTheme.destructive,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: Text('Supprimer', style: TextStyle(color: AppTheme.destructive, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _toggleProductStatus(int index) {
    setState(() {
      _myProducts[index]['isActive'] = !_myProducts[index]['isActive'];
    });
    final status = _myProducts[index]['isActive'] ? 'activée' : 'désactivée';
    Get.snackbar(
      'Statut mis à jour',
      'Votre annonce est désormais $status.',
      backgroundColor: AppTheme.primary.withOpacity(0.1),
      colorText: AppTheme.primary,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Premium Header ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppBackButton(onTap: () => Get.back()),
                        Text(
                          'Espace Particulier',
                          style: TextStyle(
                            fontSize: r.fs(18),
                            fontWeight: FontWeight.w800,
                            color: AppTheme.foreground,
                          ),
                        ),
                        _buildCircleBtn(Icons.settings_outlined, AppTheme.primary, AppTheme.primary.withOpacity(0.1),
                          onTap: () => Get.toNamed('/settings'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildIntroCard(),
                  ],
                ),
              ),
            ),

            // ── Quick Stats ───────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: r.hPad),
                child: Row(
                  children: [
                    Expanded(child: _buildStatMiniCard(r, _myProducts.length.toString(), 'Annonces', Icons.inventory_2_outlined, Colors.blue)),
                    SizedBox(width: r.s(12)),
                    Expanded(child: _buildStatMiniCard(r, '450', 'Vues', Icons.remove_red_eye_outlined, Colors.orange)),
                    SizedBox(width: r.s(12)),
                    Expanded(child: _buildStatMiniCard(r, '8', 'Ventes', Icons.shopping_bag_outlined, Colors.green)),
                  ],
                ),
              ),
            ),

            // ── Action Button ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: TogoPressableScale(
                  onTap: () => Get.toNamed('/add-product'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppTheme.shadowPrimary,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_circle_outline, color: Colors.white),
                        SizedBox(width: r.s(12)),
                        Text(
                          'Vendre un nouvel article',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: r.fs(16),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── My Listings Title ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mes annonces actives',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.foreground,
                      ),
                    ),
                    Text(
                      '${_myProducts.length} articles',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Listings List ─────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    return TogoSlideUp(
                      key: ValueKey(_myProducts[i]['id']),
                      delay: Duration(milliseconds: i * 50),
                      child: _buildIndividualProductItem(i),
                    );
                  },
                  childCount: _myProducts.length,
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
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppTheme.shadowCard,
        border: Border.all(color: AppTheme.primary.withOpacity(0.1), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_outline, color: AppTheme.primary, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gérez vos ventes privées',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.foreground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Suivez vos annonces et interagissez avec vos acheteurs en toute simplicité.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.mutedForeground,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatMiniCard(R r, String value, String label, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: r.s(16), horizontal: r.s(12)),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(r.rad(24)),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: r.s(20)),
          SizedBox(height: r.s(8)),
          Text(
            value,
            style: TextStyle(
              fontSize: r.fs(18),
              fontWeight: FontWeight.w900,
              color: AppTheme.foreground,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: r.fs(11),
              fontWeight: FontWeight.w600,
              color: AppTheme.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndividualProductItem(int index) {
    final product = _myProducts[index];
    final bool isActive = product['isActive'] ?? true;

    return Opacity(
      opacity: isActive ? 1.0 : 0.6,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.shadowSm,
          border: !isActive ? Border.all(color: AppTheme.muted.withOpacity(0.5)) : null,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: CachedNetworkImage(
                imageUrl: product['image'],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['title'],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.foreground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['price'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildTinyAction(Icons.edit_outlined, 'Modifier', 
                        onTap: () => Get.toNamed('/edit-product/${product['id']}')),
                      const SizedBox(width: 12),
                      _buildTinyAction(Icons.delete_outline, 'Supprimer', 
                        isDestructive: true, onTap: () => _deleteProduct(index)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Transform.scale(
                  scale: 0.7,
                  alignment: Alignment.centerRight,
                  child: CupertinoSwitch(
                    value: isActive,
                    activeTrackColor: AppTheme.primary,
                    inactiveTrackColor: AppTheme.muted,
                    onChanged: (val) => _toggleProductStatus(index),
                  ),
                ),
                Text(
                  isActive ? 'Actif' : 'Désactivé',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: isActive ? Colors.green : AppTheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTinyAction(IconData icon, String label, {bool isDestructive = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon, size: 14, color: isDestructive ? AppTheme.destructive : AppTheme.mutedForeground),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDestructive ? AppTheme.destructive : AppTheme.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
