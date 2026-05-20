// lib/controllers/order_controller.dart
// Gestion globale de l'état des commandes (GetX).

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/order_model.dart';
import '../Api/services/order_service.dart';
import '../Api/core/api_client.dart';
import '../Api/provider/auth_controller.dart';
import '../utils/app_toasts.dart';

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
    } catch (e) {
      // Rollback
      order.status = previousStatus;
      sellerOrders.refresh();
      buyerOrders.refresh();
      AppToasts.error(context, 'Erreur', 'Impossible de mettre à jour le statut.');
      debugPrint('OrderController._updateStatus error: $e');
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  /// Nombre de commandes vendeur en attente (badge).
  int get pendingSellerCount =>
      sellerOrders.where((o) => o.status == 'En attente').length;
}
