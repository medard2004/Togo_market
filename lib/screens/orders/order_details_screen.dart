import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../Api/config/api_constants.dart';
import '../../Api/firebase/services/chat_service.dart';
import '../../Api/provider/auth_controller.dart';
import '../../controllers/order_controller.dart';
import '../../models/order_model.dart';
import '../../utils/app_toasts.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    final Map<String, dynamic> orderData = Get.arguments ?? {};

    final String orderIdArg = (orderData['orderId'] ?? '').toString();
    final int orderIdInt = int.tryParse(
            orderIdArg.replaceAll('#', '').replaceAll('TG-', '').trim()) ??
        0;
    final bool isSale = orderData['isSale'] ?? false;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              shape: BoxShape.circle,
              boxShadow: AppTheme.shadowSm,
            ),
            child: IconButton(
              icon:
                  Icon(Icons.arrow_back, color: AppTheme.foreground, size: 20),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: Text(
          'Détails de commande',
          style: TextStyle(
            color: AppTheme.foreground,
            fontSize: r.fs(16),
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz,
                color: AppTheme.foreground, size: r.s(24)),
            onPressed: () {},
          ),
        ],
      ),
      body: Obx(() {
        final ctrl = Get.find<OrderController>();
        OrderModel? order = orderData['order'] as OrderModel?;
        if (orderIdInt != 0) {
          final foundOrder = isSale
              ? ctrl.sellerOrders.firstWhereOrNull((o) => o.id == orderIdInt)
              : ctrl.buyerOrders.firstWhereOrNull((o) => o.id == orderIdInt);
          if (foundOrder != null) {
            order = foundOrder;
          }
        }

        final String title =
            order?.product?.titre ?? orderData['title'] ?? 'Commande';
        final String price = order != null
            ? '${order.formattedPrice} F'
            : (orderData['price'] ?? '0 F');
        final String status =
            order?.status ?? orderData['status'] ?? 'En attente';
        final String rawImage =
            order?.product?.image ?? orderData['image'] ?? '';
        final String image = rawImage.isNotEmpty
            ? (rawImage.startsWith('http')
                ? rawImage
                : ApiConstants.resolveImageUrl(rawImage))
            : '';
        final String partnerName = order != null
            ? (isSale
                ? (order.user?.nom ?? 'Acheteur')
                : (order.product?.boutiqueNom ??
                    order.seller?.nom ??
                    'Vendeur'))
            : (orderData['vendor'] ?? orderData['buyer'] ?? 'Inconnu');
        final String orderId = order != null
            ? '#TG-${order.id}'
            : (orderData['orderId'] ?? '#TG-8829');
        final String date = order != null
            ? order.formattedDate
            : (orderData['date'] ?? '08 Mai 2026, 09:45');

        Color statusColor;
        Color textColor;

        switch (status) {
          case 'Acceptée':
          case 'Confirmé':
            statusColor = const Color(0xFFE8F5E9);
            textColor = const Color(0xFF2E7D32);
            break;
          case 'Refusée':
          case 'Annulé':
            statusColor = const Color(0xFFFFEBEE);
            textColor = const Color(0xFFC62828);
            break;
          case 'Terminée':
          case 'Terminé':
            statusColor = const Color(0xFFF2F2F7);
            textColor = const Color(0xFF8E8E93);
            break;
          default: // En attente
            statusColor = const Color(0xFFFFF7E6);
            textColor = const Color(0xFFB45309);
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(r.s(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Status Banner ────────────────────────────────────────────────
              Container(
                padding: EdgeInsets.all(r.s(16)),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(r.rad(20)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(r.s(10)),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        status == 'Terminée' || status == 'Terminé'
                            ? Icons.check_circle
                            : Icons.access_time_filled,
                        color: textColor,
                        size: r.s(20),
                      ),
                    ),
                    SizedBox(width: r.s(16)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Statut : $status',
                            style: TextStyle(
                              fontSize: r.fs(15),
                              fontWeight: FontWeight.w800,
                              color: textColor,
                            ),
                          ),
                          Text(
                            status == 'En attente'
                                ? 'Le vendeur doit confirmer votre commande.'
                                : status == 'Acceptée' || status == 'Confirmé'
                                    ? 'Le vendeur a accepté votre commande.'
                                    : status == 'Refusée'
                                        ? 'La commande a été refusée.'
                                        : status == 'Terminée' ||
                                                status == 'Terminé'
                                            ? 'Commande livrée et terminée.'
                                            : 'Commande traitée le $date',
                            style: TextStyle(
                              fontSize: r.fs(12),
                              color: textColor.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: r.s(24)),

              // ── Order Info ───────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Numéro de commande',
                        style: TextStyle(
                          fontSize: r.fs(12),
                          color: AppTheme.mutedForeground,
                        ),
                      ),
                      Text(
                        orderId,
                        style: TextStyle(
                          fontSize: r.fs(16),
                          fontWeight: FontWeight.w800,
                          color: AppTheme.foreground,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Date',
                        style: TextStyle(
                          fontSize: r.fs(12),
                          color: AppTheme.mutedForeground,
                        ),
                      ),
                      Text(
                        date.split(',')[0],
                        style: TextStyle(
                          fontSize: r.fs(14),
                          fontWeight: FontWeight.w700,
                          color: AppTheme.foreground,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: r.s(24)),

              // ── Product Details ──────────────────────────────────────────────
              Text(
                'Articles',
                style: TextStyle(
                  fontSize: r.fs(15),
                  fontWeight: FontWeight.w800,
                  color: AppTheme.foreground,
                ),
              ),
              SizedBox(height: r.s(12)),
              Container(
                padding: EdgeInsets.all(r.s(12)),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(r.rad(20)),
                  boxShadow: AppTheme.shadowSm,
                  border: Border.all(color: AppTheme.border.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(r.rad(15)),
                      child: image.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: image,
                              width: r.s(80),
                              height: r.s(80),
                              fit: BoxFit.cover,
                              placeholder: (_, __) =>
                                  _ImagePlaceholder(size: r.s(80)),
                              errorWidget: (_, __, ___) =>
                                  _ImagePlaceholder(size: r.s(80)),
                            )
                          : _ImagePlaceholder(size: r.s(80)),
                    ),
                    SizedBox(width: r.s(16)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: r.fs(14),
                              fontWeight: FontWeight.w700,
                              color: AppTheme.foreground,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: r.s(4)),
                          Text(
                            'Quantité: ${order?.quantity ?? 1}',
                            style: TextStyle(
                              fontSize: r.fs(12),
                              color: AppTheme.mutedForeground,
                            ),
                          ),
                          SizedBox(height: r.s(4)),
                          Text(
                            price,
                            style: TextStyle(
                              fontSize: r.fs(16),
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: r.s(24)),

              // ── Partner Info (Seller/Buyer) ──────────────────────────────────
              Text(
                isSale
                    ? 'Informations de l\'acheteur'
                    : (order?.product?.boutiqueNom != null
                        ? 'Informations de la boutique'
                        : 'Informations du vendeur'),
                style: TextStyle(
                  fontSize: r.fs(15),
                  fontWeight: FontWeight.w800,
                  color: AppTheme.foreground,
                ),
              ),
              SizedBox(height: r.s(12)),
              Container(
                padding: EdgeInsets.all(r.s(16)),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(r.rad(20)),
                  boxShadow: AppTheme.shadowSm,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: r.s(24),
                      backgroundColor: AppTheme.primary.withOpacity(0.1),
                      child: Text(
                        partnerName.isNotEmpty
                            ? partnerName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: r.fs(18),
                        ),
                      ),
                    ),
                    SizedBox(width: r.s(16)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            partnerName,
                            style: TextStyle(
                              fontSize: r.fs(14),
                              fontWeight: FontWeight.w700,
                              color: AppTheme.foreground,
                            ),
                          ),
                          SizedBox(height: r.s(2)),
                          Text(
                            'Lomé, Togo',
                            style: TextStyle(
                              fontSize: r.fs(12),
                              color: AppTheme.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        _IconButton(
                          icon: Icons.chat_bubble_outline,
                          onTap: () async {
                            final auth = Get.find<AuthController>();
                            final myUser = auth.currentUser.value;
                            if (myUser == null) {
                              AppToasts.error(context, 'Erreur',
                                  'Vous devez être connecté.');
                              return;
                            }

                            var myId = myUser.id.toString();
                            String myName = myUser.nom ?? 'Moi';
                            String myAvatar = myUser.avatarUrl ?? '';

                            final String otherId;
                            final String otherAvatar;
                            final boutiqueId = order?.product?.boutiqueId;
                            String myEntityType = 'user';
                            String otherEntityType = 'user';
                            String conversationType = 'personal';

                            if (isSale) {
                              otherId = order?.userId.toString() ?? '';
                              otherAvatar = order?.user?.avatar ?? '';
                              if (boutiqueId != null) {
                                myId = boutiqueId.toString();
                                myName = order?.product?.boutiqueNom ?? myName;
                                myEntityType = 'shop';
                                conversationType = 'shop';
                              }
                            } else {
                              otherId = boutiqueId != null
                                  ? boutiqueId.toString()
                                  : (order?.sellerId.toString() ?? '');
                              otherAvatar = order?.seller?.avatar ?? '';
                              if (boutiqueId != null) {
                                otherEntityType = 'shop';
                                conversationType = 'shop';
                              }
                            }

                            if (otherId.isEmpty) {
                              AppToasts.error(context, 'Erreur',
                                  'Impossible de démarrer le chat.');
                              return;
                            }

                            Get.dialog(
                              const Center(child: CircularProgressIndicator()),
                              barrierDismissible: false,
                            );

                            try {
                              final chatId =
                                  await ChatService.to.getOrCreateChat(
                                conversationType: conversationType,
                                myEntityId: myId,
                                myEntityType: myEntityType,
                                myName: myName,
                                myAvatar: myAvatar,
                                otherEntityId: otherId,
                                otherEntityType: otherEntityType,
                                otherName: partnerName,
                                otherAvatar: otherAvatar,
                                productId: order?.productId.toString() ??
                                    orderData['productId']?.toString(),
                                productTitle: title,
                                productImage: rawImage,
                                relatedShopId: boutiqueId?.toString(),
                              );
                              Get.back();
                              Get.toNamed(
                                  '/chat/$chatId${(conversationType == 'shop' && isSale) ? "?asBoutique=true" : ""}');
                            } catch (e) {
                              Get.back();
                              AppToasts.error(context, 'Erreur',
                                  'Impossible de démarrer le chat : $e');
                            }
                          },
                          r: r,
                        ),
                        SizedBox(width: r.s(8)),
                        _IconButton(
                          icon: Icons.call_outlined,
                          onTap: () async {
                            final String phoneNumber = order?.phone ??
                                order?.user?.telephone ??
                                order?.seller?.telephone ??
                                orderData['phone'] ??
                                '';
                            if (phoneNumber.isNotEmpty) {
                              final Uri telUri = Uri.parse('tel:$phoneNumber');
                              if (await canLaunchUrl(telUri)) {
                                await launchUrl(telUri,
                                    mode: LaunchMode.externalApplication);
                              } else {
                                AppToasts.error(context, 'Erreur',
                                    'Impossible de lancer l\'appel.');
                              }
                            } else {
                              AppToasts.error(context, 'Erreur',
                                  'Aucun numéro de téléphone disponible.');
                            }
                          },
                          r: r,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: r.s(24)),

              // ── Delivery Info ────────────────────────────────────────────────
              Text(
                'Mode de réception',
                style: TextStyle(
                  fontSize: r.fs(15),
                  fontWeight: FontWeight.w800,
                  color: AppTheme.foreground,
                ),
              ),
              SizedBox(height: r.s(12)),
              Container(
                padding: EdgeInsets.all(r.s(16)),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(r.rad(20)),
                  boxShadow: AppTheme.shadowSm,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(r.s(10)),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(r.rad(12)),
                      ),
                      child: Icon(
                        Icons.local_shipping_outlined,
                        color: AppTheme.primary,
                        size: r.s(20),
                      ),
                    ),
                    SizedBox(width: r.s(16)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order?.deliveryMethod ??
                                orderData['deliveryMethod'] ??
                                'Livraison à domicile',
                            style: TextStyle(
                              fontSize: r.fs(14),
                              fontWeight: FontWeight.w700,
                              color: AppTheme.foreground,
                            ),
                          ),
                          Text(
                            order?.deliveryAddress ??
                                orderData['deliveryAddress'] ??
                                'Lomé, Quartier Tokoin, Villa 452',
                            style: TextStyle(
                              fontSize: r.fs(12),
                              color: AppTheme.mutedForeground,
                            ),
                          ),
                          if (order != null &&
                              ((!isSale && order.deliveryMethod == 'retrait') ||
                                  (isSale &&
                                      order.deliveryMethod == 'livraison')))
                            Padding(
                              padding: EdgeInsets.only(top: r.s(8)),
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  String locationQuery = '';
                                  if (!isSale &&
                                      order!.deliveryMethod == 'retrait') {
                                    if (order!.product?.boutiqueLat != null &&
                                        order!.product?.boutiqueLon != null &&
                                        order!.product!.boutiqueLat != 0) {
                                      locationQuery =
                                          '${order!.product!.boutiqueLat},${order!.product!.boutiqueLon}';
                                    } else if (order!.product?.boutiqueAdresse !=
                                            null ||
                                        order!.product?.boutiqueDetailsAdresse !=
                                            null) {
                                      locationQuery = [
                                        order!.product?.boutiqueDetailsAdresse,
                                        order!.product?.boutiqueAdresse
                                      ]
                                          .where(
                                              (s) => s != null && s.isNotEmpty)
                                          .join(', ');
                                    }
                                  } else if (isSale &&
                                      order!.deliveryMethod == 'livraison') {
                                    if (order!.deliveryLat != null &&
                                        order!.deliveryLon != null &&
                                        order!.deliveryLat != 0) {
                                      locationQuery =
                                          '${order!.deliveryLat},${order!.deliveryLon}';
                                    } else if (order!.deliveryAddress != null &&
                                        order!.deliveryAddress!.isNotEmpty) {
                                      locationQuery = order!.deliveryAddress!;
                                    }
                                  }

                                  if (locationQuery.isNotEmpty) {
                                    final uri = Uri.parse(
                                        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(locationQuery)}');
                                    try {
                                      await launchUrl(uri,
                                          mode: LaunchMode.externalApplication);
                                    } catch (e) {
                                      AppToasts.error(context, 'Erreur',
                                          'Impossible d\'ouvrir Google Maps.');
                                    }
                                  } else {
                                    AppToasts.info(context, 'Information',
                                        'La localisation n\'est pas disponible.');
                                  }
                                },
                                icon: Icon(Icons.location_on_outlined,
                                    size: r.s(16)),
                                label: Text('Voir sur la carte',
                                    style: TextStyle(fontSize: r.fs(12))),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primary,
                                  side: BorderSide(
                                      color: AppTheme.primary.withOpacity(0.5)),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: r.s(12), vertical: 0),
                                  minimumSize: Size(0, r.s(32)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(r.rad(8)),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: r.s(32)),

              // ── Payment Summary ──────────────────────────────────────────────
              Container(
                padding: EdgeInsets.all(r.s(20)),
                decoration: BoxDecoration(
                  color: AppTheme.foreground.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(r.rad(24)),
                  border: Border.all(color: AppTheme.border.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    _PriceRow(label: 'Sous-total', value: price, r: r),
                    SizedBox(height: r.s(12)),
                    _PriceRow(
                        label: 'Frais de livraison', value: '1 500 F', r: r),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: r.s(16)),
                      child: Divider(height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: r.fs(16),
                            fontWeight: FontWeight.w800,
                            color: AppTheme.foreground,
                          ),
                        ),
                        Text(
                          price,
                          style: TextStyle(
                            fontSize: r.fs(20),
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: r.s(40)),

              // ── Actions ──────────────────────────────────────────────────────
              if (order != null) ...[
                if (isSale) ...[
                  if (status == 'En attente')
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => ctrl.refuseOrder(context, order!),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppTheme.destructive.withOpacity(0.1),
                              foregroundColor: AppTheme.destructive,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: r.s(16)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(r.rad(16)),
                              ),
                            ),
                            child: Text('Refuser',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: r.fs(14))),
                          ),
                        ),
                        SizedBox(width: r.s(16)),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => ctrl.acceptOrder(context, order!),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: r.s(16)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(r.rad(16)),
                              ),
                            ),
                            child: Text(
                              'Accepter',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: r.fs(14)),
                            ),
                          ),
                        ),
                      ],
                    )
                  else if (status == 'Acceptée' || status == 'Confirmé')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => ctrl.completeOrder(context, order!),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: r.s(16)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(r.rad(16)),
                          ),
                        ),
                        child: Text('Terminer (Livré)',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: r.fs(14))),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: r.s(16)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(r.rad(16)),
                          ),
                        ),
                        child: Text('Besoin d\'aide ?',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: r.fs(14))),
                      ),
                    ),
                ] else ...[
                  // Buyer actions
                  if (status == 'En attente')
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppTheme.destructive.withOpacity(0.1),
                              foregroundColor: AppTheme.destructive,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: r.s(16)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(r.rad(16)),
                              ),
                            ),
                            child: Text('Annuler',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: r.fs(14))),
                          ),
                        ),
                        SizedBox(width: r.s(16)),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: r.s(16)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(r.rad(16)),
                              ),
                            ),
                            child: Text(
                              'Modifier',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: r.fs(14)),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: r.s(16)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(r.rad(16)),
                          ),
                        ),
                        child: Text('Besoin d\'aide ?',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: r.fs(14))),
                      ),
                    ),
                ]
              ] else ...[
                // Fallback action if order is null
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: r.s(16)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(r.rad(16)),
                      ),
                    ),
                    child: Text('Besoin d\'aide ?',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: r.fs(14))),
                  ),
                ),
              ],

              SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
            ],
          ),
        );
      }),
    );
  }
}

// ── Image Placeholder ───────────────────────────────────────────────────────
class _ImagePlaceholder extends StatelessWidget {
  final double size;
  const _ImagePlaceholder({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.muted,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(Icons.image_not_supported_outlined,
          color: AppTheme.mutedForeground, size: size * 0.4),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final R r;

  const _IconButton({required this.icon, required this.onTap, required this.r});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(r.s(10)),
        decoration: BoxDecoration(
          color: AppTheme.background,
          border: Border.all(color: AppTheme.border),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: r.s(18), color: AppTheme.primary),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final R r;

  const _PriceRow({required this.label, required this.value, required this.r});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: r.fs(14),
            color: AppTheme.mutedForeground,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: r.fs(14),
            fontWeight: FontWeight.w700,
            color: AppTheme.foreground,
          ),
        ),
      ],
    );
  }
}
