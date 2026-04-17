import 'package:dio/dio.dart';
import '../model/boutique_model.dart';
import '../core/api_client.dart';
import '../config/api_constants.dart';
import 'package:get/get.dart' hide FormData, MultipartFile, Response;

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
    } on NotFoundException catch (_) {
      return null; // No boutique configured
    }
  }

  Future<FormData> _buildFormData(Map<String, dynamic> payload, {bool isUpdate = false}) async {
    final Map<String, dynamic> formDataMap = {};
    if (isUpdate) {
      formDataMap['_method'] = 'PUT';
    }

    for (var entry in payload.entries) {
      if (entry.key == 'logoPath' || entry.key == 'bannerPath') {
        if (entry.value != null && (entry.value as String).isNotEmpty) {
          final fileKey = entry.key == 'logoPath' ? 'logo' : 'banner';
          formDataMap[fileKey] = await MultipartFile.fromFile(entry.value as String);
        }
      } else if (entry.value is List) {
        final list = entry.value as List;
        for (int i = 0; i < list.length; i++) {
          formDataMap['${entry.key}[$i]'] = list[i];
        }
      } else {
        formDataMap[entry.key] = entry.value;
      }
    }
    return FormData.fromMap(formDataMap);
  }

  /// Create a new boutique
  Future<Boutique> store(Map<String, dynamic> payload) async {
    final bool hasFiles = payload.containsKey('logoPath') || payload.containsKey('bannerPath');
    final data = hasFiles ? await _buildFormData(payload) : payload;

    final response = await _apiClient.post(ApiConstants.boutiqueEndpoint, data: data);
    return Boutique.fromJson(response.data['boutique'] ?? response.data['data'] ?? response.data);
  }

  /// Update an existing boutique
  Future<Boutique> update(Map<String, dynamic> payload) async {
    final bool hasFiles = payload.containsKey('logoPath') || payload.containsKey('bannerPath');
    
    if (hasFiles) {
      final data = await _buildFormData(payload, isUpdate: true);
      final response = await _apiClient.post(
        ApiConstants.boutiqueEndpoint,
        data: data,
      );
      return Boutique.fromJson(response.data['boutique'] ?? response.data['data'] ?? response.data);
    } else {
      final response = await _apiClient.put(
        ApiConstants.boutiqueEndpoint,
        data: payload,
      );
      return Boutique.fromJson(response.data['boutique'] ?? response.data['data'] ?? response.data);
    }
  }
}
