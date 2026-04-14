import 'package:dio/dio.dart';
import '../../models/models.dart';
import '../core/api_client.dart';
import '../config/api_constants.dart';
import 'package:get/get.dart';

class BoutiqueService extends GetxService {
  final ApiClient _apiClient;

  BoutiqueService(this._apiClient);

  static BoutiqueService get to => Get.find();

  /// Retrieve the current user's boutique info
  Future<Boutique?> getMe() async {
    try {
      final response = await _apiClient.get(ApiConstants.boutiqueMeEndpoint);
      if (response.statusCode == 200) {
        return Boutique.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null; // No boutique configured
      }
      rethrow;
    }
  }

  /// Create a new boutique
  Future<Boutique> store(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(ApiConstants.boutiqueEndpoint, data: payload);
    return Boutique.fromJson(response.data['boutique'] ?? response.data['data'] ?? response.data);
  }

  /// Update an existing boutique
  Future<Boutique> update(Map<String, dynamic> payload) async {
    final response = await _apiClient.put(
      ApiConstants.boutiqueEndpoint,
      data: payload,
    );
    return Boutique.fromJson(response.data['boutique'] ?? response.data['data'] ?? response.data);
  }
}
