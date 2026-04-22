import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:togo_market/theme/app_colors.dart';
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
          borderRadius: BorderRadius.circular(r.rad(36)),
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
                      borderRadius: BorderRadius.circular(r.rad(32)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(r.rad(32)),
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
                          horizontal: r.s(14), vertical: r.s(7)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(r.rad(18)),
                      ),
                      child: Text(
                        product.condition,
                        style: TextStyle(
                          fontSize: r.fs(12),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF4A4A4A),
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
                          horizontal: r.s(16), vertical: r.s(10)),
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
                          fontSize: r.fs(15),
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info Section
            Padding(
              padding: EdgeInsets.fromLTRB(r.s(12), r.s(16), r.s(8), r.s(12)),
              child: Text(
                product.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: r.fs(17),
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: -0.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



