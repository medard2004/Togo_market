import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/bottom_nav.dart';
import '../../controllers/app_controller.dart';
import '../../data/mock_data.dart';
import '../../utils/responsive.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            GetBuilder<AppController>(builder: (ctrl) => _HomeTopBar(ctrl: ctrl)),
            Expanded(
              child: GetBuilder<AppController>(builder: (ctrl) => _HomeBody(ctrl: ctrl)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}

// ── Top bar ────────────────────────────────────────────────────────────────────
class _HomeTopBar extends StatelessWidget {
  final AppController ctrl;
  const _HomeTopBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(r.hPad, r.s(12), r.hPad, r.s(8)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Bonjour 👋  ',
                        style: TextStyle(fontSize: r.fs(14), color: AppTheme.mutedForeground)),
                    Flexible(
                      child: Text(
                        ctrl.userName.value.split(' ').first,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: r.fs(14), fontWeight: FontWeight.w600, color: AppTheme.foreground),
                      ),
                    ),
                  ],
                ),
                Text('Togo_Market',
                    style: TextStyle(fontSize: r.fs(20), fontWeight: FontWeight.w800, color: AppTheme.foreground)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Get.toNamed('/notifications'),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: r.s(42), height: r.s(42),
                  decoration: BoxDecoration(color: AppTheme.cardColor, shape: BoxShape.circle, boxShadow: AppTheme.shadowCard),
                  child: Icon(Icons.notifications_outlined, size: r.s(22), color: AppTheme.foreground),
                ),
                if (ctrl.unreadNotifications.value > 0)
                  Positioned(
                    top: r.s(4), right: r.s(4),
                    child: Container(
                      width: r.s(10), height: r.s(10),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: r.s(10)),
          GestureDetector(
            onTap: () => Get.toNamed('/profile'),
            child: CircleAvatar(
              radius: r.s(21),
              backgroundImage: CachedNetworkImageProvider(ctrl.userAvatar.value),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Body ───────────────────────────────────────────────────────────────────────
class _HomeBody extends StatelessWidget {
  final AppController ctrl;
  const _HomeBody({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    final selectedCat = ctrl.selectedCategory.value;
    final allProducts = ctrl.products.toList();
    final filteredProducts = ctrl.getFilteredProducts(selectedCat);

    // Hauteur du scroll horizontal = image + info + padding
    final hScrollHeight = r.cardImageH + r.s(58);

    return CustomScrollView(
      slivers: [
        // ── Barre de recherche ────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(r.hPad, r.s(4), r.hPad, r.s(12)),
            child: GestureDetector(
              onTap: () => Get.toNamed('/search'),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: r.s(16), vertical: r.s(13)),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(r.rad(16)),
                  boxShadow: AppTheme.shadowCard,
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: AppTheme.mutedForeground, size: r.s(20)),
                    SizedBox(width: r.s(10)),
                    Text('Rechercher des produits...',
                        style: TextStyle(fontSize: r.fs(14), color: AppTheme.mutedForeground)),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Catégories ────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: SizedBox(
            height: r.s(44),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: r.hPad),
              itemCount: mockCategories.length,
              separatorBuilder: (_, __) => SizedBox(width: r.s(8)),
              itemBuilder: (_, i) {
                final cat = mockCategories[i];
                final isActive = selectedCat == cat.id;
                return GestureDetector(
                  onTap: () { ctrl.selectedCategory.value = cat.id; ctrl.update(); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(horizontal: r.s(14), vertical: r.s(8)),
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.primary : AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(r.rad(20)),
                      boxShadow: isActive ? AppTheme.shadowPrimary : AppTheme.shadowCard,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(cat.emoji, style: TextStyle(fontSize: r.fs(15))),
                        SizedBox(width: r.s(5)),
                        Text(cat.label,
                            style: TextStyle(fontSize: r.fs(12), fontWeight: FontWeight.w600,
                                color: isActive ? Colors.white : AppTheme.foreground)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: r.vGap)),

        // ── Contenu ───────────────────────────────────────────────────────────
        if (selectedCat == 'all') ...[
          // 🔥 Tendances titre
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(r.hPad, 0, r.hPad, r.s(12)),
              child: SectionTitle(title: '🔥 Tendances', actionLabel: 'Voir tout', onAction: () => Get.toNamed('/category')),
            ),
          ),
          // 🔥 Tendances scroll
          SliverToBoxAdapter(
            child: SizedBox(
              height: hScrollHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: r.hPad),
                itemCount: allProducts.length,
                separatorBuilder: (_, __) => SizedBox(width: r.s(12)),
                itemBuilder: (_, i) => SizedBox(
                  width: r.cardW,
                  child: ProductCard(product: allProducts[i], isHorizontal: true),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: r.vGap)),

          // 📍 Près de chez vous titre
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(r.hPad, 0, r.hPad, r.s(12)),
              child: SectionTitle(title: '📍 Près de chez vous', actionLabel: 'Voir tout', onAction: () => Get.toNamed('/category')),
            ),
          ),
          // 📍 Près de chez vous scroll
          SliverToBoxAdapter(
            child: SizedBox(
              height: hScrollHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: r.hPad),
                itemCount: allProducts.length,
                separatorBuilder: (_, __) => SizedBox(width: r.s(12)),
                itemBuilder: (_, i) {
                  final idx = (allProducts.length - 1 - i) % allProducts.length;
                  return SizedBox(
                    width: r.cardW,
                    child: ProductCard(product: allProducts[idx], isHorizontal: true),
                  );
                },
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: r.vGap)),

          // Tous les articles titre
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(r.hPad, 0, r.hPad, r.s(12)),
              child: const SectionTitle(title: 'Tous les articles'),
            ),
          ),
          // Grille
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: r.hPad),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: r.s(12),
                crossAxisSpacing: r.s(12),
                childAspectRatio: _gridAspectRatio(context),
              ),
              delegate: SliverChildBuilderDelegate(
                (_, i) => ProductCard(product: allProducts[i]),
                childCount: allProducts.length,
              ),
            ),
          ),
        ] else ...[
          if (filteredProducts.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: r.s(60)),
                child: Center(
                  child: Column(
                    children: [
                      Text('😕', style: TextStyle(fontSize: r.fs(48))),
                      SizedBox(height: r.s(12)),
                      Text('Aucun produit dans cette catégorie',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: r.fs(15), fontWeight: FontWeight.w600, color: AppTheme.mutedForeground)),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: r.hPad),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: r.s(12),
                  crossAxisSpacing: r.s(12),
                  childAspectRatio: _gridAspectRatio(context),
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, i) => ProductCard(product: filteredProducts[i]),
                  childCount: filteredProducts.length,
                ),
              ),
            ),
        ],

        SliverToBoxAdapter(child: SizedBox(height: r.s(100))),
      ],
    );
  }

  /// Calcule un aspectRatio qui évite le overflow sur tous les écrans.
  /// La carte = image (ratio 4/3) + zone info (~58px scalée).
  double _gridAspectRatio(BuildContext context) {
    final r = R(context);
    final colW = (r.screenW - r.hPad * 2 - r.s(12)) / 2;
    final imgH = colW * (3 / 4); // ratio 4:3
    final infoH = r.s(56);       // titre + localisation + padding
    final totalH = imgH + infoH;
    return colW / totalH;
  }
}
