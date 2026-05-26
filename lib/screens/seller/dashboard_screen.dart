import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../animations/togo_animation_system.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/order_controller.dart';
import '../../models/order_model.dart';
import '../../Api/config/api_constants.dart';
import '../../Api/model/product_model.dart';
import '../../utils/app_utils.dart';
import '../../Api/firebase/controllers/chat_controller.dart';
import '../../controllers/boutique_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _tabIndex = 0; // 0: Articles, 1: Commandes, 2: Messages
  late final DashboardController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<DashboardController>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initDashboard());
  }

  Future<void> _initDashboard() async {
    // S'assurer que la boutique est chargée avant tout
    final boutiqueCtrl = Get.isRegistered<BoutiqueController>()
        ? BoutiqueController.to
        : null;
    if (boutiqueCtrl != null && boutiqueCtrl.myBoutique.value == null) {
      await boutiqueCtrl.checkMyBoutique();
    }

    _ctrl.loadMyProducts();

    // Charger les commandes vendeur
    if (Get.isRegistered<OrderController>()) {
      OrderController.to.fetchOrders();
    }

    final boutique = boutiqueCtrl?.myBoutique.value;
    if (boutique != null && Get.isRegistered<ChatController>()) {
      ChatController.to.initShopChats(boutique.id.toString());
    }
  }

  /// Gère le retour arrière :
  /// - Si on n'est pas sur l'onglet Articles (0), revenir sur Articles
  /// - Sinon, quitter l'écran
  void _handleBack() {
    if (_tabIndex != 0) {
      setState(() => _tabIndex = 0);
    } else {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Empêche la fermeture automatique quand on est sur un autre onglet
      canPop: _tabIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          // On est sur Commandes ou Messages → revenir sur Articles
          setState(() => _tabIndex = 0);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Column(
            children: [
              // ── Header ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCircleBtn(
                      Icons.arrow_back,
                      Colors.black,
                      Colors.white,
                      // Bouton retour UI : même logique que le bouton Android
                      onTap: _handleBack,
                    ),
                    Text(
                      'Mon Espace Vendeur',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.foreground,
                      ),
                    ),
                    _buildCircleBtn(
                      Icons.settings_outlined,
                      AppTheme.primary,
                      AppTheme.primaryLight,
                      onTap: () => Get.toNamed('/shop-information'),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Tab Navigation ──────────────────────────────────────
                      _buildTabSelector(),
                      const SizedBox(height: 24),

                      // ── Tab Content ─────────────────────────────────────────
                      Column(
                        key: ValueKey(_tabIndex),
                        children: [
                          if (_tabIndex == 0) ...[
                            _buildAddButton(),
                            const SizedBox(height: 24),
                            _buildArticlesTab(),
                          ] else if (_tabIndex == 1)
                            _buildOrdersTab()
                          else
                            _buildMessagesTab(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleBtn(IconData icon, Color iconColor, Color bg,
      {VoidCallback? onTap}) {
    return TogoPressableScale(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          boxShadow: bg == Colors.white
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      height: 72,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        children: [
          _buildTabItem(0, Icons.grid_view_outlined, 'Articles'),
          _buildTabItem(1, Icons.inventory_2_outlined, 'Commandes'),
          _buildTabItem(2, Icons.chat_bubble_outline_outlined, 'Messages'),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label) {
    bool isActive = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 20,
                  color: isActive ? Colors.white : AppTheme.mutedForeground),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppTheme.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () async {
        await Get.toNamed('/add-product', arguments: {'isParticulier': false});
        // Refresh products list after returning from add product
        _ctrl.loadMyProducts();
      },
      child: Container(
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          color: AppTheme.primaryLight.withOpacity(0.5),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: AppTheme.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: AppTheme.primary),
              SizedBox(width: 8),
              Text(
                'Ajouter un article',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArticlesTab() {
    return Obx(() {
      if (_ctrl.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.only(top: 40),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final products = _ctrl.myProducts;
      final activeProducts = products.where((p) => p.stock > 0).toList();
      final soldOutProducts = products.where((p) => p.stock <= 0).toList();

      if (products.isEmpty) {
        return Padding(
          padding: const EdgeInsets.only(top: 48),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.inventory_2_outlined,
                    size: 64, color: AppTheme.mutedForeground.withOpacity(0.4)),
                const SizedBox(height: 16),
                Text(
                  'Aucun article pour le moment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.mutedForeground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ajoutez votre premier produit\nen cliquant sur le bouton ci-dessus.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TogoSlideUp(
            child: Text(
              '${activeProducts.length} article${activeProducts.length > 1 ? 's' : ''} actif${activeProducts.length > 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.mutedForeground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...activeProducts.asMap().entries.map((entry) {
            final i = entry.key;
            final p = entry.value;
            return TogoSlideUp(
              delay: Duration(milliseconds: i * 80),
              child: _buildProductTile(p),
            );
          }),
          
          if (soldOutProducts.isNotEmpty) ...[
            const SizedBox(height: 24),
            TogoSlideUp(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.inventory_2_outlined,
                            size: 14, color: Color(0xFF9E8E87)),
                        const SizedBox(width: 6),
                        Text(
                          'Épuisés (${soldOutProducts.length})',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF9E8E87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...soldOutProducts.asMap().entries.map((entry) {
              final i = entry.key;
              final p = entry.value;
              return TogoSlideUp(
                delay: Duration(milliseconds: i * 80),
                child: Opacity(
                  opacity: 0.6,
                  child: _buildProductTile(p, isSoldOut: true),
                ),
              );
            }),
          ],
        ],
      );
    });
  }

  Widget _buildOrdersTab() {
    if (!Get.isRegistered<OrderController>()) {
      return const Center(child: Text('Module commandes non disponible'));
    }
    return Obx(() {
      final ctrl = OrderController.to;

      if (ctrl.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.only(top: 40),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (ctrl.hasError.value) {
        return Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi_off_rounded,
                    size: 48, color: AppTheme.mutedForeground.withOpacity(0.4)),
                const SizedBox(height: 12),
                Text('Impossible de charger les commandes',
                    style: TextStyle(color: AppTheme.mutedForeground)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: ctrl.fetchOrders,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        );
      }

      final orders = ctrl.sellerOrders.where((o) => o.product?.boutiqueId != null).toList();

      if (orders.isEmpty) {
        return Padding(
          padding: const EdgeInsets.only(top: 48),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.inventory_2_outlined,
                    size: 64, color: AppTheme.mutedForeground.withOpacity(0.4)),
                const SizedBox(height: 16),
                Text(
                  'Aucune commande pour le moment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.mutedForeground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vos commandes reçues s\'afficheront ici.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppTheme.mutedForeground),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        children: orders.asMap().entries.map((entry) {
          final i = entry.key;
          final order = entry.value;
          return TogoSlideUp(
            delay: Duration(milliseconds: i * 80),
            child: _buildOrderTile(context, order),
          );
        }).toList(),
      );
    });
  }

  Widget _buildOrderTile(BuildContext context, OrderModel order) {
    final isPending = order.status == 'En attente';
    final product   = order.product;
    final buyerName = order.user?.nom ?? 'Acheteur';

    final rawImage  = product?.image ?? '';
    final imageUrl  = rawImage.isNotEmpty ? ApiConstants.resolveImageUrl(rawImage) : '';

    final formattedPrice = '${order.formattedPrice} FCFA';

    // Couleur badge statut
    Color badgeBg; Color badgeFg;
    switch (order.status) {
      case 'Acceptée':  badgeBg = const Color(0xFFE8F5E9); badgeFg = const Color(0xFF2E7D32); break;
      case 'Refusée':   badgeBg = const Color(0xFFFFEBEE); badgeFg = const Color(0xFFC62828); break;
      case 'Terminée':  badgeBg = const Color(0xFFF2F2F7); badgeFg = const Color(0xFF8E8E93); break;
      default:          badgeBg = const Color(0xFFFFF7E6); badgeFg = const Color(0xFFB45309);
    }

    return GestureDetector(
      onTap: () => Get.toNamed('/order-details', arguments: {
        'orderId': order.id.toString(),
        'title': product?.titre ?? 'Commande #${order.id}',
        'price': formattedPrice,
        'status': order.status,
        'image': rawImage,
        'buyer': buyerName,
        'isSale': true,
        'deliveryMethod': order.deliveryMethod,
        'deliveryAddress': order.deliveryAddress,
        'paymentMethod': order.paymentMethod,
        'phone': order.phone,
        'notes': order.notes,
        'date': order.formattedDate,
        'order': order,
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.border,
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 64, height: 64, fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _dashboardImageFallback(),
                      )
                    : _dashboardImageFallback(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              product?.titre ?? 'Commande #${order.id}',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.foreground),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              order.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: badgeFg,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text('Acheteur : $buyerName',
                          style: TextStyle(
                              fontSize: 13, color: AppTheme.mutedForeground)),
                      const SizedBox(height: 2),
                      Text(formattedPrice,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (isPending) ...[
                  Expanded(
                    flex: 2,
                    child: TogoPressableScale(
                      onTap: () => OrderController.to.acceptOrder(context, order),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline,
                                color: Colors.white, size: 18),
                            SizedBox(width: 6),
                            Text('Accepter',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: TogoPressableScale(
                      onTap: () => OrderController.to.refuseOrder(context, order),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.destructive.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cancel_outlined,
                                color: AppTheme.destructive, size: 18),
                            const SizedBox(width: 6),
                            Text('Refuser',
                                style: TextStyle(
                                    color: AppTheme.destructive,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                if (order.status == 'Acceptée') ...[
                  Expanded(
                    flex: 2,
                    child: TogoPressableScale(
                      onTap: () => OrderController.to.completeOrder(context, order),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.done_all, color: Colors.green.shade700, size: 18),
                            const SizedBox(width: 6),
                            Text('Terminer',
                                style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  flex: 1,
                  child: TogoPressableScale(
                    onTap: () => Get.toNamed('/order-details', arguments: {
                      'orderId': order.id.toString(),
                      'title': product?.titre ?? 'Commande #${order.id}',
                      'price': formattedPrice,
                      'status': order.status,
                      'image': rawImage,
                      'buyer': buyerName,
                      'isSale': true,
                      'deliveryMethod': order.deliveryMethod,
                      'deliveryAddress': order.deliveryAddress,
                      'paymentMethod': order.paymentMethod,
                      'phone': order.phone,
                      'notes': order.notes,
                      'date': order.formattedDate,
                      'order': order,
                    }),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.muted,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Center(
                        child: Icon(Icons.visibility_outlined,
                            color: AppTheme.foreground, size: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardImageFallback() {
    return Container(
      width: 64, height: 64,
      color: AppTheme.muted,
      child: Icon(Icons.image_not_supported_outlined,
          color: AppTheme.mutedForeground, size: 24),
    );
  }

  Widget _buildMessagesTab() {
    if (!Get.isRegistered<ChatController>()) return const SizedBox.shrink();

    return Obx(() {
      final chats = ChatController.to.shopChats;
      final boutique = Get.isRegistered<BoutiqueController>()
          ? BoutiqueController.to.myBoutique.value
          : null;
      final shopId = boutique?.id.toString() ?? ChatController.to.currentUserId;
      final shopUid = 'shop_$shopId';

      if (chats.isEmpty) {
        return Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Center(
            child: Text(
              'Aucun message pour le moment',
              style: TextStyle(color: AppTheme.mutedForeground),
            ),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: chats.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final chat = chats[i];
          final otherUid = chat.otherParticipantUid(shopUid);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.muted,
                backgroundImage: chat.otherParticipantAvatar(shopUid).isNotEmpty
                    ? NetworkImage(chat.otherParticipantAvatar(shopUid))
                    : null,
                child: chat.otherParticipantAvatar(shopUid).isEmpty
                    ? Icon(Icons.person, color: AppTheme.mutedForeground)
                    : null,
              ),
              title: Text(chat.otherParticipantName(shopUid),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Row(
                children: [
                  if (chat.lastMessageSenderId == shopUid || chat.lastMessageSenderId == shopId) ...[
                    Icon(
                      chat.unreadCounts[otherUid] == 0 ? Icons.done_all : Icons.check,
                      size: 14,
                      color: chat.unreadCounts[otherUid] == 0 ? Colors.blueAccent : AppTheme.mutedForeground,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Expanded(
                    child: Text(chat.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              trailing: chat.unreadCountFor(shopUid) > 0
                  ? Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                          color: AppTheme.primary, shape: BoxShape.circle),
                      child: Text('${chat.unreadCountFor(shopUid)}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    )
                  : null,
              onTap: () => Get.toNamed('/chat/${chat.id}?asBoutique=true'),
            ),
          );
        },
      );
    });
  }

  Widget _buildProductTile(Product p, {bool isSoldOut = false}) {
    final imageUrl = ApiConstants.resolveImageUrl(p.image);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _imagePlaceholder(),
                        placeholder: (_, __) => _imagePlaceholder(),
                      )
                    : _imagePlaceholder(),
              ),
              if (isSoldOut)
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Épuisé',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.foreground,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  formatPrice(p.price),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.muted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    p.condition,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.mutedForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              TogoPressableScale(
                onTap: () async {
                  await Get.toNamed('/edit-product/${p.id}');
                  _ctrl.loadMyProducts();
                },
                child: _buildActionBtn(Icons.edit_outlined),
              ),
              const SizedBox(width: 8),
              TogoPressableScale(
                onTap: () => _confirmDelete(p),
                child: _buildActionBtn(Icons.delete_outline, isDelete: true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 72,
      height: 72,
      color: AppTheme.muted,
      child: Icon(Icons.image_not_supported,
          color: AppTheme.mutedForeground, size: 28),
    );
  }

  void _confirmDelete(Product p) {
    Get.dialog(
      AlertDialog(
        title: const Text('Supprimer ce produit ?'),
        content: Text('Voulez-vous vraiment supprimer "${p.title}" ?'),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _ctrl.deleteProduct(p.id.toString());
            },
            child: const Text('Supprimer',
                style: TextStyle(color: AppTheme.destructive)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, {bool isDelete = false}) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        shape: BoxShape.circle,
      ),
      child: Icon(icon,
          size: 18, color: isDelete ? AppTheme.destructive : AppTheme.primary),
    );
  }
}
