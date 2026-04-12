import 'package:dio/dio.dart';
import '../../models/models.dart';
import '../core/api_client.dart';
import '../config/api_constants.dart';
import 'package:get/get.dart';

class ProduitService extends GetxService {
  final ApiClient _apiClient;

  ProduitService(this._apiClient);

  static ProduitService get to => Get.find();

  /// Get public list of products
  Future<List<Product>> getPublicProducts() async {
    final response = await _apiClient.get(ApiConstants.productsEndpoint);
    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.map((json) => Product.fromJson(json)).toList();
  }

  /// Create a new product for the store
  Future<Product> addStoreProduct(dynamic formData) async {
    final response = await _apiClient.post(ApiConstants.productsEndpoint, data: formData);
    return Product.fromJson(response.data['data'] ?? response.data);
  }

  /// Update an existing product
  Future<Product> updateProduct(String id, dynamic formData) async {
    // If formData is FormData, we use POST with _method=PUT to fake a PUT request to Laravel
    final response = await _apiClient.post('${ApiConstants.productsEndpoint}/$id', data: formData);
    return Product.fromJson(response.data['data'] ?? response.data);
  }

  /// Delete a product
  Future<void> deleteProduct(String id) async {
    await _apiClient.dio.delete('${ApiConstants.productsEndpoint}/$id');
  }
}
