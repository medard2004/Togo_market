import 'package:get/get.dart';
import '../Api/services/user_service.dart';
import '../Api/services/produit_service.dart';
import '../Api/model/user_model.dart';
import '../Api/model/product_model.dart';

class PublicProfileController extends GetxController {
  final String userId;
  final UserService _userService = Get.find<UserService>();
  final ProduitService _produitService = Get.find<ProduitService>();

  PublicProfileController(this.userId);

  var isLoading = true.obs;
  var user = Rxn<User>();
  var products = <Product>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      isLoading(true);
      final fetchedUser = await _userService.getUserProfile(userId);
      final fetchedProducts = await _produitService.getUserProducts(userId);
      
      user.value = fetchedUser;
      products.assignAll(fetchedProducts);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger le profil : $e');
    } finally {
      isLoading(false);
    }
  }
}
