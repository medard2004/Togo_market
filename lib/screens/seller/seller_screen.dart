import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../../utils/responsive.dart';
import 'widgets/seller_stat_box.dart';
import 'widgets/seller_product_card.dart';

class SellerScreen extends StatelessWidget {
  const SellerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    final id = Get.parameters['id'] ?? 's1';
    final seller = getSellerById(id);
    if (seller == null) {
      return const Scaffold(body: Center(child: Text('Vendeur introuvable')));
    }
    final products = mockProducts.where((p) => p.sellerId == id).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ── AppBar + bannière dégradée ───────────────────────────────────
          SliverAppBar(
            expandedHeight: r.s(120),
            pinned: true,
            backgroundColor: AppTheme.primary,
            elevation: 0,
            leading: Padding(
              padding: EdgeInsets.all(r.s(8)),
              child: GestureDetector(
                onTap: Get.back,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child:
                      Icon(Icons.arrow_back, size: r.s(20), color: Colors.white),
                ),
              ),
            ),
            title: Text(seller.shopName,
                style: TextStyle(
                    fontSize: r.fs(16),
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            actions: [
              IconButton(
                icon: Icon(Icons.ios_share_outlined,
                    size: r.s(22), color: Colors.white),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primary, Color(0xFFFF8C42)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          // ── Carte info boutique (chevauche la bannière) ──────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(r.s(16), r.s(0), r.s(16), 0),
              child: Transform.translate(
                offset: Offset(0, -r.s(1)),
                child: Container(
                  padding: EdgeInsets.all(r.s(16)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(r.rad(20)),
                    boxShadow: AppTheme.shadowCardLg,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Logo boutique
                          Container(
                            width: r.s(64),
                            height: r.s(64),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              borderRadius: BorderRadius.circular(r.rad(14)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(r.rad(14)),
                              child: CachedNetworkImage(
                                imageUrl: seller.avatar,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Shimmer.fromColors(
                                  baseColor: AppTheme.muted,
                                  highlightColor: Colors.white,
                                  child: Container(color: AppTheme.muted),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: r.s(14)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(seller.shopName,
                                    style: TextStyle(
                                        fontSize: r.fs(18),
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.foreground)),
                                SizedBox(height: r.s(4)),
                                Row(children: [
                                  Icon(Icons.star,
                                      size: r.s(14), color: Colors.amber),
                                  SizedBox(width: r.s(4)),
                                  Text('${seller.rating} (124 avis)',
                                      style: TextStyle(
                                          fontSize: r.fs(13),
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.foreground)),
                                ]),
                                SizedBox(height: r.s(3)),
                                Row(children: [
                                  Icon(Icons.location_on_outlined,
                                      size: r.s(13),
                                      color: AppTheme.mutedForeground),
                                  SizedBox(width: r.s(2)),
                                  Flexible(
                                      child: Text(seller.location,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: r.fs(12),
                                              color: AppTheme.mutedForeground))),
                                ]),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: r.s(14)),
                      // Bouton Discuter
                      GestureDetector(
                        onTap: () => Get.toNamed('/chat/c1'),
                        child: Container(
                          width: double.infinity,
                          height: r.s(48).clamp(44, 54),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(r.rad(12)),
                            boxShadow: AppTheme.shadowPrimary,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline,
                                  color: Colors.white, size: r.s(18)),
                              SizedBox(width: r.s(8)),
                              Text('Discuter avec le vendeur',
                                  style: TextStyle(
                                      fontSize: r.fs(14),
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Stats ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(r.s(16), r.s(14), r.s(16), 0),
              child: Row(
                children: [
                  SellerStatBox(label: 'Ventes', value: '1.2k', r: r),
                  SizedBox(width: r.s(10)),
                  SellerStatBox(label: 'Réponse', value: '< 1h', r: r),
                  SizedBox(width: r.s(10)),
                  SellerStatBox(
                      label: 'Actif',
                      value: 'Maintenant',
                      r: r,
                      valueSmall: true),
                ],
              ),
            ),
          ),

          // ── En-tête Articles + Filtrer ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(r.s(16), r.s(22), r.s(16), r.s(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Articles (${products.length})',
                      style: TextStyle(
                          fontSize: r.fs(18),
                          fontWeight: FontWeight.w700,
                          color: AppTheme.foreground)),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: r.s(14), vertical: r.s(7)),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(r.rad(20)),
                      ),
                      child: Row(children: [
                        Icon(Icons.tune, size: r.s(14), color: AppTheme.primary),
                        SizedBox(width: r.s(4)),
                        Text('Filtrer',
                            style: TextStyle(
                                fontSize: r.fs(13),
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary)),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Grille produits ──────────────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.fromLTRB(r.s(16), 0, r.s(16), r.s(40)),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: r.s(16),
                crossAxisSpacing: r.s(12),
                childAspectRatio: _gridRatio(context),
              ),
              delegate: SliverChildBuilderDelegate(
                (_, i) => SellerProductCard(product: products[i], r: r),
                childCount: products.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _gridRatio(BuildContext context) {
    final r = R(context);
    final colW = (r.screenW - r.s(16) * 2 - r.s(12)) / 2;
    final imgH = colW; // carré
    final infoH = r.s(52);
    return colW / (imgH + infoH);
  }
}
