import 'package:get/get.dart';
import '../model/category_model.dart';
import '../core/api_client.dart';
import '../config/api_constants.dart';

class CategoryService extends GetxService {
  final ApiClient _apiClient;

  CategoryService(this._apiClient);

  static CategoryService get to => Get.find();

  /// Retrieve all available categories from backend
  Future<List<Category>> getCategories() async {
    final response = await _apiClient.get(ApiConstants.categoriesEndpoint);
    // The API may return a bare array [] OR a wrapped {"data": [...]} object.
    // We check the type to avoid a cast exception on a bare list.
    final dynamic raw = response.data;
    final List<dynamic> rawData = (raw is List) ? raw : (raw['data'] ?? []);
    return rawData.map((json) => Category.fromJson(json)).toList();
  }
}
