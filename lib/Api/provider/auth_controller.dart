import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get/get.dart';
import '../model/user_model.dart';
import '../model/category_model.dart';
import '../model/location_model.dart';
import '../services/auth_service.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthController extends GetxController {
  final AuthService _authService;
  
  AuthController(this._authService);

  // Observable state
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isFirstTime = true.obs; // For onboarding
  final RxBool hasToken = false.obs;
  
  // Public data
  final RxList<Category> categories = <Category>[].obs;
  final RxList<Ville> locations = <Ville>[].obs;

  @override
  void onInit() {
    super.onInit();
    _checkInitialState();
    _loadPublicData();

    ever(currentUser, (user) async {
      const storage = FlutterSecureStorage();
      if (user != null) {
        await storage.write(key: 'user_data', value: jsonEncode(user.toJson()));
      } else {
        await storage.delete(key: 'user_data');
      }
    });
  }

  bool get isAuthenticated => currentUser.value != null;

  Future<void> _checkInitialState() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'auth_token');
    final first = await storage.read(key: 'is_first_time');
    
    if (first == 'false') {
      isFirstTime.value = false;
    }

    if (token != null && token.isNotEmpty) {
      hasToken.value = true;
      try {
        // Load cached user instantly to avoid UI flicker
        final cachedUser = await storage.read(key: 'user_data');
        if (cachedUser != null) {
          currentUser.value = User.fromJson(jsonDecode(cachedUser));
        }

        isLoading.value = true;
        final user = await _authService.getCurrentUser();
        currentUser.value = user;
        await storage.write(key: 'user_data', value: jsonEncode(user.toJson()));
      } catch (e) {
        debugPrint('Failed to load user on startup: $e');
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> markOnboardingComplete() async {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'is_first_time', value: 'false');
    isFirstTime.value = false;
  }

  Future<void> _loadPublicData() async {
    try {
      var cats = await _authService.getCategories();
      if (cats.isEmpty) {
        cats = [
          Category(id: 1, nom: 'Électronique', slug: 'electronique'),
          Category(id: 2, nom: 'Mode', slug: 'mode'),
          Category(id: 3, nom: 'Alimentation', slug: 'alimentation'),
          Category(id: 4, nom: 'Maison', slug: 'maison'),
        ];
      }
      categories.assignAll(cats);
      
      var locs = await _authService.getLocations();
      if (locs.isEmpty) {
        locs = [
          Ville(id: 1, nom: 'Lomé', quartiers: [
            Quartier(id: 1, villeId: 1, nom: 'Adidogomé'),
            Quartier(id: 2, villeId: 1, nom: 'Agoè'),
            Quartier(id: 3, villeId: 1, nom: 'Bé'),
            Quartier(id: 4, villeId: 1, nom: 'Bagida'),
            Quartier(id: 5, villeId: 1, nom: 'Hedzranawoé'),
          ]),
          Ville(id: 2, nom: 'Kara', quartiers: [
            Quartier(id: 6, villeId: 2, nom: 'Chaminade'),
            Quartier(id: 7, villeId: 2, nom: 'Lama'),
          ]),
        ];
      }
      locations.assignAll(locs);
    } catch (e) {
      debugPrint("Failed to load public data: $e");
      // Fallback
      categories.assignAll([
        Category(id: 1, nom: 'Électronique', slug: 'electronique'),
        Category(id: 2, nom: 'Mode', slug: 'mode'),
        Category(id: 3, nom: 'Alimentation', slug: 'alimentation'),
      ]);
      locations.assignAll([
        Ville(id: 1, nom: 'Lomé', quartiers: [
          Quartier(id: 1, villeId: 1, nom: 'Adidogomé'),
          Quartier(id: 2, villeId: 1, nom: 'Agoè'),
          Quartier(id: 3, villeId: 1, nom: 'Bé'),
          Quartier(id: 4, villeId: 1, nom: 'Bagida'),
        ])
      ]);
    }
  }

  Future<bool> verifyPhone(String telephone) async {
    try {
      isLoading.value = true;
      return await _authService.verifyPhone(telephone);
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyEmail(String email) async {
    try {
      isLoading.value = true;
      return await _authService.verifyEmail(email);
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String telephone, String password) async {
    try {
      isLoading.value = true;
      final user = await _authService.login(telephone, password);
      currentUser.value = user;
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(String telephone, String password) async {
    try {
      isLoading.value = true;
      final user = await _authService.register(telephone, password);
      currentUser.value = user;
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        currentUser.value = user;
      }
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile({
    String? telephone,
    String? email,
    String? nom,
    int? quartierId,
    List<int>? selectedCategories,
    String? details,
    String? photoPath,
  }) async {
    try {
      isLoading.value = true;
      final updatedUser = await _authService.updateProfile(
        telephone: telephone,
        email: email,
        nom: nom,
        quartierId: quartierId,
        categories: selectedCategories,
        details: details,
        photoPath: photoPath,
      );
      currentUser.value = updatedUser;
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Après Google : le backend attend souvent `verify-phone` puis la mise à jour profil pour enregistrer le numéro.
  Future<void> linkSocialPhone(String telephone, String nom) async {
    try {
      isLoading.value = true;
      await _authService.verifyPhone(telephone);
      final updatedUser = await _authService.updateProfile(
        telephone: telephone,
        nom: nom,
      );
      currentUser.value = updatedUser;
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    currentUser.value = null;
    // Redirect is now handled by the UI after the loading screen
  }
  Future<void> requestPasswordReset(String telephone) async {
    try {
      isLoading.value = true;
      await _authService.requestPasswordReset(telephone);
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword(String telephone, String code, String password) async {
    try {
      isLoading.value = true;
      await _authService.resetPassword(telephone, code, password);
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
