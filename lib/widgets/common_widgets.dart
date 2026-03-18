import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';
import '../models/models.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../controllers/app_controller.dart';
import '../utils/responsive.dart';

// ── ProductCard ───────────────────────────────────────────────────────────────
class ProductCard extends StatelessWidget {
  final Product product;
  final bool isHorizontal;

  const ProductCard({
    super.key,
    required this.product,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    final ctrl = Get.find<AppController>();

    return GestureDetector(
      onTap: () => Get.toNamed('/product/${product.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(r.rad(18)),
          boxShadow: AppTheme.shadowCard,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Image ───────────────────────────────────────────────────────
            Stack(
              children: [
                isHorizontal
                    ? SizedBox(
                        height: r.cardImageH,
                        width: double.infinity,
                        child: _buildImage(),
                      )
                    : AspectRatio(
                        aspectRatio: 4 / 3,
                        child: _buildImage(),
                      ),
                Positioned(
                  top: r.s(7), left: r.s(7),
                  child: _ConditionBadge(condition: product.condition, r: r),
                ),
                Positioned(
                  bottom: r.s(7), left: r.s(7),
                  child: _PriceBadge(price: product.price, r: r),
                ),
                Positioned(
                  top: r.s(7), right: r.s(7),
                  child: Obx(() {
                    final fav = ctrl.isFavorite(product.id);
                    return GestureDetector(
                      onTap: () => ctrl.toggleFavorite(product.id),
                      child: Container(
                        width: r.s(30), height: r.s(30),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          fav ? Icons.favorite : Icons.favorite_border,
                          size: r.s(14),
                          color: fav ? AppTheme.primary : AppTheme.mutedForeground,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
            // ── Infos ──────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(r.s(9), r.s(7), r.s(9), r.s(9)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: r.fs(12),
                      fontWeight: FontWeight.w600,
                      color: AppTheme.foreground,
                    ),
                  ),
                  SizedBox(height: r.s(3)),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: r.s(10), color: AppTheme.mutedForeground),
                      SizedBox(width: r.s(2)),
                      Expanded(
                        child: Text(
                          product.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: r.fs(10), color: AppTheme.mutedForeground),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() => CachedNetworkImage(
        imageUrl: product.image,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (_, __) => Shimmer.fromColors(
          baseColor: AppTheme.muted,
          highlightColor: Colors.white,
          child: Container(color: AppTheme.muted),
        ),
        errorWidget: (_, __, ___) => Container(
          color: AppTheme.muted,
          child: const Icon(Icons.image_not_supported, color: AppTheme.mutedForeground),
        ),
      );
}

class _ConditionBadge extends StatelessWidget {
  final String condition;
  final R r;
  const _ConditionBadge({required this.condition, required this.r});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: r.s(7), vertical: r.s(3)),
        decoration: BoxDecoration(
          color: condition == 'Neuf' ? AppTheme.secondary : AppTheme.muted,
          borderRadius: BorderRadius.circular(r.rad(20)),
        ),
        child: Text(
          condition,
          style: TextStyle(
            fontSize: r.fs(9),
            fontWeight: FontWeight.w700,
            color: condition == 'Neuf' ? Colors.white : AppTheme.mutedForeground,
          ),
        ),
      );
}

class _PriceBadge extends StatelessWidget {
  final double price;
  final R r;
  const _PriceBadge({required this.price, required this.r});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: r.s(8), vertical: r.s(3)),
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(r.rad(20)),
        ),
        child: Text(
          formatPrice(price),
          style: TextStyle(fontSize: r.fs(10), fontWeight: FontWeight.w700, color: Colors.white),
        ),
      );
}

// ── ShimmerCard ───────────────────────────────────────────────────────────────
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    return Shimmer.fromColors(
      baseColor: AppTheme.muted,
      highlightColor: Colors.white,
      child: Container(
        height: r.s(200),
        decoration: BoxDecoration(
          color: AppTheme.muted,
          borderRadius: BorderRadius.circular(r.rad(18)),
        ),
      ),
    );
  }
}

// ── AppButton ─────────────────────────────────────────────────────────────────
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool outlined;
  final IconData? icon;
  final bool isLoading;
  final Color? color;

  const AppButton({
    super.key,
    required this.label,
    required this.onTap,
    this.outlined = false,
    this.icon,
    this.isLoading = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    final bg = color ?? AppTheme.primary;

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: r.s(54).clamp(46.0, 62.0),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : bg,
          borderRadius: BorderRadius.circular(r.rad(16)),
          border: outlined ? Border.all(color: bg, width: 2) : null,
          boxShadow: outlined ? null : AppTheme.shadowPrimary,
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: r.s(22), height: r.s(22),
                  child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: outlined ? bg : Colors.white, size: r.s(18)),
                      SizedBox(width: r.s(8)),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: r.fs(15),
                          fontWeight: FontWeight.w700,
                          color: outlined ? bg : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── AppBackButton ─────────────────────────────────────────────────────────────
class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  const AppBackButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    return GestureDetector(
      onTap: onTap ?? Get.back,
      child: Container(
        width: r.s(40), height: r.s(40),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          shape: BoxShape.circle,
          boxShadow: AppTheme.shadowCard,
        ),
        child: Icon(Icons.arrow_back_ios_new, size: r.s(17), color: AppTheme.foreground),
      ),
    );
  }
}

