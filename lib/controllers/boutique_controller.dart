import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../models/models.dart';
import '../../Api/services/boutique_service.dart';

class BoutiqueController extends GetxController {
  final BoutiqueService _boutiqueService;

  BoutiqueController(this._boutiqueService);

  static BoutiqueController get to => Get.find();

  // State
  final Rx<Boutique?> myBoutique = Rx<Boutique?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initially check boutique status when initialized if logged in
    // checkMyBoutique();
  }

  /// Checks if the user has a boutique
  Future<void> checkMyBoutique() async {
    isLoading.value = true;
    try {
      final boutique = await _boutiqueService.getMe();
      myBoutique.value = boutique;
    } catch (e) {
      myBoutique.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Create a boutique and update state
  Future<dynamic> createBoutique(Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      final boutique = await _boutiqueService.store(data);
      myBoutique.value = boutique;
      return true;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 422) {
        return e.response?.data['errors'];
      }
      Get.snackbar('Erreur', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update boutique
  Future<dynamic> updateBoutique(Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      final boutique = await _boutiqueService.update(data);
      myBoutique.value = boutique;
      return true;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 422) {
        return e.response?.data['errors'];
      }
      Get.snackbar('Erreur', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
