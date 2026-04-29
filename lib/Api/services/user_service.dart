import 'package:get/get.dart';
import '../model/user_model.dart';
import '../core/api_client.dart';

class UserService extends GetxService {
  final ApiClient _apiClient;

  UserService(this._apiClient);

  static UserService get to => Get.find();

  /// Récupérer le profil public d'un utilisateur
  Future<User> getUserProfile(String id) async {
    final response = await _apiClient.get('/users/$id');
    final raw = response.data;
    // On s'attend à { "status": "success", "data": { ...user data... } }
    final userData = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
    return User.fromJson(userData);
  }
}
