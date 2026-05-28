// lib/controllers/order_controller.dart
// Gestion globale de l'état des commandes (GetX).

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/order_model.dart';
import '../Api/services/order_service.dart';
import '../Api/core/api_client.dart';
import '../Api/provider/auth_controller.dart';
import '../utils/app_toasts.dart';
import 'app_controller.dart';
import '../Api/firebase/services/chat_service.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class OrderController extends GetxController {
  static OrderController get to => Get.find();

  // ── Observable state ────────────────────────────────────────────────────────
  final buyerOrders  = <OrderModel>[].obs; // commandes passées (acheteur)
  final sellerOrders = <OrderModel>[].obs; // commandes reçues  (vendeur)
  final isLoading    = false.obs;
  final hasError     = false.obs;

  late final OrderService _service;

  @override
  void onInit() {
    super.onInit();
    _service = OrderService(Get.find<ApiClient>());

    // Ne charger que si l'utilisateur est connecté
    if (_isAuthenticated) {
      fetchOrders();
    }

    // Réagir au login / logout
    if (Get.isRegistered<AuthController>()) {
      ever(Get.find<AuthController>().currentUser, (user) {
        if (user != null) {
          fetchOrders();
        } else {
          buyerOrders.clear();
          sellerOrders.clear();
        }
      });
    }
  }

  bool get _isAuthenticated {
    if (!Get.isRegistered<AuthController>()) return false;
    return Get.find<AuthController>().isAuthenticated;
  }

  // ── Fetch ────────────────────────────────────────────────────────────────────

  Future<void> fetchOrders() async {
    if (!_isAuthenticated) return;

    isLoading.value = true;
    hasError.value  = false;
    try {
      final data = await _service.getOrders();
      final buyerList  = (data['as_buyer']  as List? ?? [])
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final sellerList = (data['as_seller'] as List? ?? [])
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
      buyerOrders.assignAll(buyerList);
      sellerOrders.assignAll(sellerList);
    } catch (e) {
      hasError.value = true;
      debugPrint('OrderController.fetchOrders error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Actions vendeur ──────────────────────────────────────────────────────────

  Future<void> acceptOrder(BuildContext context, OrderModel order) async {
    await _updateStatus(context, order, 'Acceptée');
  }

  Future<void> refuseOrder(BuildContext context, OrderModel order) async {
    await _updateStatus(context, order, 'Refusée');
  }

  Future<void> completeOrder(BuildContext context, OrderModel order) async {
    await _updateStatus(context, order, 'Terminée');
  }

  Future<void> approveCancellation(BuildContext context, OrderModel order) async {
    await _updateStatus(context, order, 'Annulé');
    await _sendSystemMessage(order, "Le vendeur a accepté l'annulation de la commande.");
  }

  Future<void> rejectCancellation(BuildContext context, OrderModel order) async {
    await _updateStatus(context, order, 'Acceptée');
    await _sendSystemMessage(order, "Le vendeur a refusé l'annulation de la commande.");
  }

  Future<void> _updateStatus(
      BuildContext context, OrderModel order, String newStatus) async {
    final previousStatus = order.status;
    // Optimistic update
    order.status = newStatus;
    sellerOrders.refresh();
    buyerOrders.refresh();

    try {
      await _service.updateOrderStatus(order.id, newStatus);
      AppToasts.success(context, 'Commande mise à jour', 'Statut : $newStatus');
      await _updateRecapInChat(order);
      if (Get.isRegistered<AppController>()) {
        Get.find<AppController>().fetchProduits();
      }
    } catch (e) {
      // Rollback
      order.status = previousStatus;
      sellerOrders.refresh();
      buyerOrders.refresh();
      AppToasts.error(context, 'Erreur', 'Impossible de mettre à jour le statut.');
      debugPrint('OrderController._updateStatus error: $e');
    }
  }

  // ── Actions acheteur ────────────────────────────────────────────────────────

  Future<void> cancelBuyerOrder(BuildContext context, OrderModel order) async {
    final previousStatus = order.status;
    order.status = 'Annulé';
    buyerOrders.refresh();

    try {
      await _service.cancelOrder(order.id);
      AppToasts.success(context, 'Commande annulée', 'Votre commande a été annulée.');
      await _sendSystemMessage(order, "L'acheteur a annulé la commande.");
      await _updateRecapInChat(order);
    } catch (e) {
      order.status = previousStatus;
      buyerOrders.refresh();
      AppToasts.error(context, 'Erreur', 'Impossible d\'annuler la commande.');
      debugPrint('OrderController.cancelBuyerOrder error: $e');
    }
  }

  Future<void> updateBuyerOrder(BuildContext context, OrderModel order, Map<String, dynamic> data) async {
    try {
      final response = await _service.updateOrder(order.id, data);
      if (response['success'] == true && response['order'] != null) {
        final updatedOrder = OrderModel.fromJson(response['order']);
        final index = buyerOrders.indexWhere((o) => o.id == order.id);
        if (index != -1) {
          buyerOrders[index] = updatedOrder;
        }
        AppToasts.success(context, 'Mise à jour réussie', 'Votre commande a été modifiée.');
        await _sendOrderRecapMessage(updatedOrder, isModification: true);
      }
    } catch (e) {
      AppToasts.error(context, 'Erreur', 'Impossible de modifier la commande.');
      debugPrint('OrderController.updateBuyerOrder error: $e');
    }
  }

  Future<void> requestRefund(BuildContext context, OrderModel order, dynamic formData) async {
    try {
      final response = await _service.requestRefund(order.id, formData);
      if (response['success'] == true && response['refund'] != null) {
        // On recharge les commandes pour mettre à jour l'UI avec le refund
        await fetchOrders();
        AppToasts.success(context, 'Demande envoyée', 'Votre demande de remboursement a été envoyée.');
        await _sendSystemMessage(order, "L'acheteur a demandé un remboursement.");
      }
    } catch (e) {
      AppToasts.error(context, 'Erreur', 'Impossible d\'envoyer la demande.');
      debugPrint('OrderController.requestRefund error: $e');
      rethrow;
    }
  }

  Future<void> requestCancellation(BuildContext context, OrderModel order) async {
    final previousStatus = order.status;
    order.status = 'Annulation demandée';
    buyerOrders.refresh();

    try {
      await _service.updateOrderStatus(order.id, 'Annulation demandée');
      AppToasts.success(context, 'Demande envoyée', 'Votre demande d\'annulation a été envoyée au vendeur.');
      await _sendSystemMessage(order, "L'acheteur a demandé l'annulation de la commande.");
      await _updateRecapInChat(order);
    } catch (e) {
      order.status = previousStatus;
      buyerOrders.refresh();
      AppToasts.error(context, 'Erreur', 'Impossible de demander l\'annulation.');
      debugPrint('OrderController.requestCancellation error: $e');
    }
  }

  Future<void> _sendSystemMessage(OrderModel order, String content) async {
    try {
      if (!Get.isRegistered<ChatService>()) return;
      final chatService = Get.find<ChatService>();

      final buyer = order.user;
      final seller = order.seller;
      final product = order.product;
      if (buyer == null || seller == null || product == null) return;

      final isSellerShop = product.boutiqueId != null;
      final actualSellerEntityId = isSellerShop ? product.boutiqueId.toString() : seller.id.toString();

      final chatId = await chatService.getOrCreateChat(
        conversationType: isSellerShop ? 'shop' : 'personal',
        myEntityId: buyer.id.toString(),
        myEntityType: 'user',
        myName: buyer.nom,
        myAvatar: buyer.avatar ?? '',
        otherEntityId: actualSellerEntityId,
        otherEntityType: isSellerShop ? 'shop' : 'user',
        otherName: isSellerShop ? (product.boutiqueNom ?? seller.nom) : seller.nom,
        otherAvatar: isSellerShop ? (product.boutiqueLogo ?? seller.avatar ?? '') : (seller.avatar ?? ''),
        productId: product.id.toString(),
        productTitle: product.titre,
        productImage: product.image,
        relatedShopId: product.boutiqueId?.toString(),
      );

      await chatService.sendMessage(
        chatId,
        buyer.id.toString(),
        'user',
        actualSellerEntityId,
        isSellerShop ? 'shop' : 'user',
        content,
        productId: product.id.toString(),
        type: 'system',
      );
    } catch (e) {
      debugPrint('OrderController._sendSystemMessage error: $e');
    }
  }

  /// Envoie un message de type 'order' avec le récapitulatif formaté
  Future<void> _sendOrderRecapMessage(OrderModel order, {bool isModification = false}) async {
    try {
      if (!Get.isRegistered<ChatService>()) return;
      final chatService = Get.find<ChatService>();

      final buyer = order.user;
      final seller = order.seller;
      final product = order.product;
      if (buyer == null || seller == null || product == null) return;

      final isSellerShop = product.boutiqueId != null;
      final actualSellerEntityId = isSellerShop ? product.boutiqueId.toString() : seller.id.toString();

      final chatId = await chatService.getOrCreateChat(
        conversationType: isSellerShop ? 'shop' : 'personal',
        myEntityId: buyer.id.toString(),
        myEntityType: 'user',
        myName: buyer.nom,
        myAvatar: buyer.avatar ?? '',
        otherEntityId: actualSellerEntityId,
        otherEntityType: isSellerShop ? 'shop' : 'user',
        otherName: isSellerShop ? (product.boutiqueNom ?? seller.nom) : seller.nom,
        otherAvatar: isSellerShop ? (product.boutiqueLogo ?? seller.avatar ?? '') : (seller.avatar ?? ''),
        productId: product.id.toString(),
        productTitle: product.titre,
        productImage: product.image,
        relatedShopId: product.boutiqueId?.toString(),
      );

      final DateFormat formatter = DateFormat('dd MMM yyyy, HH:mm', 'fr');
      final dateStr = formatter.format(order.createdAt);

      final Map<String, String> basePayload = {
        'order_id': order.id.toString(),
        'date': dateStr,
        'product_title': product.titre,
        'product_image': product.image ?? '',
        'quantity': order.quantity.toString(),
        'total': '${order.totalPrice.toStringAsFixed(0)} FCFA',
        'mode': order.deliveryMethod ?? '',
        'address': order.deliveryAddress ?? '',
        'payment': order.paymentMethod ?? '',
        'phone': order.phone ?? '',
        'note': order.notes ?? '',
        'status': order.status,
      };

      // Si c'est une modification, on met d'abord à jour les anciens messages de cette commande
      // avec les nouvelles données de base (sans l'indicateur is_modified pour ne pas les transformer visuellement)
      if (isModification) {
        await chatService.updateOrderRecapMessages(
          chatId,
          order.id.toString(),
          basePayload,
        );
      }

      final Map<String, String> newPayload = Map.from(basePayload);
      if (isModification) {
        newPayload['is_modified'] = 'true';
      }

      await chatService.sendMessage(
        chatId,
        buyer.id.toString(),
        'user',
        actualSellerEntityId,
        isSellerShop ? 'shop' : 'user',
        jsonEncode(newPayload),
        productId: product.id.toString(),
        type: 'order',
      );
    } catch (e) {
      debugPrint('OrderController._sendOrderRecapMessage error: $e');
    }
  }

  /// Met à jour uniquement le contenu des anciens récapitulatifs dans la discussion (sans en envoyer de nouveau)
  Future<void> _updateRecapInChat(OrderModel order) async {
    try {
      if (!Get.isRegistered<ChatService>()) return;
      final chatService = Get.find<ChatService>();

      final buyer = order.user;
      final seller = order.seller;
      final product = order.product;
      if (buyer == null || seller == null || product == null) return;

      final isSellerShop = product.boutiqueId != null;
      final actualSellerEntityId = isSellerShop ? product.boutiqueId.toString() : seller.id.toString();

      final chatId = await chatService.getOrCreateChat(
        conversationType: isSellerShop ? 'shop' : 'personal',
        myEntityId: buyer.id.toString(),
        myEntityType: 'user',
        myName: buyer.nom,
        myAvatar: buyer.avatar ?? '',
        otherEntityId: actualSellerEntityId,
        otherEntityType: isSellerShop ? 'shop' : 'user',
        otherName: isSellerShop ? (product.boutiqueNom ?? seller.nom) : seller.nom,
        otherAvatar: isSellerShop ? (product.boutiqueLogo ?? seller.avatar ?? '') : (seller.avatar ?? ''),
        productId: product.id.toString(),
        productTitle: product.titre,
        productImage: product.image,
        relatedShopId: product.boutiqueId?.toString(),
      );

      final DateFormat formatter = DateFormat('dd MMM yyyy, HH:mm', 'fr');
      final dateStr = formatter.format(order.createdAt);

      final Map<String, String> basePayload = {
        'order_id': order.id.toString(),
        'date': dateStr,
        'product_title': product.titre,
        'product_image': product.image ?? '',
        'quantity': order.quantity.toString(),
        'total': '${order.totalPrice.toStringAsFixed(0)} FCFA',
        'mode': order.deliveryMethod ?? '',
        'address': order.deliveryAddress ?? '',
        'payment': order.paymentMethod ?? '',
        'phone': order.phone ?? '',
        'note': order.notes ?? '',
        'status': order.status,
      };

      await chatService.updateOrderRecapMessages(
        chatId,
        order.id.toString(),
        basePayload,
      );
    } catch (e) {
      debugPrint('OrderController._updateRecapInChat error: $e');
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  /// Nombre de commandes vendeur en attente (badge).
  int get pendingSellerCount =>
      sellerOrders.where((o) => o.status == 'En attente' || o.status == 'Annulation demandée').length;
}
