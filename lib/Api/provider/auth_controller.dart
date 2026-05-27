import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get/get.dart';
import '../model/user_model.dart';
import '../model/category_model.dart';
import '../model/location_model.dart';
import '../services/auth_service.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/api_client.dart';
import '../firebase/services/firebase_auth_bridge_service.dart';
import 'package:geolocator/geolocator.dart';
import '../../utils/location_service.dart';
import '../firebase/services/chat_service.dart';

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
        await _syncFirebaseAuth();
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
          Category(id: 1, name: 'Électronique', slug: 'electronique'),
          Category(id: 2, name: 'Mode', slug: 'mode'),
          Category(id: 3, name: 'Alimentation', slug: 'alimentation'),
          Category(id: 4, name: 'Maison', slug: 'maison'),
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
        Category(id: 1, name: 'Électronique', slug: 'electronique'),
        Category(id: 2, name: 'Mode', slug: 'mode'),
        Category(id: 3, name: 'Alimentation', slug: 'alimentation'),
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

  Future<void> _syncFirebaseAuth({bool asBoutique = false}) async {
    if (!Get.isRegistered<FirebaseAuthBridgeService>()) return;
    try {
      await Get.find<FirebaseAuthBridgeService>()
          .signInWithBackendToken(asBoutique: asBoutique);
    } catch (e) {
      debugPrint('Firebase auth sync failed: $e');
    }
  }

  Future<void> login(String telephone, String password) async {
    try {
      isLoading.value = true;
      final user = await _authService.login(telephone, password);
      currentUser.value = user;
      await _syncFirebaseAuth();
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
      await _syncFirebaseAuth();
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
        await _syncFirebaseAuth();
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
    int? villeId,
    String? quartier,
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
        villeId: villeId,
        quartier: quartier,
        categories: selectedCategories,
        details: details,
        photoPath: photoPath,
      );
      currentUser.value = updatedUser;

      // Update the user's name and avatar in all their chats
      if (Get.isRegistered<ChatService>()) {
        ChatService.to.syncEntityProfileInChats(
          entityType: 'user',
          entityId: updatedUser.id.toString(),
          newName: updatedUser.nom ?? '',
          newAvatar: updatedUser.avatarUrl ?? '',
        );
      }
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
    try {
      final apiClient = Get.find<ApiClient>();
      await apiClient.delete('/user/fcm-token');
    } catch (e) {
      debugPrint('Error deleting FCM token on logout: $e');
    }
    if (Get.isRegistered<FirebaseAuthBridgeService>()) {
      await Get.find<FirebaseAuthBridgeService>().signOut();
    }
    await _authService.logout();
    currentUser.value = null;
    hasToken.value = false;
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

  Future<void> resetPassword(
      String telephone, String code, String password) async {
    try {
      isLoading.value = true;
      await _authService.resetPassword(telephone, code, password);
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> getCurrentLocationAndMatch(
      {double? lat, double? lon}) async {
    try {
      double latitude;
      double longitude;

      if (lat != null && lon != null) {
        latitude = lat;
        longitude = lon;
      } else {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) return null;
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) return null;
        }
        if (permission == LocationPermission.deniedForever) return null;

        final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        latitude = position.latitude;
        longitude = position.longitude;
      }

      final data = await LocationService.reverseGeocode(latitude, longitude);
      if (data != null) {
        final villeName = data['ville']?.toLowerCase() ?? '';
        final quartierName = data['quartier']?.toLowerCase() ?? '';

        Ville? matchedVille;
        if (villeName.isNotEmpty) {
          for (var v in locations) {
            if (villeName.contains(v.nom.toLowerCase()) ||
                v.nom.toLowerCase().contains(villeName)) {
              matchedVille = v;
              break;
            }
          }
        }

        if (matchedVille != null) {
          Quartier? matchedQuartier;
          if (quartierName.isNotEmpty) {
            for (var q in matchedVille.quartiers) {
              if (quartierName.contains(q.nom.toLowerCase()) ||
                  q.nom.toLowerCase().contains(quartierName)) {
                matchedQuartier = q;
                break;
              }
            }
          }
          return {
            'villeId': matchedVille.id,
            'quartierId': matchedQuartier
                ?.id, // Do not auto-select the first one if no match
            'rawVille': villeName,
            'rawQuartier': quartierName,
          };
        } else {
          // Si on ne trouve pas la ville, on renvoie quand même les données brutes
          return {
            'villeId': null,
            'quartierId': null,
            'rawVille': villeName,
            'rawQuartier': quartierName,
          };
        }
      }
    } catch (e) {
      debugPrint("Erreur getCurrentLocationAndMatch: $e");
    }
    return null;
  }
}
