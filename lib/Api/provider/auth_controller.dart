import 'package:get/get.dart';
import '../model/user_model.dart';
import '../model/category_model.dart';
import '../model/location_model.dart';
import '../services/auth_service.dart';
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
      // User has token, maybe fetch profile to ensure it's valid
      // For now we assume optimistic login or fetch user data here
      // Example: currentUser.value = await _authService.getCurrentUser();
      // Since backend gives token on login/register, we will consider them logged in.
      // But we should Ideally verify the token by fetching the profile.
    }
  }

  Future<void> markOnboardingComplete() async {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'is_first_time', value: 'false');
    isFirstTime.value = false;
  }

  Future<void> _loadPublicData() async {
    try {
      final cats = await _authService.getCategories();
      categories.assignAll(cats);
      
      final locs = await _authService.getLocations();
      locations.assignAll(locs);
    } catch (e) {
      print("Failed to load public data: \$e");
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
    String? nom,
    int? quartierId,
    List<int>? selectedCategories,
    String? details,
  }) async {
    try {
      isLoading.value = true;
      final updatedUser = await _authService.updateProfile(
        telephone: telephone,
        nom: nom,
        quartierId: quartierId,
        categories: selectedCategories,
        details: details,
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
}
