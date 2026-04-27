import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../models/models.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/responsive.dart';
import '../../../controllers/app_controller.dart';
import '../../../data/mock_data.dart';

class SellerProductCard extends StatelessWidget {
  final Product product;
  final R r;
  const SellerProductCard({super.key, required this.product, required this.r});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/product/${product.id}'),
      child: Container(
        padding: EdgeInsets.all(r.s(10)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(r.rad(25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6F8),
                      borderRadius: BorderRadius.circular(r.rad(22)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(r.rad(22)),
                      child: CachedNetworkImage(
                        imageUrl: product.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Condition Badge (Top Left)
                  Positioned(
                    top: r.s(12),
                    left: r.s(12),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: r.s(5), vertical: r.s(2)),
                      decoration: BoxDecoration(
                        color: product.condition == 'Neuf'
                            ? const Color.fromARGB(255, 255, 255, 255)
                            : const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(r.rad(18)),
                      ),
                      child: Text(
                        product.condition,
                        style: TextStyle(
                          fontSize: r.fs(10),
                          fontWeight: FontWeight.w800,
                          color: product.condition == 'Neuf'
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFE65100),
                        ),
                      ),
                    ),
                  ),
                  // Price Badge (Bottom Right)
                  Positioned(
                    bottom: r.s(12),
                    right: r.s(12),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: r.s(10), vertical: r.s(5)),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(r.rad(20)),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        '${formatPrice(product.price)}',
                        style: TextStyle(
                          fontSize: r.fs(10),
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Favorite Button (Top Right)
                  Positioned(
                    top: r.s(12),
                    right: r.s(12),
                    child: Obx(() {
                      final ctrl = Get.find<AppController>();
                      final fav = ctrl.isFavorite(product.id);
                      return GestureDetector(
                        onTap: () => ctrl.toggleFavorite(product.id),
                        child: Container(
                          padding: EdgeInsets.all(r.s(4)),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: PhosphorIcon(
                            fav
                                ? PhosphorIcons.heart(PhosphorIconsStyle.fill)
                                : PhosphorIcons.heart(),
                            size: r.s(14),
                            color: fav ? AppTheme.primary : Colors.black,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            // Info Section
            Padding(
              padding: EdgeInsets.fromLTRB(r.s(10), r.s(4), r.s(6), r.s(6)),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: r.fs(12),
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  SizedBox(width: r.s(4)),
                  GestureDetector(
                    onTap: () => Get.toNamed('/chat/c1', arguments: product),
                    child: PhosphorIcon(
                      PhosphorIcons.chatCircleDots(),
                      size: r.s(15),
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
