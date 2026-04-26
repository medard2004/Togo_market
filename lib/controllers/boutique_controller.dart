import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../Api/model/boutique_model.dart';
import '../Api/services/boutique_service.dart';
import '../Api/provider/auth_controller.dart';

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
    if (Get.isRegistered<AuthController>()) {
      ever(Get.find<AuthController>().currentUser, (user) {
        if (user == null) {
          myBoutique.value = null;
        }
      });
    }
  }

  /// Checks if the user has a boutique
  Future<bool> checkMyBoutique() async {
    isLoading.value = true;
    try {
      final boutique = await _boutiqueService.getMe();
      myBoutique.value = boutique;
      return true;
    } catch (e) {
      Get.snackbar('Erreur de connexion', 'Veuillez vérifier votre réseau.');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Recharge la boutique sans indicateur global (ex. avant le picker catégories produit).
  Future<void> silentRefreshMyBoutique() async {
    try {
      final boutique = await _boutiqueService.getMe();
      myBoutique.value = boutique;
    } catch (_) {}
  }

  Future<void> goToMyBoutique() async {
    if (myBoutique.value != null) {
      Get.toNamed('/dashboard');
      return;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    bool checked = await checkMyBoutique();

    if (Get.isDialogOpen == true) {
      Get.back(); // close dialog
    }

    if (!checked) return;

    if (myBoutique.value != null) {
      Get.toNamed('/dashboard');
    } else {
      Get.toNamed('/store-settings');
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

  /// Validate a step
  Future<dynamic> validateStep(int step, Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      await _boutiqueService.validateStep(step, data);
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
