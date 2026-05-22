import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../controllers/order_controller.dart';
import '../../models/order_model.dart';
import '../../Api/config/api_constants.dart';
import '../../Api/firebase/services/chat_service.dart';
import '../../Api/provider/auth_controller.dart';
import '../../utils/app_toasts.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int _activeTab = 0; // 0 = Achats, 1 = Ventes

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<OrderController>()) {
        OrderController.to.fetchOrders();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvoked: (didPop) {
        if (!didPop) {
          Get.offAllNamed('/home');
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                shape: BoxShape.circle,
                boxShadow: AppTheme.shadowSm,
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: AppTheme.foreground, size: 20),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Get.back();
                  } else {
                    Get.offAllNamed('/home');
                  }
                },
              ),
            ),
          ),
          title: Text(
            'Mes commandes',
            style: TextStyle(
              color: AppTheme.foreground,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          centerTitle: false,
        ),
        body: Column(
          children: [
            const SizedBox(height: 12),
            // ── Tabs (Achats / Ventes) ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 54,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppTheme.muted,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    _buildTabPill('Achats', 0),
                    _buildTabPill('Ventes', 1),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Divider(height: 1, thickness: 1, color: AppTheme.border),
            // ── Orders List ───────────────────────────────────────────────────
            Expanded(
              child: Get.isRegistered<OrderController>()
                  ? Obx(() {
                      final ctrl = OrderController.to;
                      if (ctrl.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (ctrl.hasError.value) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Erreur de chargement'),
                              ElevatedButton(
                                onPressed: () => ctrl.fetchOrders(),
                                child: const Text('Réessayer'),
                              )
                            ],
                          ),
                        );
                      }
                      return IndexedStack(
                        index: _activeTab,
                        children: [
                          _buildList(ctrl.buyerOrders, isSale: false),
                          _buildList(
                              ctrl.sellerOrders
                                  .where((o) => o.product?.boutiqueId == null)
                                  .toList(),
                              isSale: true),
                        ],
                      );
                    })
                  : const Center(
                      child: Text('Module commandes non disponible')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabPill(String label, int index) {
    bool isActive = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.cardColor : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isActive ? AppTheme.shadowSm : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color:
                    isActive ? AppTheme.foreground : AppTheme.mutedForeground,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<OrderModel> orders, {required bool isSale}) {
    if (orders.isEmpty) {
      return Center(
        child: Text(
          isSale ? 'Aucune vente' : 'Aucun achat',
          style: TextStyle(color: AppTheme.mutedForeground),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => OrderController.to.fetchOrders(),
      color: AppTheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        itemCount: orders.length,
        itemBuilder: (context, i) {
          final order = orders[i];

          // Determine status color as per main branch design
          Color statusColor;
          Color textColor;
          switch (order.status) {
            case 'Acceptée':
            case 'Confirmé':
              statusColor = const Color(0xFFE8F5E9);
              textColor = const Color(0xFF2E7D32);
              break;
            case 'Refusée':
              statusColor = const Color(0xFFFFEBEE);
              textColor = const Color(0xFFC62828);
              break;
            case 'Terminée':
            case 'Terminé':
              statusColor = const Color(0xFFF2F2F7);
              textColor = const Color(0xFF8E8E93);
              break;
            case 'En attente':
            default:
              statusColor = const Color(0xFFFFF7E6);
              textColor = const Color(0xFFB45309);
              break;
          }

          final String? rawImage = order.product?.image;
          final imageUrl = (rawImage != null && rawImage.isNotEmpty)
              ? ApiConstants.resolveImageUrl(rawImage)
              : '';

          return _OrderCard(
            title: order.product?.titre ?? 'Produit #${order.productId}',
            price: '${order.formattedPrice} F',
            partnerLabel: isSale
                ? 'Acheteur:'
                : (order.product?.boutiqueNom != null
                    ? 'Boutique:'
                    : 'Vendeur:'),
            partnerName: isSale
                ? (order.user?.nom ?? 'Acheteur')
                : (order.product?.boutiqueNom ??
                    order.seller?.nom ??
                    'Vendeur'),
            image: imageUrl,
            status: order.status,
            statusColor: statusColor,
            textColor: textColor,
            isSale: isSale,
            order: order,
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final String title;
  final String price;
  final String partnerLabel;
  final String partnerName;
  final String image;
  final String status;
  final Color statusColor;
  final Color textColor;
  final bool isSale;
  final OrderModel order;

  const _OrderCard({
    required this.title,
    required this.price,
    required this.partnerLabel,
    required this.partnerName,
    required this.image,
    required this.status,
    required this.statusColor,
    required this.textColor,
    required this.isSale,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final navigateToDetails = () => Get.toNamed('/order-details', arguments: {
          'orderId': order.id.toString(),
          'title': title,
          'price': price,
          'status': status,
          'image': image,
          'vendor': isSale ? null : partnerName,
          'buyer': isSale ? partnerName : null,
          'isSale': isSale,
          'deliveryMethod': order.deliveryMethod,
          'deliveryAddress': order.deliveryAddress,
          'paymentMethod': order.paymentMethod,
          'phone': order.phone,
          'notes': order.notes,
          'date': order.formattedDate,
          'order': order,
        });

    return GestureDetector(
      onTap: navigateToDetails,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: image.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: image,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _imageFallback(),
                        )
                      : _imageFallback(),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.foreground,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        price,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.mutedForeground),
                          children: [
                            TextSpan(text: '$partnerLabel '),
                            TextSpan(
                              text: partnerName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Actions
            if (isSale && status == 'En attente')
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'Détails',
                      onTap: navigateToDetails,
                      isOutline: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionButton(
                      label: 'Accepter',
                      onTap: () =>
                          OrderController.to.acceptOrder(context, order),
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionButton(
                      label: 'Refuser',
                      onTap: () =>
                          OrderController.to.refuseOrder(context, order),
                      color: AppTheme.muted,
                      textColor: AppTheme.foreground,
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'Détails',
                      icon: Icons.visibility_outlined,
                      onTap: navigateToDetails,
                      isOutline: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (isSale && status == 'Acceptée') ...[
                    Expanded(
                      child: _ActionButton(
                        label: 'Terminer',
                        icon: Icons.check_circle_outline,
                        onTap: () =>
                            OrderController.to.completeOrder(context, order),
                        color: Colors.green.withOpacity(0.12),
                        textColor: Colors.green.shade700,
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: _ActionButton(
                        label: 'Chat',
                        icon: Icons.chat_bubble_outline,
                        onTap: () async {
                          final auth = Get.find<AuthController>();
                          final myUser = auth.currentUser.value;
                          if (myUser == null) {
                            AppToasts.error(
                                context, 'Erreur', 'Vous devez être connecté.');
                            return;
                          }

                          var myId = myUser.id.toString();
                          final myName = myUser.nom ?? 'Moi';
                          final myAvatar = myUser.avatarUrl ?? '';
                          final boutiqueId = order.product?.boutiqueId;

                          String otherId;
                          if (isSale) {
                            // Vendeur → acheteur (myId = boutiqueId si produit boutique)
                            otherId = order.userId.toString();
                            if (boutiqueId != null)
                              myId = boutiqueId.toString();
                          } else {
                            // Acheteur → boutique ou vendeur particulier
                            otherId = boutiqueId != null
                                ? boutiqueId.toString()
                                : order.sellerId.toString();
                          }

                          if (otherId.isEmpty) return;

                          try {
                            final chatId = await ChatService.to.getOrCreateChat(
                              myId: myId,
                              myName: myName,
                              myAvatar: myAvatar,
                              otherId: otherId,
                              otherName: partnerName,
                              otherAvatar: '',
                              productId: order.productId.toString(),
                              productTitle: title,
                              productImage: order.product?.image ?? '',
                            );
                            Get.toNamed(
                                '/chat/$chatId${isSale ? "?asBoutique=true" : ""}');
                          } catch (e) {
                            AppToasts.error(context, 'Erreur',
                                'Impossible d\'ouvrir le chat.');
                          }
                        },
                        color: AppTheme.primary.withOpacity(0.1),
                        textColor: AppTheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: AppTheme.muted,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(Icons.image_not_supported_outlined,
          color: AppTheme.mutedForeground, size: 28),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isOutline;
  final Color? color;
  final Color? textColor;
  final double? width;

  const _ActionButton({
    required this.label,
    this.icon,
    required this.onTap,
    this.isOutline = false,
    this.color,
    this.textColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 44,
        decoration: BoxDecoration(
          color: isOutline ? Colors.transparent : (color ?? AppTheme.primary),
          borderRadius: BorderRadius.circular(14),
          border: isOutline ? Border.all(color: AppTheme.primary) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 16,
                  color: isOutline
                      ? AppTheme.primary
                      : (textColor ?? Colors.white)),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color:
                    isOutline ? AppTheme.primary : (textColor ?? Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
