import 'base_service.dart';

class OrderService extends BaseService {
  OrderService(super.apiClient);

  /// Créer une nouvelle commande
  Future<Map<String, dynamic>> createOrder({
    required int productId,
    required int quantity,
    String? paymentMethod,
    String? deliveryMethod,
    String? deliveryAddress,
    double? deliveryLat,
    double? deliveryLon,
    String? phone,
    String? notes,
  }) async {
    final response = await apiClient.post(
      '/orders',
      data: {
        'product_id': productId,
        'quantity': quantity,
        'payment_method': paymentMethod,
        'delivery_method': deliveryMethod,
        'delivery_address': deliveryAddress,
        'delivery_lat': deliveryLat,
        'delivery_lon': deliveryLon,
        'phone': phone,
        'notes': notes,
      },
    );
    return response.data;
  }

  /// Récupérer les commandes (en tant qu'acheteur et vendeur)
  /// Retourne { 'as_buyer': [...], 'as_seller': [...] }
  Future<Map<String, dynamic>> getOrders() async {
    final response = await apiClient.get('/orders');
    return response.data;
  }

  /// Mettre à jour le statut d'une commande (vendeur)
  /// status = 'Acceptée' | 'Refusée' | 'Terminée'
  Future<Map<String, dynamic>> updateOrderStatus(int orderId, String status) async {
    final response = await apiClient.patch(
      '/orders/$orderId/status',
      data: {'status': status},
    );
    return response.data;
  }

  /// Mettre à jour les détails d'une commande (acheteur)
  Future<Map<String, dynamic>> updateOrder(int orderId, Map<String, dynamic> data) async {
    final response = await apiClient.put(
      '/orders/$orderId',
      data: data,
    );
    return response.data;
  }

  /// Demander un remboursement
  Future<Map<String, dynamic>> requestRefund(int orderId, dynamic data) async {
    final response = await apiClient.post(
      '/orders/$orderId/refund',
      data: data,
    );
    return response.data;
  }

  /// Annuler une commande (acheteur)
  Future<Map<String, dynamic>> cancelOrder(int orderId) async {
    return updateOrderStatus(orderId, 'Annulé');
  }
}
