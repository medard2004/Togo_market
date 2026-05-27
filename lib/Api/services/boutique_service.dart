import 'dart:io';
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

  /// Retrieve all boutiques (public listing)
  Future<List<Boutique>> getBoutiques() async {
    try {
      final response = await _apiClient.get(ApiConstants.boutiquesEndpoint);
      if (response.statusCode == 200) {
        final data = response.data;
        final List list = data is List ? data : (data['data'] ?? []);
        return list.map((json) => Boutique.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get nearby boutiques based on user location and preferences
  Future<List<Boutique>> getNearbyBoutiques(
      {String? zone, double? lat, double? lng}) async {
    try {
      final params = <String, dynamic>{};
      if (zone != null && zone.isNotEmpty) params['zone'] = zone;
      if (lat != null) params['lat'] = lat;
      if (lng != null) params['lng'] = lng;

      final response = await _apiClient.get(
        ApiConstants.nearbyBoutiquesEndpoint,
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List list = data is List ? data : (data['data'] ?? []);
        return list.map((json) => Boutique.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<FormData> _buildFormData(Map<String, dynamic> payload,
      {bool isUpdate = false}) async {
    final Map<String, dynamic> formDataMap = {};
    if (isUpdate) {
      formDataMap['_method'] = 'PUT';
    }

    for (var entry in payload.entries) {
      if (entry.key == 'logoPath' || entry.key == 'bannerPath') {
        if (entry.value != null && (entry.value as String).isNotEmpty) {
          final file = File(entry.value as String);
          if (await file.exists()) {
            final fileKey = entry.key == 'logoPath' ? 'logo' : 'banner';
            formDataMap[fileKey] = await MultipartFile.fromFile(file.path);
          }
        }
      } else if (entry.value is List) {
        final list = entry.value as List;
        for (int i = 0; i < list.length; i++) {
          formDataMap['${entry.key}[$i]'] = list[i].toString();
        }
      } else if (entry.value is Map) {
        // Encode nested Maps (e.g. horaires) as individual keys for multipart
        _flattenMap(entry.key, entry.value as Map, formDataMap);
      } else {
        formDataMap[entry.key] = entry.value;
      }
    }
    return FormData.fromMap(formDataMap);
  }

  /// Recursively flatten a nested map for FormData (e.g. horaires[jours][0] = 'Lun')
  void _flattenMap(String prefix, Map map, Map<String, dynamic> output) {
    for (var key in map.keys) {
      final value = map[key];
      final fullKey = '$prefix[$key]';
      if (value is Map) {
        _flattenMap(fullKey, value, output);
      } else if (value is List) {
        for (int i = 0; i < value.length; i++) {
          output['$fullKey[$i]'] = value[i].toString();
        }
      } else {
        output[fullKey] = value?.toString() ?? '';
      }
    }
  }

  /// Create a new boutique
  Future<Boutique> store(Map<String, dynamic> payload) async {
    final bool hasFiles =
        payload.containsKey('logoPath') || payload.containsKey('bannerPath');
    final data = hasFiles ? await _buildFormData(payload) : payload;

    final response =
        await _apiClient.post(ApiConstants.boutiqueEndpoint, data: data);
    return Boutique.fromJson(
        response.data['boutique'] ?? response.data['data'] ?? response.data);
  }

  /// Update an existing boutique
  Future<Boutique> update(Map<String, dynamic> payload) async {
    final bool hasFiles =
        payload.containsKey('logoPath') || payload.containsKey('bannerPath');

    if (hasFiles) {
      final data = await _buildFormData(payload, isUpdate: true);
      final response = await _apiClient.post(
        ApiConstants.boutiqueEndpoint,
        data: data,
      );
      return Boutique.fromJson(
          response.data['boutique'] ?? response.data['data'] ?? response.data);
    } else {
      final response = await _apiClient.put(
        ApiConstants.boutiqueEndpoint,
        data: payload,
      );
      return Boutique.fromJson(
          response.data['boutique'] ?? response.data['data'] ?? response.data);
    }
  }

  /// Validate a specific step data
  Future<bool> validateStep(int step, Map<String, dynamic> data) async {
    data['step'] = step;
    await _apiClient.post('${ApiConstants.boutiqueEndpoint}/validate-step',
        data: data);
    return true; // If no exception thrown, validation passed
  }
}
