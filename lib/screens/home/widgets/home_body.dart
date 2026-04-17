import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import '../../../animations/togo_animation_system.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';
import '../../../controllers/app_controller.dart';
import '../../../utils/responsive.dart';
import '../../../Api/model/category_model.dart';
import '../../../utils/category_icon_helper.dart';

class HomeBody extends StatelessWidget {
  final AppController ctrl;
  const HomeBody({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    final selectedCat = ctrl.selectedCategory.value;
    final allProducts = ctrl.products.toList();
    final filteredProducts = ctrl.getFilteredProducts(selectedCat);

    // Hauteur du scroll horizontal = image + info + padding
    final hScrollHeight = r.cardImageH + r.s(58);

    return AnimationLimiter(
      child: RefreshIndicator(
        onRefresh: () async {
          await ctrl.fetchProduits();
          // Optionally fetch categories if needed
          await ctrl.fetchCategories();
        },
        color: AppTheme.primary,
        backgroundColor: AppTheme.cardColor,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
          // ── Barre de recherche ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(r.hPad, r.s(4), r.hPad, r.s(12)),
              child: TogoFadeInEntry(
                child: GestureDetector(
                  onTap: () => Get.toNamed('/search'),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: r.s(16), vertical: r.s(13)),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(r.rad(16)),
                      boxShadow: AppTheme.shadowCard,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search,
                            color: AppTheme.mutedForeground, size: r.s(20)),
                        SizedBox(width: r.s(10)),
                        Text(
                          'Rechercher des produits...',
                          style: TextStyle(
                              fontSize: r.fs(14),
                              color: AppTheme.mutedForeground),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Catégories ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: r.s(44),
              child: Obx(() {
                final apiCats = ctrl.categories;
                // We manually add "Tout" at the beginning
                final displayCats = [
                  Category(id: -1, nom: 'Tout', slug: 'tout'),
                  ...apiCats
                ];

                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: r.hPad),
                  itemCount: displayCats.length,
                  separatorBuilder: (_, __) => SizedBox(width: r.s(8)),
                  itemBuilder: (_, i) {
                    final cat = displayCats[i];
                    final catIdStr = cat.id == -1 ? 'all' : cat.id.toString();
                    final isActive = selectedCat == catIdStr;

                    return GestureDetector(
                      onTap: () {
                        ctrl.selectedCategory.value = catIdStr;
                        ctrl.update();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                            horizontal: r.s(14), vertical: r.s(8)),
                        decoration: BoxDecoration(
                          color:
                              isActive ? AppTheme.primary : AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(r.rad(20)),
                          boxShadow: isActive
                              ? AppTheme.shadowPrimary
                              : AppTheme.shadowCard,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CategoryIconHelper.getIcon(cat.slug),
                              size: r.fs(16),
                              color: isActive ? Colors.white : AppTheme.primary,
                            ),
                            SizedBox(width: r.s(8)),
                            Text(cat.nom,
                                style: TextStyle(
                                    fontSize: r.fs(12),
                                    fontWeight: FontWeight.w600,
                                    color: isActive
                                        ? Colors.white
                                        : AppTheme.foreground)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: r.vGap)),

          // ── Contenu ─────────────────────────────────────────────────────────
          if (selectedCat == 'all') ...[
            // Tendances titre
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(r.hPad, 0, r.hPad, r.s(12)),
                child: SectionTitle(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: Colors.orange,
                  title: 'Tendances',
                  actionLabel: 'Voir tout',
                  onAction: () => Get.toNamed('/category'),
                ),
              ),
            ),
            // Tendances scroll
            SliverToBoxAdapter(
              child: SizedBox(
                height: hScrollHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: r.hPad),
                  itemCount: allProducts.length,
                  separatorBuilder: (_, __) => SizedBox(width: r.s(12)),
                  itemBuilder: (_, i) => AnimationConfiguration.staggeredList(
                    position: i,
                    duration: const Duration(milliseconds: 260),
                    child: SlideAnimation(
                      horizontalOffset: 28,
                      curve: Curves.easeOutCubic,
                      child: FadeInAnimation(
                        curve: Curves.easeOutCubic,
                        child: SizedBox(
                          width: r.cardW,
                          child: ProductCard(
                              product: allProducts[i], isHorizontal: true),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: r.vGap)),

            // Près de chez vous titre
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(r.hPad, 0, r.hPad, r.s(12)),
                child: SectionTitle(
                  icon: Icons.location_on_rounded,
                  iconColor: AppTheme.primary,
                  title: 'Près de chez vous',
                  actionLabel: 'Voir tout',
                  onAction: () => Get.toNamed('/category'),
                ),
              ),
            ),
            // Près de chez vous scroll
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
                    return AnimationConfiguration.staggeredList(
                      position: i,
                      duration: const Duration(milliseconds: 260),
                      child: SlideAnimation(
                        horizontalOffset: 28,
                        curve: Curves.easeOutCubic,
                        child: FadeInAnimation(
                          curve: Curves.easeOutCubic,
                          child: SizedBox(
                            width: r.cardW,
                            child: ProductCard(
                                product: allProducts[idx], isHorizontal: true),
                          ),
                        ),
                      ),
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
                  (_, i) => AnimationConfiguration.staggeredGrid(
                    position: i,
                    columnCount: 2,
                    duration: const Duration(milliseconds: 280),
                    child: SlideAnimation(
                      verticalOffset: 22,
                      curve: Curves.easeOutCubic,
                      child: FadeInAnimation(
                        curve: Curves.easeOutCubic,
                        child: ProductCard(product: allProducts[i]),
                      ),
                    ),
                  ),
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
                        Icon(Icons.search_off_rounded,
                            size: r.s(64), color: AppTheme.mutedForeground),
                        SizedBox(height: r.s(12)),
                        Text('Aucun produit dans cette catégorie',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: r.fs(15),
                                fontWeight: FontWeight.w600,
                                color: AppTheme.mutedForeground)),
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
                    (_, i) => AnimationConfiguration.staggeredGrid(
                      position: i,
                      columnCount: 2,
                      duration: const Duration(milliseconds: 280),
                      child: SlideAnimation(
                        verticalOffset: 22,
                        curve: Curves.easeOutCubic,
                        child: FadeInAnimation(
                          curve: Curves.easeOutCubic,
                          child: ProductCard(product: filteredProducts[i]),
                        ),
                      ),
                    ),
                    childCount: filteredProducts.length,
                  ),
                ),
              ),
          ],

          SliverToBoxAdapter(child: SizedBox(height: r.s(100))),
        ],
      ),
      ),
    );
  }

  /// Calcule un aspectRatio qui évite le overflow sur tous les écrans.
  double _gridAspectRatio(BuildContext context) {
    final r = R(context);
    final colW = (r.screenW - r.hPad * 2 - r.s(12)) / 2;
    final imgH = colW * (3 / 4); // ratio 4:3
    final infoH = r.s(56); // titre + localisation + padding
    final totalH = imgH + infoH;
    return colW / totalH;
  }
}
