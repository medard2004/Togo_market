import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../controllers/app_controller.dart';
import '../../utils/responsive.dart';
import '../../utils/app_utils.dart';
import '../../Api/config/api_constants.dart';
import '../../models/models.dart';
import '../../Api/firebase/services/chat_service.dart';
import '../../Api/provider/auth_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../utils/app_toasts.dart';

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
    final ctrl = Get.find<AppController>();
    
    // Get product from global state
    final product = ctrl.products.firstWhereOrNull((p) => p.id.toString() == id);

    if (product == null) {
      return Scaffold(
        body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('😕', style: TextStyle(fontSize: 40)),
          const Text('Produit introuvable'),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: Get.back, child: const Text('Retour')),
        ])),
      );
    }

    final boutique = product.boutiqueObj;
    final similar = ctrl.getSimilarProducts(product.id.toString(), product.category);
    final images = product.images.isNotEmpty ? product.images : [product.image];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── AppBar flottante ────────────────────────────────────────────
              SliverAppBar(
                pinned: true,
                backgroundColor: AppTheme.cardColor,
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
                          imageUrl: ApiConstants.resolveImageUrl(images[i]),
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
                      SizedBox(height: r.s(8)),

                      // Badge de Stock Premium
                      _buildStockBadge(r, product),
                      SizedBox(height: r.s(16)),

                      // Localisation
                      Container(
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
                                  Text(boutique != null ? 'Adresse de la boutique' : 'Localisation (Quartier / Zone / Ville)',
                                      style: TextStyle(fontSize: r.fs(12), color: AppTheme.mutedForeground)),
                                  Text(
                                    boutique != null && boutique.adresse != null && boutique.adresse!.isNotEmpty
                                        ? '${boutique.adresse}${boutique.detailsAdresse != null && boutique.detailsAdresse!.isNotEmpty ? ' - ${boutique.detailsAdresse}' : ''}'
                                        : (product.location.isNotEmpty ? product.location : 'Lomé, Togo'),
                                      style: TextStyle(fontSize: r.fs(14), fontWeight: FontWeight.w700, color: AppTheme.foreground)),
                                ],
                              ),
                            ),
                          ],
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
                        children: [
                          if (product.categoryObj != null) product.categoryObj!.name,
                          product.condition,
                          product.isPriceNegotiable ? 'Prix Négociable' : 'Prix Fixe'
                        ]
                            .map((tag) => Container(
                                  padding: EdgeInsets.symmetric(horizontal: r.s(14), vertical: r.s(7)),
                                  decoration: BoxDecoration(
                                    color: AppTheme.muted,
                                    borderRadius: BorderRadius.circular(r.rad(30)),
                                  ),
                                  child: Text(tag.toString(),
                                      style: TextStyle(fontSize: r.fs(13), fontWeight: FontWeight.w500, color: AppTheme.foreground)),
                                ))
                            .toList(),
                      ),
                      SizedBox(height: r.s(20)),

                      // Carte vendeur
                      if (boutique != null)
                        _buildShopCard(r, boutique!)
                      else if (product.userObj != null)
                        _buildIndividualProfileCard(r, product.userObj!),
                      SizedBox(height: r.s(20)),

                      // ── Localisation (Mini-Carte) ───────────────────────────
                      Text('Localisation',
                          style: TextStyle(fontSize: r.fs(18), fontWeight: FontWeight.w700, color: AppTheme.foreground)),
                      SizedBox(height: r.s(12)),
                      _buildLocationCard(r, context, boutique, product),
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
                                  children: [
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
                color: AppTheme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(Get.isDarkMode ? 0.3 : 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
                border: Border(
                  top: BorderSide(color: AppTheme.border.withOpacity(0.5)),
                ),
              ),
              child: Row(
                children: [
                  // Bouton Commander (outline)
                  GestureDetector(
                    onTap: (product.stockType == 'stock' && product.stock <= 0) || (product.stockType == 'unique' && product.stock <= 0)
                        ? () {
                            AppToasts.error(context, 'Indisponible', 'Cet article n’est plus disponible.');
                          }
                        : () {
                            final auth = Get.find<AuthController>();
                            if (!auth.isAuthenticated) {
                              Get.toNamed('/auth', arguments: {
                                'redirect': '/order',
                                'arguments': {'productId': product.id},
                              });
                              return;
                            }
                            Get.toNamed('/order', arguments: {'productId': product.id});
                          },
                    child: Container(
                      height: r.s(50).clamp(44, 56),
                      padding: EdgeInsets.symmetric(horizontal: r.s(16)),
                      decoration: BoxDecoration(
                        color: (product.stockType == 'stock' && product.stock <= 0) || (product.stockType == 'unique' && product.stock <= 0)
                            ? Colors.grey.withOpacity(0.1)
                            : AppTheme.primaryLight.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(r.rad(30)),
                        border: Border.all(
                          color: (product.stockType == 'stock' && product.stock <= 0) || (product.stockType == 'unique' && product.stock <= 0)
                              ? Colors.grey
                              : AppTheme.primary,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            (product.stockType == 'stock' && product.stock <= 0) || (product.stockType == 'unique' && product.stock <= 0)
                                ? Icons.remove_shopping_cart_outlined
                                : Icons.shopping_cart_outlined,
                            size: r.s(18),
                            color: (product.stockType == 'stock' && product.stock <= 0) || (product.stockType == 'unique' && product.stock <= 0)
                                ? Colors.grey
                                : AppTheme.primary,
                          ),
                          SizedBox(width: r.s(6)),
                          Text(
                            (product.stockType == 'stock' && product.stock <= 0) || (product.stockType == 'unique' && product.stock <= 0)
                                ? 'Épuisé'
                                : 'Commander',
                            style: TextStyle(
                              fontSize: r.fs(13),
                              fontWeight: FontWeight.w800,
                              color: (product.stockType == 'stock' && product.stock <= 0) || (product.stockType == 'unique' && product.stock <= 0)
                                  ? Colors.grey
                                  : AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: r.s(10)),
                  // Bouton Discuter (plein)
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final auth = Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;
                        if (auth == null || !auth.isAuthenticated) {
                          Get.toNamed('/auth', arguments: {
                            'redirect': 'discuss_product',
                            'arguments': product,
                          });
                          return;
                        }
                        
                        final currentUser = auth.currentUser.value!;
                        final myId = currentUser.id.toString();
                        final myName = currentUser.nom ?? 'Utilisateur';
                        final myAvatar = currentUser.avatarUrl ?? '';
                        
                        // Déterminer l'ID du vendeur (boutique ou utilisateur)
                        final sellerId = boutique != null ? boutique.id.toString() : (product.userObj?.id.toString() ?? product.sellerId.toString());
                        
                        // Utiliser le nom/logo de la boutique pour l'affichage si c'est un pro
                        final sellerName = boutique?.nom ?? product.userObj?.nom ?? 'Vendeur';
                        final sellerAvatar = boutique?.logoUrl ?? product.userObj?.avatarUrl ?? '';
                        


                        try {
                          final chatId = await ChatService.to.getOrCreateChat(
                            myId: myId,
                            myName: myName,
                            myAvatar: myAvatar,
                            otherId: sellerId,
                            otherName: sellerName,
                            otherAvatar: sellerAvatar,
                            productId: product.id.toString(),
                            productTitle: product.title,
                            productImage: product.image,
                          );
                          Get.toNamed('/chat/$chatId', arguments: product);
                        } catch (e) {
                          AppToasts.error(context, 'Erreur Chat', 'Impossible de démarrer la discussion.');
                        }
                      },
                      child: Container(
                        height: r.s(50).clamp(44, 56),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(r.rad(30)),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: r.s(18)),
                            SizedBox(width: r.s(8)),
                            Flexible(
                              child: Text(
                                'Discuter',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: r.fs(15),
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
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

  // ── Design Boutique (branch main) ────────────────────────────────────────
  Widget _buildShopCard(R r, Boutique boutique) {
    final logoUrl = ApiConstants.resolveImageUrl(boutique.logoUrl);
    return Container(
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
                    backgroundColor: AppTheme.primaryLight,
                    backgroundImage: logoUrl.isNotEmpty
                        ? CachedNetworkImageProvider(logoUrl)
                        : null,
                    child: logoUrl.isEmpty
                        ? Icon(Icons.storefront, size: r.s(26), color: AppTheme.primary)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: r.s(12),
                      height: r.s(12),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
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
                    Text(boutique.nom,
                        style: TextStyle(
                            fontSize: r.fs(15),
                            fontWeight: FontWeight.w700,
                            color: AppTheme.foreground)),
                    SizedBox(height: r.s(2)),
                    Row(children: [
                      Icon(Icons.flash_on, size: r.s(12), color: AppTheme.primary),
                      SizedBox(width: r.s(2)),
                      Text('Vendeur Professionnel',
                          style: TextStyle(
                              fontSize: r.fs(12),
                              color: AppTheme.mutedForeground)),
                    ]),
                    SizedBox(height: r.s(2)),
                    if (boutique.adresse != null)
                      Text(boutique.adresse!.toUpperCase(),
                          style: TextStyle(
                              fontSize: r.fs(10),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              color: AppTheme.mutedForeground)),
                  ],
                ),
              ),
              Row(children: [
                Icon(Icons.star, size: r.s(14), color: Colors.amber),
                SizedBox(width: r.s(2)),
                Text('${boutique.noteMoyenne}',
                    style: TextStyle(
                        fontSize: r.fs(13),
                        fontWeight: FontWeight.w700,
                        color: AppTheme.foreground)),
              ]),
            ],
          ),
          SizedBox(height: r.s(12)),
          GestureDetector(
            onTap: () => Get.toNamed('/seller/${boutique.id}', arguments: boutique),
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
                    style: TextStyle(
                        fontSize: r.fs(14),
                        fontWeight: FontWeight.w600,
                        color: AppTheme.foreground)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Design Particulier (branch main) ─────────────────────────────────────
  Widget _buildIndividualProfileCard(R r, User user) {
    final avatarUrl = ApiConstants.resolveImageUrl(user.avatarUrl ?? '');
    return Container(
      padding: EdgeInsets.all(r.s(16)),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(r.rad(20)),
        border: Border.all(color: AppTheme.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: r.s(28),
            backgroundColor: AppTheme.secondary.withOpacity(0.15),
            backgroundImage: avatarUrl.isNotEmpty
                ? CachedNetworkImageProvider(avatarUrl)
                : null,
            child: avatarUrl.isEmpty
                ? Icon(Icons.person, size: r.s(28), color: AppTheme.secondary)
                : null,
          ),
          SizedBox(width: r.s(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nom ?? 'Utilisateur',
                  style: TextStyle(
                    fontSize: r.fs(16),
                    fontWeight: FontWeight.w800,
                    color: AppTheme.foreground,
                  ),
                ),
                SizedBox(height: r.s(2)),
                Text(
                  'Vendeur Particulier',
                  style: TextStyle(
                    fontSize: r.fs(11),
                    color: AppTheme.mutedForeground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: r.s(4)),
                Row(
                  children: [
                    Icon(Icons.verified_user, size: r.s(12), color: Colors.green),
                    SizedBox(width: r.s(4)),
                    Text(

                      'Vendeur vérifié',
                      style: TextStyle(
                        fontSize: r.fs(11),
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Get.toNamed('/profile/${user.id}'),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: r.s(12), vertical: r.s(8)),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(r.rad(10)),
              ),
              child: Icon(Icons.chevron_right, color: AppTheme.primary),
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

  Widget _buildLocationCard(R r, BuildContext context, dynamic boutique, dynamic product) {
    final double? lat = (boutique != null && boutique.latitude != 0) ? boutique.latitude as double? : null;
    final double? lon = (boutique != null && boutique.longitude != 0) ? boutique.longitude as double? : null;
    final bool hasCoords = lat != null && lon != null;

    // Adresse à afficher
    final String address = (boutique != null && boutique.adresse != null && boutique.adresse!.isNotEmpty)
        ? boutique.adresse!
        : (product.location?.isNotEmpty == true ? product.location : 'Localisation non renseignée');

    Future<void> openMaps() async {
      Uri? uri;
      if (hasCoords) {
        uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon');
      } else if (address.isNotEmpty && address != 'Localisation non renseignée') {
        uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}');
      }
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) AppToasts.error(context, 'Erreur', 'Localisation indisponible.');
      }
    }

    return GestureDetector(
      onTap: openMaps,
      child: Container(
        height: r.s(200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(r.rad(18)),
          border: Border.all(color: AppTheme.border),
          boxShadow: AppTheme.shadowCard,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // ── Carte interactive ──────────────────────────────────────────
            hasCoords
                ? FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(lat, lon),
                      initialZoom: 15.0,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none, // lecture seule, non scrollable
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.togo.market',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(lat, lon),
                            width: r.s(40),
                            height: r.s(40),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: AppTheme.shadowPrimary,
                                  ),
                                  child: const Icon(Icons.storefront, color: Colors.white, size: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                // ── Fallback : placeholder si pas de coords ────────────────
                : Container(
                    color: AppTheme.muted,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_off_outlined, size: r.s(40), color: AppTheme.mutedForeground),
                          SizedBox(height: r.s(8)),
                          Text('Carte non disponible',
                              style: TextStyle(color: AppTheme.mutedForeground, fontSize: r.fs(13))),
                        ],
                      ),
                    ),
                  ),

            // ── Overlay : adresse + bouton Maps ──────────────────────────
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: r.s(12), vertical: r.s(10)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.65), Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.directions_outlined, size: 13, color: AppTheme.primary),
                          const SizedBox(width: 4),
                          Text('Itinéraire',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                        ],
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

  Widget _buildStockBadge(R r, Product product) {
    final bool isOutOfStock = product.stockType == 'stock' && product.stock <= 0;
    final bool isUniqueAndSold = product.stockType == 'unique' && product.stock <= 0;

    if (isOutOfStock || isUniqueAndSold) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: r.s(10), vertical: r.s(6)),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(r.rad(8)),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: r.s(14), color: Colors.red),
            SizedBox(width: r.s(4)),
            Text(
              isUniqueAndSold ? 'Vendu / Indisponible' : 'Rupture de stock',
              style: TextStyle(
                fontSize: r.fs(12),
                fontWeight: FontWeight.w700,
                color: Colors.red,
              ),
            ),
          ],
        ),
      );
    }

    if (product.stockType == 'unique') {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: r.s(10), vertical: r.s(6)),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(r.rad(8)),
          border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_border_rounded, size: r.s(14), color: AppTheme.primary),
            SizedBox(width: r.s(4)),
            Text(
              'Pièce unique',
              style: TextStyle(
                fontSize: r.fs(12),
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
      );
    }

    final bool isLowStock = product.stock <= 3;
    final Color badgeColor = isLowStock ? Colors.orange : Colors.green;
    final IconData icon = isLowStock ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded;
    final String label = isLowStock
        ? 'Plus que ${product.stock} exemplaires restants !'
        : '${product.stock} en stock (disponible)';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.s(10), vertical: r.s(6)),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(r.rad(8)),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: r.s(14), color: badgeColor),
          SizedBox(width: r.s(4)),
          Text(
            label,
            style: TextStyle(
              fontSize: r.fs(12),
              fontWeight: FontWeight.w700,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}
