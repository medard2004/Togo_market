import 'package:get/get.dart';
import '../model/product_model.dart';
import '../core/api_client.dart';
import '../config/api_constants.dart';

class FavoriService extends GetxService {
  final ApiClient _apiClient;

  FavoriService(this._apiClient);

  static FavoriService get to => Get.find();

  /// Récupère la liste des produits favoris de l'utilisateur connecté.
  Future<List<Product>> getFavorites() async {
    final response = await _apiClient.get(ApiConstants.favoritesEndpoint);
    final data = response.data;
    final list = data is List
        ? data
        : (data is Map && data['data'] is List ? data['data'] as List : []);
    return list.map((json) => Product.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Toggle favori pour un produit. Retourne le nouveau statut (true = est favori).
  Future<bool> toggleFavorite(dynamic productId) async {
    final response = await _apiClient.post(
      ApiConstants.toggleFavoriteEndpoint(productId),
    );
    final data = response.data;
    if (data is Map && data.containsKey('is_favoris')) {
      return data['is_favoris'] as bool;
    }
    return false;
  }
}
