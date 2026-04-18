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
    final hScrollHeight = r.cardImageH + r.s(58);

    return AnimationLimiter(
      child: Obx(() {
        final selectedCat   = ctrl.selectedCategory.value;
        final allProducts   = ctrl.products.toList();
        final filteredProds = ctrl.getFilteredProducts(selectedCat);
        final trending      = ctrl.trendingProducts.isNotEmpty
            ? ctrl.trendingProducts.toList()
            : allProducts.take(8).toList();
        final selectedZone  = ctrl.selectedZone.value;
        final nearbyProds   = ctrl.getProductsByZone(selectedZone ?? '');

        return RefreshIndicator(
          onRefresh: () async {
            await ctrl.fetchProduits();
            await ctrl.fetchCategories();
            await ctrl.fetchTrendingProducts();
          },
          color: AppTheme.primary,
          backgroundColor: AppTheme.cardColor,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Barre de recherche ──────────────────────────────────────────
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

              // ── Catégories ─────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: SizedBox(
                  height: r.s(44),
                  child: Builder(builder: (_) {
                    final apiCats = ctrl.categories;
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
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                                horizontal: r.s(14), vertical: r.s(8)),
                            decoration: BoxDecoration(
                              color: isActive ? AppTheme.primary : AppTheme.cardColor,
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

              // ── Contenu ────────────────────────────────────────────────────
              if (selectedCat == 'all') ...[

                // ── Section Tendances ─────────────────────────────────────────
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
                SliverToBoxAdapter(
                  child: trending.isEmpty
                      ? _buildEmptyZone(r, 'Aucun produit tendance')
                      : SizedBox(
                          height: hScrollHeight,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: r.hPad),
                            itemCount: trending.length,
                            separatorBuilder: (_, __) => SizedBox(width: r.s(12)),
                            itemBuilder: (_, i) =>
                                AnimationConfiguration.staggeredList(
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
                                        product: trending[i], isHorizontal: true),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: r.vGap)),

                // ── Section Près de chez vous ─────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        EdgeInsets.fromLTRB(r.hPad, 0, r.hPad, r.s(12)),
                    child: Row(
                      children: [
                        Expanded(
                          child: SectionTitle(
                            icon: Icons.location_on_rounded,
                            iconColor: AppTheme.primary,
                            title: 'Près de chez vous',
                            actionLabel: 'Voir tout',
                            onAction: () => Get.toNamed('/category'),
                          ),
                        ),
                        // Bouton de sélection de zone
                        GestureDetector(
                          onTap: () => _showZonePicker(context, ctrl),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: r.s(10), vertical: r.s(5)),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              borderRadius: BorderRadius.circular(r.rad(20)),
                              border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.tune_rounded,
                                    size: r.s(14), color: AppTheme.primary),
                                SizedBox(width: r.s(4)),
                                Text(
                                  selectedZone ?? 'Zone',
                                  style: TextStyle(
                                      fontSize: r.fs(11),
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: nearbyProds.isEmpty
                      ? _buildZoneEmptyState(r, context, ctrl)
                      : SizedBox(
                          height: hScrollHeight,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding:
                                EdgeInsets.symmetric(horizontal: r.hPad),
                            itemCount: nearbyProds.length,
                            separatorBuilder: (_, __) =>
                                SizedBox(width: r.s(12)),
                            itemBuilder: (_, i) =>
                                AnimationConfiguration.staggeredList(
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
                                        product: nearbyProds[i],
                                        isHorizontal: true),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: r.vGap)),

                // ── Tous les articles ─────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        EdgeInsets.fromLTRB(r.hPad, 0, r.hPad, r.s(12)),
                    child: const SectionTitle(title: 'Tous les articles'),
                  ),
                ),
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
                if (filteredProds.isEmpty)
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
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
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
                              child: ProductCard(product: filteredProds[i]),
                            ),
                          ),
                        ),
                        childCount: filteredProds.length,
                      ),
                    ),
                  ),
              ],

              SliverToBoxAdapter(child: SizedBox(height: r.s(100))),
            ],
          ),
        );
      }),
    );
  }

  // ── Sélecteur de zone (BottomSheet) ────────────────────────────────────────
  void _showZonePicker(BuildContext context, AppController ctrl) {
    final zones = ctrl.availableZones;
    final r = R(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(r.rad(20))),
      ),
      builder: (_) => Obx(() {
        final current = ctrl.selectedZone.value;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: r.s(10)),
              width: r.s(36),
              height: r.s(4),
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(r.s(16)),
              child: Text('Sélectionner votre zone',
                  style: TextStyle(
                      fontSize: r.fs(16), fontWeight: FontWeight.w700,
                      color: AppTheme.foreground)),
            ),
            // Option "Toutes les zones"
            ListTile(
              leading: Icon(Icons.public_rounded,
                  color: current == null ? AppTheme.primary : AppTheme.mutedForeground),
              title: Text('Toutes les zones',
                  style: TextStyle(
                      fontWeight: current == null ? FontWeight.w700 : FontWeight.w500,
                      color: current == null ? AppTheme.primary : AppTheme.foreground)),
              trailing: current == null
                  ? Icon(Icons.check_circle, color: AppTheme.primary, size: r.s(20))
                  : null,
              onTap: () {
                ctrl.setSelectedZone(null);
                Navigator.pop(context);
              },
            ),
            if (zones.isEmpty)
              Padding(
                padding: EdgeInsets.all(r.s(16)),
                child: Text('Aucune zone disponible',
                    style: TextStyle(
                        color: AppTheme.mutedForeground, fontSize: r.fs(14))),
              )
            else
              SizedBox(
                height: zones.length > 6 ? 280 : null,
                child: ListView.builder(
                  shrinkWrap: zones.length <= 6,
                  itemCount: zones.length,
                  itemBuilder: (_, i) {
                    final zone = zones[i];
                    final isSelected = current == zone;
                    return ListTile(
                      leading: Icon(Icons.location_on_outlined,
                          color: isSelected ? AppTheme.primary : AppTheme.mutedForeground,
                          size: r.s(20)),
                      title: Text(zone,
                          style: TextStyle(
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? AppTheme.primary : AppTheme.foreground)),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: AppTheme.primary, size: r.s(20))
                          : null,
                      onTap: () {
                        ctrl.setSelectedZone(zone);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + r.s(8)),
          ],
        );
      }),
    );
  }

  // ── Widgets helpers ────────────────────────────────────────────────────────
  Widget _buildEmptyZone(R r, String message) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: r.s(20)),
      child: Center(
        child: Text(message,
            style: TextStyle(
                fontSize: r.fs(13), color: AppTheme.mutedForeground)),
      ),
    );
  }

  Widget _buildZoneEmptyState(R r, BuildContext context, AppController ctrl) {
    return Padding(
      padding: EdgeInsets.fromLTRB(r.hPad, r.s(4), r.hPad, r.s(8)),
      child: GestureDetector(
        onTap: () => _showZonePicker(context, ctrl),
        child: Container(
          padding: EdgeInsets.all(r.s(16)),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(r.rad(14)),
            border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.location_searching_rounded,
                  color: AppTheme.primary, size: r.s(24)),
              SizedBox(width: r.s(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Choisir votre zone',
                        style: TextStyle(
                            fontSize: r.fs(14),
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary)),
                    Text('Sélectionnez votre quartier ou ville pour voir les produits proches.',
                        style: TextStyle(
                            fontSize: r.fs(12), color: AppTheme.mutedForeground)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppTheme.primary, size: r.s(18)),
            ],
          ),
        ),
      ),
    );
  }

  double _gridAspectRatio(BuildContext context) {
    final r = R(context);
    final colW = (r.screenW - r.hPad * 2 - r.s(12)) / 2;
    final imgH = colW * (3 / 4);
    final infoH = r.s(56);
    final totalH = imgH + infoH;
    return colW / totalH;
  }
}