// ── SectionTitle ──────────────────────────────────────────────────────────────
class SectionTitle extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionTitle({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: r.fs(16), fontWeight: FontWeight.w700, color: AppTheme.foreground),
          ),
        ),
        if (actionLabel != null) ...[
          SizedBox(width: r.s(8)),
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: TextStyle(fontSize: r.fs(13), fontWeight: FontWeight.w600, color: AppTheme.primary),
            ),
          ),
        ],
      ],
    );
  }
}

// ── CategoryPill ──────────────────────────────────────────────────────────────
class CategoryPill extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const CategoryPill({super.key, required this.emoji, required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    return GestureDetector(
      onTap: onTap,
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
            Text(emoji, style: TextStyle(fontSize: r.fs(15))),
            SizedBox(width: r.s(5)),
            Text(
              label,
              maxLines: 1,
              style: TextStyle(fontSize: r.fs(12), fontWeight: FontWeight.w600, color: isActive ? Colors.white : AppTheme.foreground),
            ),
          ],
        ),
      ),
    );
  }
}

// ── SellerCard ────────────────────────────────────────────────────────────────
class SellerCard extends StatelessWidget {
  final Seller seller;
  final VoidCallback? onChat;
  final VoidCallback? onVisit;

  const SellerCard({super.key, required this.seller, this.onChat, this.onVisit});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    return Container(
      padding: EdgeInsets.all(r.s(14)),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(r.rad(18)),
        boxShadow: AppTheme.shadowCard,
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(radius: r.s(24), backgroundImage: CachedNetworkImageProvider(seller.avatar)),
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  width: r.s(11), height: r.s(11),
                  decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                ),
              ),
            ],
          ),
          SizedBox(width: r.s(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(seller.shopName, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: r.fs(13), fontWeight: FontWeight.w700)),
                SizedBox(height: r.s(2)),
                Row(children: [
                  Icon(Icons.flash_on, size: r.s(11), color: AppTheme.primary),
                  Flexible(child: Text('Répond en ${seller.responseTime}', maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: r.fs(10), color: AppTheme.mutedForeground))),
                ]),
                SizedBox(height: r.s(3)),
                Row(children: List.generate(5, (i) => Icon(i < seller.rating.floor() ? Icons.star : Icons.star_border, size: r.s(12), color: Colors.amber))),
              ],
            ),
          ),
          SizedBox(width: r.s(8)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onVisit != null)
                GestureDetector(
                  onTap: onVisit,
                  child: Text('Voir boutique', style: TextStyle(fontSize: r.fs(11), fontWeight: FontWeight.w600, color: AppTheme.primary)),
                ),
              SizedBox(height: r.s(6)),
              if (onChat != null)
                GestureDetector(
                  onTap: onChat,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: r.s(10), vertical: r.s(5)),
                    decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(r.rad(10))),
                    child: Text('Chat', style: TextStyle(fontSize: r.fs(12), fontWeight: FontWeight.w700, color: AppTheme.primary)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
