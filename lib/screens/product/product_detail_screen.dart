import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/common_widgets.dart';
import '../../controllers/app_controller.dart';
import '../../data/mock_data.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _imageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final id = Get.parameters['id'] ?? '';
    final product = getProductById(id);
    final ctrl = Get.find<AppController>();

    if (product == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('😕', style: TextStyle(fontSize: 40)),
              const Text('Produit introuvable'),
              ElevatedButton(
                  onPressed: Get.back, child: const Text('Retour')),
            ],
          ),
        ),
      );
    }

    final seller = getSellerById(product.sellerId);
    final similar =
        ctrl.getSimilarProducts(product.id, product.category);
    // Mock multiple images
    final images = [product.image, product.image, product.image];

    return Scaffold(
        resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // Sticky top bar
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.background,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: AppBackButton(),
            ),
            title: Text(
              product.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              Obx(() {
                final fav = ctrl.isFavorite(product.id);
                return IconButton(
                  icon: Icon(
                    fav ? Icons.favorite : Icons.favorite_border,
                    color: fav ? AppTheme.primary : AppTheme.foreground,
                  ),
                  onPressed: () => ctrl.toggleFavorite(product.id),
                );
              }),
              IconButton(
                icon:
                    const Icon(Icons.share_outlined, color: AppTheme.foreground),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gallery
                GestureDetector(
                  onHorizontalDragEnd: (d) {
                    if (d.primaryVelocity! < 0 && _imageIndex < images.length - 1) {
                      setState(() => _imageIndex++);
                    } else if (d.primaryVelocity! > 0 && _imageIndex > 0) {
                      setState(() => _imageIndex--);
                    }
                  },
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: images[_imageIndex],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (_, __) =>
                              Container(color: AppTheme.muted),
                        ),
                        // Dots
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              images.length,
                              (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: i == _imageIndex ? 20 : 6,
                                height: 6,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                decoration: BoxDecoration(
                                  color: i == _imageIndex
                                      ? AppTheme.primary
                                      : Colors.white.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price + condition
                      Row(
                        children: [
                          Text(
                            formatPrice(product.price),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: product.condition == 'Neuf'
                                  ? AppTheme.secondary
                                  : AppTheme.muted,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              product.condition,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: product.condition == 'Neuf'
                                    ? Colors.white
                                    : AppTheme.mutedForeground,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.foreground,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Location
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.location_on,
                                  size: 14, color: AppTheme.primary),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.location,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.foreground,
                                  ),
                                ),
                                const Text(
                                  'À 2.5 km de vous',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Description
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.muted,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'DESCRIPTION',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                                color: AppTheme.mutedForeground,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.description,
                              style: const TextStyle(
                                  fontSize: 14, height: 1.5),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [product.category, product.condition, 'Lomé']
                                  .map((tag) => Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.cardColor,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          tag,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Seller card
                      if (seller != null)
                        SellerCard(
                          seller: seller,
                          onChat: () =>
                              Get.toNamed('/chat/c1'),
                          onVisit: () =>
                              Get.toNamed('/seller/${seller.id}'),
                        ),
                      const SizedBox(height: 16),
                      // Security tip
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.shield_outlined,
                                color: AppTheme.primary, size: 22),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Pour votre sécurité, rencontrez le vendeur dans un lieu public.',
                                style: TextStyle(
                                    fontSize: 12, color: AppTheme.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Similar products
                      if (similar.isNotEmpty) ...[
                        const SectionTitle(title: 'Produits similaires'),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.65,
                          ),
                          itemCount: similar.length,
                          itemBuilder: (_, i) =>
                              ProductCard(product: similar[i]),
                        ),
                      ],
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Fixed CTA
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          boxShadow: AppTheme.shadowCardLg,
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Get.toNamed('/order',
                    arguments: {'productId': product.id}),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.primary, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'Commander',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () => Get.toNamed('/chat/c1'),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.shadowPrimary,
                  ),
                  child: const Center(
                    child: Text(
                      'Discuter avec le vendeur',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
