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
}
