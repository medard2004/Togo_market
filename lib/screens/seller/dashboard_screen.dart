import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../animations/togo_animation_system.dart';
import '../../controllers/app_controller.dart';
import '../../Api/config/api_constants.dart';
import '../../Api/model/product_model.dart';
import '../../utils/app_utils.dart';
import 'add_product_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _tabIndex = 0; // 0: Articles, 1: Commandes, 2: Messages
  late final DashboardController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<DashboardController>();
    // Reload products when entering dashboard (boutique may have just been created)
    WidgetsBinding.instance.addPostFrameCallback((_) => _ctrl.loadMyProducts());
  }

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

  Widget _buildCircleBtn(IconData icon, Color iconColor, Color bg,
      {VoidCallback? onTap}) {
    return TogoPressableScale(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          boxShadow: bg == Colors.white
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Icon(icon, color: iconColor, size: 20),
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
            color: Colors.black.withOpacity(0.04),
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
      onTap: () async {
        await Get.to(() => const AddProductScreen());
        // Refresh products list after returning from add product
        _ctrl.loadMyProducts();
      },
      child: Container(
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          color: AppTheme.primaryLight.withOpacity(0.5),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: AppTheme.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
    return Obx(() {
      if (_ctrl.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.only(top: 40),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final products = _ctrl.myProducts;
      if (products.isEmpty) {
        return Padding(
          padding: const EdgeInsets.only(top: 48),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.inventory_2_outlined,
                    size: 64, color: AppTheme.mutedForeground.withOpacity(0.4)),
                const SizedBox(height: 16),
                const Text(
                  'Aucun article pour le moment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.mutedForeground,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ajoutez votre premier produit\nen cliquant sur le bouton ci-dessus.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TogoSlideUp(
            child: Text(
              '${products.length} article${products.length > 1 ? 's' : ''} actif${products.length > 1 ? 's' : ''}',
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.mutedForeground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...products.asMap().entries.map((entry) {
            final i = entry.key;
            final p = entry.value;
            return TogoSlideUp(
              delay: Duration(milliseconds: i * 80),
              child: _buildProductTile(p),
            );
          }),
        ],
      );
    });
  }

  Widget _buildOrdersTab() {
    return const Padding(
      padding: EdgeInsets.only(top: 40),
      child: Center(
        child: Text(
          'Aucune commande pour le moment',
          style: TextStyle(color: AppTheme.mutedForeground),
        ),
      ),
    );
  }

  Widget _buildMessagesTab() {
    return const Padding(
      padding: EdgeInsets.only(top: 40),
      child: Center(
        child: Text(
          'Aucun message pour le moment',
          style: TextStyle(color: AppTheme.mutedForeground),
        ),
      ),
    );
  }

  Widget _buildProductTile(Product p) {
    final imageUrl = ApiConstants.resolveImageUrl(p.image);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _imagePlaceholder(),
                    placeholder: (_, __) => _imagePlaceholder(),
                  )
                : _imagePlaceholder(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.foreground,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  formatPrice(p.price),
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
                    p.condition,
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
                onTap: () async {
                  await Get.toNamed('/edit-product/${p.id}');
                  _ctrl.loadMyProducts();
                },
                child: _buildActionBtn(Icons.edit_outlined),
              ),
              const SizedBox(width: 8),
              TogoPressableScale(
                onTap: () => _confirmDelete(p),
                child: _buildActionBtn(Icons.delete_outline, isDelete: true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 72,
      height: 72,
      color: AppTheme.muted,
      child: const Icon(Icons.image_not_supported,
          color: AppTheme.mutedForeground, size: 28),
    );
  }

  void _confirmDelete(Product p) {
    Get.dialog(
      AlertDialog(
        title: const Text('Supprimer ce produit ?'),
        content: Text('Voulez-vous vraiment supprimer "${p.title}" ?'),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _ctrl.deleteProduct(p.id.toString());
            },
            child: const Text('Supprimer',
                style: TextStyle(color: AppTheme.destructive)),
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
