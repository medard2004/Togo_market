import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class ProductCardSkeleton extends StatelessWidget {
  final bool isHorizontal;

  const ProductCardSkeleton({
    super.key,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final r = R(context);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(r.rad(18)),
        boxShadow: AppTheme.shadowCard,
      ),
      clipBehavior: Clip.antiAlias,
      child: Shimmer.fromColors(
        baseColor: AppTheme.muted,
        highlightColor: AppTheme.cardColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Image Placeholder ──
            isHorizontal
                ? SizedBox(
                    height: r.cardImageH,
                    width: double.infinity,
                    child: Container(color: Colors.white),
                  )
                : AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Container(color: Colors.white),
                  ),
            
            // ── Infos Placeholder ──
            Padding(
              padding: EdgeInsets.fromLTRB(r.s(9), r.s(8), r.s(9), r.s(9)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: r.fs(12),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(r.rad(4)),
                    ),
                  ),
                  SizedBox(height: r.s(6)),
                  Container(
                    height: r.fs(10),
                    width: r.s(60),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(r.rad(4)),
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

class ShopCarouselCardSkeleton extends StatelessWidget {
  const ShopCarouselCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final r = R(context);

    return Container(
      width: r.s(160),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(r.rad(24)),
        boxShadow: AppTheme.shadowCard,
      ),
      clipBehavior: Clip.antiAlias,
      child: Shimmer.fromColors(
        baseColor: AppTheme.muted,
        highlightColor: AppTheme.cardColor,
        child: Stack(
          children: [
            Column(
              children: [
                // Banner Placeholder
                SizedBox(
                  height: r.s(85),
                  width: double.infinity,
                  child: Container(color: Colors.white),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(r.s(12), r.s(24), r.s(12), r.s(12)),
                  child: Column(
                    children: [
                      Container(
                        height: r.fs(13),
                        width: r.s(100),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(r.rad(4)),
                        ),
                      ),
                      SizedBox(height: r.s(6)),
                      Container(
                        height: r.fs(10),
                        width: r.s(60),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(r.rad(4)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Avatar Placeholder
            Positioned(
              top: r.s(55),
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: r.s(46),
                  height: r.s(46),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
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
