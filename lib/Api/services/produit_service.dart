import 'package:get/get.dart';
import '../model/product_model.dart';
import '../model/trending_products_page.dart';
import '../core/api_client.dart';
import '../config/api_constants.dart';

class ProduitService extends GetxService {
  final ApiClient _apiClient;

  ProduitService(this._apiClient);

  static ProduitService get to => Get.find();

  /// Parse a response that may be paginated {"data":[...]} or a bare array []
  List<dynamic> _parseList(dynamic rawData) {
    if (rawData is List) return rawData;
    if (rawData is Map && rawData.containsKey('data') && rawData['data'] is List) {
      return rawData['data'] as List;
    }
    return [];
  }

  /// Get public list of products (paginated or not)
  Future<List<Product>> getPublicProducts() async {
    final response = await _apiClient.get(ApiConstants.productsEndpoint);
    final list = _parseList(response.data);
    return list.map((json) => Product.fromJson(json)).toList();
  }

  /// Get products belonging to the authenticated user's boutique
  Future<List<Product>> getMyBoutiqueProducts(String boutiqueId) async {
    final response = await _apiClient.get(
      '/boutiques/$boutiqueId/produits',
    );
    final list = _parseList(response.data);
    return list.map((json) => Product.fromJson(json)).toList();
  }

  /// Create a new product for the store
  Future<Product> addStoreProduct(dynamic formData) async {
    final response = await _apiClient.post(ApiConstants.productsEndpoint, data: formData);
    final raw = response.data;
    return Product.fromJson(raw is Map && raw.containsKey('data') ? raw['data'] : raw);
  }

  /// Update an existing product
  Future<Product> updateProduct(String id, dynamic formData) async {
    final response = await _apiClient.post('${ApiConstants.productsEndpoint}/$id', data: formData);
    final raw = response.data;
    return Product.fromJson(raw is Map && raw.containsKey('data') ? raw['data'] : raw);
  }

  /// Aperçu tendances (10 premiers) pour la page d'accueil.
  Future<List<Product>> getTrendingProducts() async {
    final response = await _apiClient.get(ApiConstants.trendingProductsEndpoint);
    final list = _parseList(response.data);
    return list.map((json) => Product.fromJson(json)).toList();
  }

  /// Tendances paginées (écran « Voir tout »), même ordre que l'aperçu.
  Future<TrendingProductsPage> getTrendingProductsPage({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.trendingProductsPaginatedEndpoint,
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
    );
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      return TrendingProductsPage(items: [], currentPage: 1, lastPage: 1);
    }
    return TrendingProductsPage.fromJson(data);
  }

  /// Get products by zone (text match on localisation)
  Future<List<Product>> getProductsByZone(String zone) async {
    final response = await _apiClient.get(
      ApiConstants.productsByZoneEndpoint,
      queryParameters: {'zone': zone},
    );
    final list = _parseList(response.data);
    return list.map((json) => Product.fromJson(json)).toList();
  }

  /// Delete a product
  Future<void> deleteProduct(String id) async {
    await _apiClient.dio.delete('${ApiConstants.productsEndpoint}/$id');
  }
}
