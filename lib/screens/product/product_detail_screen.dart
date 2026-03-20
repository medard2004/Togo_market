import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../controllers/app_controller.dart';
import '../../data/mock_data.dart';
import '../../utils/responsive.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _imageIndex = 0;
  final _pageCtrl = PageController();

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    final id = Get.parameters['id'] ?? '';
    final product = getProductById(id);
    final ctrl = Get.find<AppController>();

    if (product == null) {
      return Scaffold(
        body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('😕', style: TextStyle(fontSize: 40)),
          const Text('Produit introuvable'),
          ElevatedButton(onPressed: Get.back, child: const Text('Retour')),
        ])),
      );
    }

    final seller = getSellerById(product.sellerId);
    final similar = ctrl.getSimilarProducts(product.id, product.category);
    final images = [product.image, product.image, product.image];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── AppBar flottante ────────────────────────────────────────────
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                scrolledUnderElevation: 0.5,
                leading: Padding(
                  padding: EdgeInsets.all(r.s(8)),
                  child: GestureDetector(
                    onTap: Get.back,
                    child: Container(
                      decoration: BoxDecoration(color: AppTheme.background, shape: BoxShape.circle),
                      child: Icon(Icons.arrow_back, size: r.s(22), color: AppTheme.foreground),
                    ),
                  ),
                ),
                title: Text('Détails du produit',
                    style: TextStyle(fontSize: r.fs(17), fontWeight: FontWeight.w700, color: AppTheme.foreground)),
                actions: [
                  IconButton(
                    icon: Icon(Icons.share_outlined, size: r.s(22), color: AppTheme.foreground),
                    onPressed: () {},
                  ),
                  Obx(() {
                    final fav = ctrl.isFavorite(product.id);
                    return IconButton(
                      icon: Icon(fav ? Icons.favorite : Icons.favorite_border,
                          size: r.s(22), color: fav ? AppTheme.primary : AppTheme.foreground),
                      onPressed: () => ctrl.toggleFavorite(product.id),
                    );
                  }),
                ],
              ),

              // ── Galerie images ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    SizedBox(
                      height: r.screenH * 0.38,
                      child: PageView.builder(
                        controller: _pageCtrl,
                        itemCount: images.length,
                        onPageChanged: (i) => setState(() => _imageIndex = i),
                        itemBuilder: (_, i) => CachedNetworkImage(
                          imageUrl: images[i],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (_, __) => Shimmer.fromColors(
                            baseColor: AppTheme.muted,
                            highlightColor: Colors.white,
                            child: Container(color: AppTheme.muted),
                          ),
                        ),
                      ),
                    ),
                    // Indicateurs de points
                    Positioned(
                      bottom: r.s(12),
                      left: 0, right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(images.length, (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.symmetric(horizontal: r.s(4)),
                          width: i == _imageIndex ? r.s(24) : r.s(8),
                          height: r.s(8),
                          decoration: BoxDecoration(
                            color: i == _imageIndex ? AppTheme.primary : Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        )),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Contenu ─────────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(r.s(16), r.s(20), r.s(16), r.s(100)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Prix
                      Text(
                        '${formatPrice(product.price).replaceAll(' F', '')} FCFA',
                        style: TextStyle(
                          fontSize: r.fs(28),
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                        ),
                      ),
                      SizedBox(height: r.s(4)),

                      // Titre produit
                      Text(
                        product.title,
                        style: TextStyle(
                          fontSize: r.fs(20),
                          fontWeight: FontWeight.w700,
                          color: AppTheme.foreground,
                          height: 1.25,
                        ),
                      ),
                      SizedBox(height: r.s(16)),

                      // Localisation
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: r.s(16), vertical: r.s(13)),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(r.rad(14)),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: r.s(36), height: r.s(36),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryLight,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.location_on, size: r.s(18), color: AppTheme.primary),
                              ),
                              SizedBox(width: r.s(12)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(product.location,
                                        style: TextStyle(fontSize: r.fs(14), fontWeight: FontWeight.w700, color: AppTheme.foreground)),
                                    Text('À 2.5 km de vous',
                                        style: TextStyle(fontSize: r.fs(12), color: AppTheme.mutedForeground)),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right, color: AppTheme.mutedForeground, size: r.s(20)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: r.s(20)),

                      // Description
                      Text('DESCRIPTION',
                          style: TextStyle(fontSize: r.fs(11), fontWeight: FontWeight.w700,
                              letterSpacing: 1.5, color: AppTheme.mutedForeground)),
                      SizedBox(height: r.s(10)),
                      Text(product.description,
                          style: TextStyle(fontSize: r.fs(15), color: AppTheme.foreground, height: 1.6)),
                      SizedBox(height: r.s(14)),

                      // Tags
                      Wrap(
                        spacing: r.s(8),
                        runSpacing: r.s(8),
                        children: ['Pointure 42', product.condition, 'Vendeur vérifié']
                            .map((tag) => Container(
                                  padding: EdgeInsets.symmetric(horizontal: r.s(14), vertical: r.s(7)),
                                  decoration: BoxDecoration(
                                    color: AppTheme.muted,
                                    borderRadius: BorderRadius.circular(r.rad(30)),
                                  ),
                                  child: Text(tag,
                                      style: TextStyle(fontSize: r.fs(13), fontWeight: FontWeight.w500, color: AppTheme.foreground)),
                                ))
                            .toList(),
                      ),
                      SizedBox(height: r.s(20)),

                      // Carte vendeur
                      if (seller != null) ...[
                        Container(
                          padding: EdgeInsets.all(r.s(14)),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(r.rad(16)),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: r.s(26),
                                        backgroundImage: CachedNetworkImageProvider(seller.avatar),
                                      ),
                                      Positioned(
                                        bottom: 0, right: 0,
                                        child: Container(
                                          width: r.s(12), height: r.s(12),
                                          decoration: BoxDecoration(
                                            color: Colors.green, shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 2),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: r.s(12)),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(seller.shopName,
                                            style: TextStyle(fontSize: r.fs(15), fontWeight: FontWeight.w700, color: AppTheme.foreground)),
                                        SizedBox(height: r.s(2)),
                                        Row(children: [
                                          Icon(Icons.flash_on, size: r.s(12), color: AppTheme.primary),
                                          SizedBox(width: r.s(2)),
                                          Text('Répond en ~5 min',
                                              style: TextStyle(fontSize: r.fs(12), color: AppTheme.mutedForeground)),
                                        ]),
                                        SizedBox(height: r.s(2)),
                                        Text('MEMBRE DEPUIS JAN 2023',
                                            style: TextStyle(fontSize: r.fs(10), fontWeight: FontWeight.w600,
                                                letterSpacing: 0.5, color: AppTheme.mutedForeground)),
                                      ],
                                    ),
                                  ),
                                  Row(children: [
                                    Icon(Icons.star, size: r.s(14), color: Colors.amber),
                                    SizedBox(width: r.s(2)),
                                    Text('${seller.rating}',
                                        style: TextStyle(fontSize: r.fs(13), fontWeight: FontWeight.w700, color: AppTheme.foreground)),
                                  ]),
                                ],
                              ),
                              SizedBox(height: r.s(12)),
                              GestureDetector(
                                onTap: () => Get.toNamed('/seller/${seller.id}'),
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(vertical: r.s(11)),
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardColor,
                                    borderRadius: BorderRadius.circular(r.rad(10)),
                                    border: Border.all(color: AppTheme.border),
                                  ),
                                  child: Center(
                                    child: Text('Voir la boutique',
                                        style: TextStyle(fontSize: r.fs(14), fontWeight: FontWeight.w600, color: AppTheme.foreground)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: r.s(20)),
                      ],

                      // Localisation produit (carte simulée)
                      Text('Localisation du produit',
                          style: TextStyle(fontSize: r.fs(18), fontWeight: FontWeight.w700, color: AppTheme.foreground)),
                      SizedBox(height: r.s(12)),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(r.rad(16)),
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                              imageUrl:
                                  'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=600&h=250&fit=crop',
                              width: double.infinity,
                              height: r.s(160),
                              fit: BoxFit.cover,
                            ),
                            Positioned.fill(
                              child: Container(color: Colors.black.withOpacity(0.08)),
                            ),
                            Positioned(
                              bottom: r.s(14), left: r.s(14),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: r.s(12), vertical: r.s(7)),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(r.rad(20)),
                                  boxShadow: AppTheme.shadowCard,
                                ),
                                child: Row(children: [
                                  Icon(Icons.location_on, size: r.s(14), color: AppTheme.primary),
                                  SizedBox(width: r.s(4)),
                                  Text(product.location,
                                      style: TextStyle(fontSize: r.fs(12), fontWeight: FontWeight.w600)),
                                ]),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: r.s(16)),

                      // Conseil sécurité
                      Container(
                        padding: EdgeInsets.all(r.s(14)),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(r.rad(14)),
                          border: Border.all(color: Colors.amber.withOpacity(0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: r.s(32), height: r.s(32),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLight,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.shield_outlined, size: r.s(16), color: AppTheme.primary),
                            ),
                            SizedBox(width: r.s(10)),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(fontSize: r.fs(13), color: AppTheme.primary, height: 1.5),
                                  children: const [
                                    TextSpan(text: 'Conseil de sécurité : ', style: TextStyle(fontWeight: FontWeight.w700)),
                                    TextSpan(text: 'Ne payez jamais d\'avance. Rencontrez le vendeur dans un lieu public pour vérifier le produit.'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: r.s(24)),

                      // Produits similaires
                      if (similar.isNotEmpty) ...[
                        Text('Produits similaires',
                            style: TextStyle(fontSize: r.fs(18), fontWeight: FontWeight.w700, color: AppTheme.foreground)),
                        SizedBox(height: r.s(14)),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: r.s(12),
                            crossAxisSpacing: r.s(12),
                            childAspectRatio: _gridRatio(context),
                          ),
                          itemCount: similar.length,
                          itemBuilder: (_, i) => ProductCard(product: similar[i]),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── CTA fixe en bas ─────────────────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(r.s(16), r.s(12), r.s(16),
                  MediaQuery.of(context).padding.bottom + r.s(12)),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, -4)),
                ],
              ),
              child: Row(
                children: [
                  // Bouton Commander (outline)
                  GestureDetector(
                    onTap: () => Get.toNamed('/order', arguments: {'productId': product.id}),
                    child: Container(
                      height: r.s(50).clamp(44, 56),
                      padding: EdgeInsets.symmetric(horizontal: r.s(20)),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(r.rad(30)),
                        border: Border.all(color: AppTheme.primary, width: 1.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_outlined, size: r.s(16), color: AppTheme.primary),
                          SizedBox(width: r.s(6)),
                          Text('Commander',
                              style: TextStyle(fontSize: r.fs(14), fontWeight: FontWeight.w700, color: AppTheme.primary)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: r.s(10)),
                  // Bouton Discuter (plein)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.toNamed('/chat/c1'),
                      child: Container(
                        height: r.s(50).clamp(44, 56),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(r.rad(30)),
                          boxShadow: AppTheme.shadowPrimary,
                        ),
                        child: Center(
                          child: Text('Discuter avec le vendeur',
                              style: TextStyle(fontSize: r.fs(14), fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                ],
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
    return colW / (colW * (3 / 4) + r.s(56));
  }
}
