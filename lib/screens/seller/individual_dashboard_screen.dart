import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../animations/togo_animation_system.dart';
import '../../widgets/common_widgets.dart';
import '../../utils/responsive.dart';
import '../../controllers/my_products_controller.dart';
import '../../Api/model/product_model.dart';
import '../../utils/app_utils.dart';
import '../../Api/config/api_constants.dart';

class IndividualDashboardScreen extends StatefulWidget {
  const IndividualDashboardScreen({super.key});

  @override
  State<IndividualDashboardScreen> createState() =>
      _IndividualDashboardScreenState();
}

class _IndividualDashboardScreenState extends State<IndividualDashboardScreen> {
  late final MyProductsController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<MyProductsController>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ctrl.loadMyProducts());
  }

  void _deleteProduct(Product p) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Supprimer l\'annonce ?',
            style: TextStyle(
                color: AppTheme.foreground, fontWeight: FontWeight.w800)),
        content: Text(
            'Cette action est irréversible. Voulez-vous vraiment supprimer "${p.title}" ?',
            style: TextStyle(color: AppTheme.mutedForeground)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Annuler',
                style: TextStyle(color: AppTheme.mutedForeground)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _ctrl.deleteProduct(p.id.toString());
            },
            child: Text('Supprimer',
                style: TextStyle(
                    color: AppTheme.destructive, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Obx(() {
          final products = _ctrl.myProducts;
          final totalViews = '156'; // Mocked
          final totalSales = '24'; // Mocked

          return CustomScrollView(
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
                          _buildCircleBtn(
                            Icons.settings_outlined,
                            AppTheme.primary,
                            AppTheme.primary.withOpacity(0.1),
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
                      Expanded(
                          child: _buildStatMiniCard(
                              r,
                              products.length.toString(),
                              'Annonces',
                              Icons.inventory_2_outlined,
                              Colors.blue)),
                      SizedBox(width: r.s(12)),
                      Expanded(
                          child: _buildStatMiniCard(r, totalViews, 'Vues',
                              Icons.remove_red_eye_outlined, Colors.orange)),
                      SizedBox(width: r.s(12)),
                      Expanded(
                          child: _buildStatMiniCard(r, totalSales, 'Ventes',
                              Icons.shopping_bag_outlined, Colors.green)),
                    ],
                  ),
                ),
              ),

              // ── Action Button ─────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: TogoPressableScale(
                    onTap: () async {
                      await Get.toNamed('/add-product',
                          arguments: {'isParticulier': true});
                      _ctrl.loadMyProducts();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primary,
                            AppTheme.primary.withOpacity(0.8)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: AppTheme.shadowPrimary,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_circle_outline,
                              color: Colors.white),
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
                        '${products.length} articles',
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
              if (_ctrl.isLoading.value)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              else if (products.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 64,
                              color: AppTheme.mutedForeground.withOpacity(0.4)),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun article pour le moment',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        return TogoSlideUp(
                          key: ValueKey(products[i].id),
                          delay: Duration(milliseconds: i * 50),
                          child: _buildIndividualProductItem(products[i]),
                        );
                      },
                      childCount: products.length,
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCircleBtn(IconData icon, Color iconColor, Color bg,
      {VoidCallback? onTap}) {
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
        border:
            Border.all(color: AppTheme.primary.withOpacity(0.1), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child:
                Icon(Icons.person_outline, color: AppTheme.primary, size: 30),
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

  Widget _buildStatMiniCard(
      R r, String value, String label, IconData icon, Color color) {
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

  Widget _buildIndividualProductItem(Product product) {
    final bool isActive = true;
    final imageUrl = ApiConstants.resolveImageUrl(product.image);

    return Opacity(
      opacity: isActive ? 1.0 : 0.6,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.shadowSm,
          border: !isActive
              ? Border.all(color: AppTheme.muted.withOpacity(0.5))
              : null,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _imagePlaceholder(),
                      placeholder: (_, __) => _imagePlaceholder(),
                    )
                  : _imagePlaceholder(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.foreground,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatPrice(product.price),
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
                          onTap: () async {
                        await Get.toNamed('/edit-product/${product.id}');
                        _ctrl.loadMyProducts();
                      }),
                      const SizedBox(width: 12),
                      _buildTinyAction(Icons.delete_outline, 'Supprimer',
                          isDestructive: true,
                          onTap: () => _deleteProduct(product)),
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
                    onChanged: (val) {
                      Get.snackbar(
                        'Info',
                        'La modification du statut n\'est pas encore disponible.',
                        backgroundColor: AppTheme.primary.withOpacity(0.1),
                        colorText: AppTheme.primary,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
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

  Widget _imagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      color: AppTheme.muted,
      child: Icon(Icons.image_not_supported,
          color: AppTheme.mutedForeground, size: 28),
    );
  }

  Widget _buildTinyAction(IconData icon, String label,
      {bool isDestructive = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon,
              size: 14,
              color: isDestructive
                  ? AppTheme.destructive
                  : AppTheme.mutedForeground),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDestructive
                  ? AppTheme.destructive
                  : AppTheme.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
