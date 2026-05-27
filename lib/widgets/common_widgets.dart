import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';
import '../models/models.dart'; // Exports Product, Boutique, Category
import '../theme/app_theme.dart';
import '../utils/app_utils.dart';
import '../controllers/app_controller.dart';
import '../utils/responsive.dart';
export '../theme/widgets/togo_button.dart';
export '../theme/widgets/togo_back_button.dart';
export '../theme/widgets/section_title.dart';
import '../utils/category_icon_helper.dart';
import '../Api/config/api_constants.dart';
import '../Api/firebase/services/chat_service.dart';
import '../Api/provider/auth_controller.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../utils/app_toasts.dart';

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
    final boutique = product.boutiqueObj;
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
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Image ───────────────────────────────────────────────────────
                Stack(
                  clipBehavior: Clip.none,
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
                      top: r.s(7),
                      left: r.s(7),
                      child:
                          _ConditionBadge(condition: product.condition, r: r),
                    ),
                    Positioned(
                      bottom: r.s(7),
                      right: r.s(7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _PriceBadge(price: product.price, r: r),
                          if (boutique != null) ...[
                            SizedBox(height: r.s(6)),
                            _buildShopBadge(context, boutique, r),
                          ] else if (product.userObj != null) ...[
                            SizedBox(height: r.s(6)),
                            _buildUserBadge(context, product.userObj!, r),
                          ],
                        ],
                      ),
                    ),
                    Positioned(
                      top: r.s(7),
                      right: r.s(7),
                      child: Obx(() {
                        final fav = ctrl.isFavorite(product.id);
                        return GestureDetector(
                          onTap: () => ctrl.toggleFavorite(product.id),
                          child: Container(
                            width: r.s(30),
                            height: r.s(30),
                            decoration: BoxDecoration(
                              color: AppTheme.cardColor.withOpacity(0.92),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              fav ? Icons.favorite : Icons.favorite_border,
                              size: r.s(14),
                              color: fav
                                  ? AppTheme.primary
                                  : AppTheme.mutedForeground,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
                // ── Infos ──────────────────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(r.s(9), r.s(8), r.s(9), r.s(9)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: r.fs(12),
                                fontWeight: FontWeight.w600,
                                color: AppTheme.foreground,
                              ),
                            ),
                          ),
                          SizedBox(width: r.s(4)),
                          GestureDetector(
                            onTap: () async {
                              final authCtrl = Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;
                              if (authCtrl == null || !authCtrl.isAuthenticated) {
                                Get.toNamed('/auth', arguments: {
                                  'redirect': '/product/${product.id}',
                                });
                                return;
                              }

                              final currentUser = authCtrl.currentUser.value;
                              if (currentUser == null) return;

                              // Déterminer le vendeur
                              final boutique = product.boutiqueObj;
                              final isShop = boutique != null;
                              final sellerId = isShop ? boutique.id.toString() : (product.userObj?.id.toString() ?? product.sellerId.toString());
                              final sellerName = isShop ? boutique.nom : (product.userObj?.nom ?? 'Vendeur');
                              final sellerAvatar = isShop ? (boutique.logoUrl ?? '') : (product.userObj?.avatarUrl ?? '');

                              try {
                                final chatId = await ChatService.to.getOrCreateChat(
                                  conversationType: isShop ? 'shop' : 'personal',
                                  myEntityId: currentUser.id.toString(),
                                  myEntityType: 'user',
                                  myName: currentUser.nom ?? 'Utilisateur',
                                  myAvatar: currentUser.avatarUrl ?? '',
                                  otherEntityId: sellerId,
                                  otherEntityType: isShop ? 'shop' : 'user',
                                  otherName: sellerName,
                                  otherAvatar: sellerAvatar,
                                  productId: product.id.toString(),
                                  productTitle: product.title,
                                  productImage: product.image,
                                  relatedShopId: isShop ? boutique.id.toString() : null,
                                );
                                Get.toNamed('/chat/$chatId?asBoutique=false', arguments: product);
                              } catch (e) {
                                AppToasts.error(context, 'Erreur', 'Impossible de démarrer la discussion.');
                              }
                            },
                            child: PhosphorIcon(
                              PhosphorIcons.chatCircleDots(),
                              size: r.s(15),
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: r.s(3)),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: r.s(10), color: AppTheme.mutedForeground),
                          SizedBox(width: r.s(2)),
                          Expanded(
                            child: Text(
                              product.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: r.fs(10),
                                  color: AppTheme.mutedForeground),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopBadge(BuildContext context, Boutique boutique, R r) {
    final logoUrl = ApiConstants.resolveImageUrl(boutique.logoUrl);
    return GestureDetector(
      onTap: () => _showShopInfo(context, boutique, r),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(r.s(3)),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(r.rad(20)),
          boxShadow: AppTheme.shadowSm,
          border: Border.all(color: AppTheme.cardColor, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: r.s(6),
              backgroundImage: logoUrl.isNotEmpty ? CachedNetworkImageProvider(logoUrl) : null,
              backgroundColor: AppTheme.primaryLight,
            ),
            SizedBox(width: r.s(5)),
            Padding(
              padding: EdgeInsets.only(right: r.s(8)),
              child: Text(
                boutique.nom,
                style: TextStyle(
                  fontSize: r.fs(9),
                  fontWeight: FontWeight.w800,
                  color: AppTheme.foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserBadge(BuildContext context, User user, R r) {
    final logoUrl = ApiConstants.resolveImageUrl(user.avatarUrl ?? '');
    return GestureDetector(
      onTap: () => Get.toNamed('/profile/${user.id}'),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(r.s(3)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(r.rad(20)),
          boxShadow: AppTheme.shadowSm,
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: r.s(6),
              backgroundImage: logoUrl.isNotEmpty ? CachedNetworkImageProvider(logoUrl) : null,
              backgroundColor: AppTheme.secondary.withOpacity(0.2),
              child: logoUrl.isEmpty ? Icon(Icons.person, size: r.s(8), color: AppTheme.secondary) : null,
            ),
            SizedBox(width: r.s(5)),
            Padding(
              padding: EdgeInsets.only(right: r.s(8)),
              child: Text(
                user.nom ?? 'Utilisateur',
                style: TextStyle(
                  fontSize: r.fs(9),
                  fontWeight: FontWeight.w800,
                  color: AppTheme.foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showShopInfo(BuildContext context, Boutique boutique, R r) {
    final logoUrl = ApiConstants.resolveImageUrl(boutique.logoUrl);
    final bannerUrl = ApiConstants.resolveImageUrl(boutique.bannerUrl);
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(r.rad(30))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Banner Image ──
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                // Banner
                ClipRRect(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(r.rad(30))),
                  child: SizedBox(
                    height: r.s(130),
                    width: double.infinity,
                    child: bannerUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: bannerUrl, fit: BoxFit.cover)
                        : Container(color: AppTheme.primary.withOpacity(0.1)),
                  ),
                ),
                // Gradient overlay
                Container(
                  height: r.s(130),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(r.rad(30))),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.transparent,
                        Colors.black.withOpacity(0.1)
                      ],
                    ),
                  ),
                ),
                // Drag Handle
                Positioned(
                  top: r.s(12),
                  child: Container(
                    width: r.s(40),
                    height: r.s(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Avatar (Overflowing)
                Positioned(
                  bottom: -r.s(40),
                  child: Container(
                    padding: EdgeInsets.all(r.s(4)),
                    decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]),
                    child: CircleAvatar(
                      radius: r.s(42),
                      backgroundColor: AppTheme.muted,
                      backgroundImage: logoUrl.isNotEmpty
                          ? CachedNetworkImageProvider(logoUrl)
                          : null,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: r.s(48)), // Espace pour l'avatar qui déborde

            // ── Infos ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: r.hPad),
              child: Column(
                children: [
                  Text(boutique.nom,
                      style: TextStyle(
                          fontSize: r.fs(18),
                          fontWeight: FontWeight.w900,
                          color: AppTheme.foreground)),
                  SizedBox(height: r.s(6)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on_rounded,
                          size: r.s(12), color: AppTheme.mutedForeground),
                      SizedBox(width: r.s(4)),
                      Text(boutique.adresse ?? 'Togo',
                          style: TextStyle(
                              fontSize: r.fs(11),
                              color: AppTheme.mutedForeground,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  SizedBox(height: r.s(20)),

                  // ── Stats Row (Réduit) ──
                  Container(
                    padding: EdgeInsets.symmetric(vertical: r.s(10)),
                    decoration: BoxDecoration(
                      color: AppTheme.muted.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(r.rad(16)),
                      border: Border.all(color: AppTheme.border.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatBox(
                            r,
                            Icons.star_rounded,
                            Colors.amber,
                            boutique.noteMoyenne > 0 ? boutique.noteMoyenne.toString() : '-',
                            'Note'),
                        Container(
                            height: r.s(20),
                            width: 1,
                            color: Colors.grey.withOpacity(0.2)),
                        _buildStatBox(
                            r,
                            Icons.storefront_rounded,
                            AppTheme.primary,
                            'Pro',
                            'Boutique'),
                        Container(
                            height: r.s(20),
                            width: 1,
                            color: Colors.grey.withOpacity(0.2)),
                        _buildStatBox(r, Icons.flash_on_rounded, Colors.green,
                            '~1h', 'Réponse'),
                      ],
                    ),
                  ),
                  SizedBox(height: r.s(28)),

                  // ── Premium Action Buttons ──
                  Row(
                    children: [
                      // Chat Button
                      Container(
                        height: r.s(56),
                        width: r.s(56),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(r.rad(18)),
                          border: Border.all(
                              color: AppTheme.primary.withOpacity(0.2),
                              width: 1.5),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(r.rad(18)),
                            onTap: () async {
                              Get.back();
                              final auth = Get.find<AuthController>();
                              final me = auth.currentUser.value;
                              if (me == null) {
                                Get.toNamed('/auth');
                                return;
                              }
                              try {
                                final chatId =
                                    await ChatService.to.getOrCreateChat(
                                  conversationType: 'shop',
                                  myEntityId: me.id.toString(),
                                  myEntityType: 'user',
                                  myName: me.nom ?? 'Utilisateur',
                                  myAvatar: me.avatarUrl ?? '',
                                  otherEntityId: boutique.id.toString(),
                                  otherEntityType: 'shop',
                                  otherName: boutique.nom,
                                  otherAvatar: boutique.logoUrl ?? '',
                                  relatedShopId: boutique.id.toString(),
                                );
                                Get.toNamed('/chat/$chatId?asBoutique=false');
                              } catch (_) {
                                Get.snackbar(
                                  'Erreur',
                                  'Impossible d\'ouvrir la conversation.',
                                  snackPosition: SnackPosition.TOP,
                                );
                              }
                            },
                            child: Center(
                              child: Icon(Icons.forum_rounded,
                                  color: AppTheme.primary, size: r.s(26)),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: r.s(16)),

                      // Visit Shop Button
                      Expanded(
                        child: Container(
                          height: r.s(56),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(r.rad(18)),
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primary,
                                Color.lerp(
                                    AppTheme.primary, Colors.black, 0.15)!
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              )
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(r.rad(18)),
                              onTap: () {
                                Get.back();
                                Get.toNamed('/seller/${boutique.id}');
                              },
                              child: Center(
                                child: Text(
                                  'Visiter la boutique',
                                  style: TextStyle(
                                    fontSize: r.fs(16),
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: r.s(32)),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildStatBox(
      R r, IconData icon, Color color, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: r.s(14), color: color),
            SizedBox(width: r.s(4)),
            Text(value,
                style: TextStyle(
                    fontSize: r.fs(14),
                    fontWeight: FontWeight.w800,
                    color: AppTheme.foreground)),
          ],
        ),
        SizedBox(height: r.s(2)),
        Text(label,
            style: TextStyle(
                fontSize: r.fs(10),
                color: AppTheme.mutedForeground,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildImage() {
    final imageUrl = ApiConstants.resolveImageUrl(product.image);
    if (imageUrl.isEmpty) {
      return Container(
        color: AppTheme.muted,
        child: Center(
          child:
              Icon(Icons.image_not_supported, color: AppTheme.mutedForeground),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
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
        child: Center(
          child:
              Icon(Icons.image_not_supported, color: AppTheme.mutedForeground),
        ),
      ),
    );
  }
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
            color:
                condition == 'Neuf' ? Colors.white : AppTheme.mutedForeground,
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
          style: TextStyle(
              fontSize: r.fs(10),
              fontWeight: FontWeight.w700,
              color: Colors.white),
        ),
      );
}

// ── FavoriteTicketCard ────────────────────────────────────────────────────────
class FavoriteTicketCard extends StatelessWidget {
  final Product product;
  const FavoriteTicketCard({super.key, required this.product});

  static const _fallbackIcons = [
    Icons.shopping_bag_rounded,
    Icons.devices_rounded,
    Icons.checkroom_rounded,
    Icons.home_rounded,
    Icons.face_retouching_natural_rounded,
    Icons.build_rounded,
  ];

  static const _fallbackColors = [
    Color(0xFF1E6EBF),
    Color(0xFFB0387A),
    Color(0xFF7B3FB5),
    Color(0xFF2A7A4B),
    Color(0xFFD44A6A),
    Color(0xFF4A7AB5),
  ];

  Color _stripeColor() {
    if (product.categoryObj != null) {
      final id = product.categoryObj!.id;
      return _fallbackColors[id % _fallbackColors.length];
    }
    final intId = int.tryParse(product.category) ?? 0;
    return _fallbackColors[intId % _fallbackColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    final ctrl = Get.find<AppController>();

    // Use real boutique name or user name if available
    final shopName = product.boutiqueObj?.nom ?? product.userObj?.nom ?? 'Vendeur';
    final isParticulier = product.boutiqueObj == null;

    final stripe = _stripeColor();
    final catLabel = product.categoryObj?.name ?? 'Produit';
    final iconData = CategoryIconHelper.getIconFromString(product.categoryObj?.icon);

    return GestureDetector(
      onTap: () => Get.toNamed('/product/${product.id}'),
      child: Container(
        height: r.s(92).clamp(80.0, 108.0),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(r.rad(16)),
          boxShadow: AppTheme.shadowCard,
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Bande colorée gauche ──────────────────────────────────────
            Container(
              width: r.s(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [stripe, AppTheme.secondary],
                ),
              ),
            ),

            // ── Zone image / emoji ────────────────────────────────────────
            SizedBox(
              width: r.s(80).clamp(68.0, 96.0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Builder(builder: (_) {
                    final imgUrl = ApiConstants.resolveImageUrl(product.image);
                    if (imgUrl.isEmpty) {
                      return Container(
                        color: stripe.withOpacity(0.12),
                        child: Center(
                            child:
                                Icon(iconData, size: r.s(32), color: stripe)),
                      );
                    }
                    return CachedNetworkImage(
                      imageUrl: imgUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: stripe.withOpacity(0.12),
                        child: Center(
                            child:
                                Icon(iconData, size: r.s(32), color: stripe)),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: stripe.withOpacity(0.12),
                        child: Center(
                            child:
                                Icon(iconData, size: r.s(32), color: stripe)),
                      ),
                    );
                  }),
                  // Overlay léger sur l'image
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.08)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Séparateur pointillé ──────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(vertical: r.s(10)),
              child: SizedBox(
                width: r.s(14),
                child: CustomPaint(
                    painter: _DashedLinePainter(color: AppTheme.muted)),
              ),
            ),

            // ── Infos produit ─────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, r.s(10), r.s(12), r.s(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Catégorie
                    Text(
                      catLabel.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: r.fs(9),
                        fontWeight: FontWeight.w700,
                        color: stripe,
                        letterSpacing: 0.8,
                      ),
                    ),
                    // Titre
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: r.fs(13),
                        fontWeight: FontWeight.w600,
                        color: AppTheme.foreground,
                        height: 1.25,
                      ),
                    ),
                    // Prix + vendeur
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            formatPrice(product.price),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: r.fs(14),
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(isParticulier ? Icons.person_rounded : Icons.storefront_rounded,
                                size: r.s(10), color: AppTheme.mutedForeground),
                            SizedBox(width: r.s(3)),
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: r.s(72)),
                              child: Text(
                                shopName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: r.fs(9),
                                    color: AppTheme.mutedForeground),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Bouton cœur ───────────────────────────────────────────────
            Obx(() {
              final fav = ctrl.isFavorite(product.id);
              return GestureDetector(
                onTap: () => ctrl.toggleFavorite(product.id),
                child: Container(
                  width: r.s(40),
                  color: Colors.transparent,
                  child: Center(
                    child: Icon(
                      fav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: r.s(22),
                      color: fav ? AppTheme.primary : AppTheme.mutedForeground,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// Peintre pour la ligne pointillée verticale
class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const dashH = 4.0;
    const gap = 4.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(Offset(size.width / 2, y),
          Offset(size.width / 2, (y + dashH).clamp(0, size.height)), paint);
      y += dashH + gap;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
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

// ── CategoryPill ──────────────────────────────────────────────────────────────
class CategoryPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const CategoryPill({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

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
            Icon(
              icon,
              size: r.fs(15),
              color: isActive ? Colors.white : AppTheme.primary,
            ),
            SizedBox(width: r.s(6)),
            Text(
              label,
              maxLines: 1,
              style: TextStyle(
                  fontSize: r.fs(12),
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppTheme.foreground),
            ),
          ],
        ),
      ),
    );
  }
}

// ── SellerCard ────────────────────────────────────────────────────────────────
class SellerCard extends StatelessWidget {
  final Boutique? boutique;
  final User? user;
  final VoidCallback? onChat;
  final VoidCallback? onVisit;

  const SellerCard(
      {super.key, this.boutique, this.user, this.onChat, this.onVisit});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    final isShop = boutique != null;
    final String name = isShop ? boutique!.nom : (user?.nom ?? 'Utilisateur');
    final String avatar = isShop ? ApiConstants.resolveImageUrl(boutique!.logoUrl) : ApiConstants.resolveImageUrl(user?.avatarUrl ?? '');
    final double rating = isShop ? boutique!.noteMoyenne : 0.0;
    
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
              CircleAvatar(
                  radius: r.s(24),
                  backgroundColor: AppTheme.secondary.withOpacity(0.2),
                  backgroundImage: avatar.isNotEmpty ? CachedNetworkImageProvider(avatar) : null,
                  child: avatar.isEmpty ? Icon(isShop ? Icons.storefront : Icons.person, color: AppTheme.secondary) : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: r.s(11),
                  height: r.s(11),
                  decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2)),
                ),
              ),
            ],
          ),
          SizedBox(width: r.s(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: r.fs(13), fontWeight: FontWeight.w700)),
                SizedBox(height: r.s(2)),
                Row(children: [
                  Icon(isShop ? Icons.flash_on : Icons.person, size: r.s(11), color: isShop ? AppTheme.primary : AppTheme.secondary),
                  SizedBox(width: r.s(4)),
                  Flexible(
                      child: Text(isShop ? 'Vendeur Professionnel' : 'Vendeur Particulier',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: r.fs(10),
                              color: AppTheme.mutedForeground))),
                ]),
                SizedBox(height: r.s(3)),
                if (isShop)
                  Row(
                      children: List.generate(
                          5,
                          (i) => Icon(
                              i < rating.floor()
                                  ? Icons.star
                                  : Icons.star_border,
                              size: r.s(12),
                              color: Colors.amber))),
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
                  child: Text(isShop ? 'Voir boutique' : 'Voir le profil',
                      style: TextStyle(
                          fontSize: r.fs(11),
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary)),
                ),
              SizedBox(height: r.s(6)),
              if (onChat != null)
                GestureDetector(
                  onTap: onChat,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: r.s(10), vertical: r.s(5)),
                    decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(r.rad(10))),
                    child: Text('Chat',
                        style: TextStyle(
                            fontSize: r.fs(12),
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── ShopCarouselCard ─────────────────────────────────────────────────────────
class ShopCarouselCard extends StatelessWidget {
  final Boutique boutique;
  final VoidCallback? onTap;

  const ShopCarouselCard({super.key, required this.boutique, this.onTap});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    final logoUrl = ApiConstants.resolveImageUrl(boutique.logoUrl);
    final bannerUrl = ApiConstants.resolveImageUrl(boutique.bannerUrl);

    return GestureDetector(
      onTap: onTap ?? () => Get.toNamed('/seller/${boutique.id}'),
      child: Container(
        width: r.s(160),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(r.rad(24)),
          boxShadow: AppTheme.shadowCard,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background / Banner + info
            Column(
              children: [
                // ── Banner ──────────────────────────────────────────────
                SizedBox(
                  height: r.s(85),
                  width: double.infinity,
                  child: bannerUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: bannerUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _GradientBanner(),
                          errorWidget: (_, __, ___) => _GradientBanner(),
                        )
                      : _GradientBanner(),
                ),
                Padding(
                  padding:
                      EdgeInsets.fromLTRB(r.s(12), r.s(24), r.s(12), r.s(12)),
                  child: Column(
                    children: [
                      Text(
                        boutique.nom,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: r.fs(13),
                          fontWeight: FontWeight.w800,
                          color: AppTheme.foreground,
                        ),
                      ),
                      SizedBox(height: r.s(4)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_on_rounded,
                              size: r.s(10), color: AppTheme.mutedForeground),
                          SizedBox(width: r.s(2)),
                          Flexible(
                            child: Text(
                              boutique.adresse ?? 'Lomé',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: r.fs(10),
                                color: AppTheme.mutedForeground,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Floating Avatar
            Positioned(
              top: r.s(55),
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(r.s(3)),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: AppTheme.border.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 4)),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: r.s(20),
                    backgroundColor: AppTheme.primaryLight,
                    backgroundImage: logoUrl.isNotEmpty ? CachedNetworkImageProvider(logoUrl) : null,
                    child: logoUrl.isEmpty ? Icon(Icons.storefront, color: AppTheme.primary, size: r.s(20)) : null,
                  ),
                ),
              ),
            ),
            // Rating Badge
            Positioned(
              top: r.s(8),
              right: r.s(8),
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: r.s(8), vertical: r.s(4)),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(r.rad(12)),
                  boxShadow: AppTheme.shadowSm,
                ),
                child: Row(
                  children: [
                    Icon(Icons.star_rounded,
                        color: Colors.amber, size: 12),
                    SizedBox(width: 2),
                    Text(
                      boutique.noteMoyenne.toString(),
                      style: TextStyle(
                        fontSize: r.fs(10),
                        fontWeight: FontWeight.w800,
                        color: AppTheme.foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Fallback gradient banner used in ShopCarouselCard ────────────────────────
class _GradientBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary.withOpacity(0.15),
            AppTheme.secondary.withOpacity(0.08),
          ],
        ),
      ),
      child: Center(
        child: Opacity(
          opacity: 0.12,
          child: const Icon(Icons.storefront_rounded, size: 54, color: AppTheme.primary),
        ),
      ),
    );
  }
}
