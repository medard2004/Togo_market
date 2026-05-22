import 'package:get/get.dart';
import '../Api/model/product_model.dart';
import '../Api/services/produit_service.dart';
import '../utils/app_toasts.dart';
import '../Api/provider/auth_controller.dart';

class MyProductsController extends GetxController {
  final isLoading = false.obs;
  final myProducts = <Product>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Only load if the user is authenticated, to avoid 401 errors for guests
    if (Get.find<AuthController>().currentUser.value != null) {
      loadMyProducts();
    }
  }

  Future<void> loadMyProducts() async {
    if (Get.find<AuthController>().currentUser.value == null) return;
    isLoading.value = true;
    try {
      final products = await ProduitService.to.getMyPersonalProducts();
      myProducts.assignAll(products);
    } catch (e) {
      if (Get.context != null) {
        AppToasts.error(Get.context!, 'Erreur', 'Impossible de charger vos annonces personnelles.');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await ProduitService.to.deleteProduct(id);
      myProducts.removeWhere((p) => p.id.toString() == id);
      if (Get.context != null) {
        AppToasts.success(Get.context!, 'Succès', 'Annonce supprimée avec succès.');
      }
    } catch (e) {
      if (Get.context != null) {
        AppToasts.error(Get.context!, 'Erreur', 'Impossible de supprimer cette annonce.');
      }
    }
  }
}
