import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../Api/model/product_model.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/app_utils.dart';
import '../../../utils/responsive.dart';
import '../../../controllers/app_controller.dart';

class SellerProductCard extends StatelessWidget {
  final Product product;
  final R r;
  const SellerProductCard({super.key, required this.product, required this.r});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AppController>();
    return GestureDetector(
      onTap: () => Get.toNamed('/product/${product.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image carrée avec favori + badge NOUVEAU
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(r.rad(14)),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CachedNetworkImage(
                    imageUrl: product.image,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Shimmer.fromColors(
                      baseColor: AppTheme.muted,
                      highlightColor: Colors.white,
                      child: Container(color: AppTheme.muted),
                    ),
                  ),
                ),
              ),
              // Badge NOUVEAU si condition == 'Neuf'
              if (product.condition == 'Neuf')
                Positioned(
                  bottom: r.s(8),
                  left: r.s(8),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: r.s(8), vertical: r.s(3)),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(r.rad(6)),
                    ),
                    child: Text('NOUVEAU',
                        style: TextStyle(
                            fontSize: r.fs(9),
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ),
              // Bouton cœur
              Positioned(
                top: r.s(8),
                right: r.s(8),
                child: Obx(() {
                  final fav = ctrl.isFavorite(product.id);
                  return GestureDetector(
                    onTap: () => ctrl.toggleFavorite(product.id),
                    child: Container(
                      width: r.s(32),
                      height: r.s(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.shadowCard,
                      ),
                      child: Icon(
                        fav ? Icons.favorite : Icons.favorite_border,
                        size: r.s(16),
                        color: fav ? AppTheme.primary : AppTheme.mutedForeground,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: r.s(8)),
          Text(product.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: r.fs(13),
                  fontWeight: FontWeight.w600,
                  color: AppTheme.foreground)),
          SizedBox(height: r.s(2)),
          Text(formatPrice(product.price),
              style: TextStyle(
                  fontSize: r.fs(14),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary)),
        ],
      ),
    );
  }
}
