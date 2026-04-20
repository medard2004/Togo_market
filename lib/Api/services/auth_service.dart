import '../core/api_client.dart';
import '../config/api_constants.dart';
import '../model/user_model.dart';
import '../model/category_model.dart';
import '../model/location_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart' as dio;

class AuthService {
  final ApiClient _apiClient;
  
  AuthService(this._apiClient);

  // --- PUBLIC DATA --- //
  
  Future<List<Category>> getCategories() async {
    final response = await _apiClient.get(ApiConstants.categoriesEndpoint);
    if (response.statusCode == 200) {
      final List data = response.data;
      return data.map((json) => Category.fromJson(json)).toList();
    }
    throw Exception('Failed to load categories');
  }

  Future<List<Ville>> getLocations() async {
    final response = await _apiClient.get(ApiConstants.locationsEndpoint);
    if (response.statusCode == 200) {
      final List data = response.data;
      return data.map((json) => Ville.fromJson(json)).toList();
    }
    throw Exception('Failed to load locations');
  }

  // --- AUTHENTICATION FLOW --- //

  /// Règle métier : Le numéro doit impérativement avoir le préfixe "+228" suivi de 8 chiffres
  /// Renverra un 422 (ValidationException) si invalide, géré par ApiClient.
  Future<bool> verifyPhone(String telephone) async {
    final response = await _apiClient.post(
      ApiConstants.verifyPhoneEndpoint,
      data: {'telephone': telephone},
    );
    return response.statusCode == 200;
  }

  Future<bool> verifyEmail(String email) async {
    final response = await _apiClient.post(
      ApiConstants.verifyEmailEndpoint,
      data: {'email': email},
    );
    return response.statusCode == 200;
  }

  Future<User> register(String telephone, String password) async {
    final response = await _apiClient.post(
      ApiConstants.registerEndpoint,
      data: {
        'telephone': telephone,
        'password': password,
      },
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final token = response.data['token'];
      final user = User.fromJson(response.data['user']);
      await _apiClient.saveToken(token);
      return user;
    }
    throw Exception('Register failed');
  }

  Future<User> getCurrentUser() async {
    final response = await _apiClient.get('/user');
    if (response.statusCode == 200) {
      return User.fromJson(response.data['user']);
    }
    throw Exception('Failed to load current user');
  }

  Future<User> login(String telephone, String password) async {
    final response = await _apiClient.post(
      ApiConstants.loginEndpoint,
      data: {
        'telephone': telephone,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final token = response.data['token'];
      final user = User.fromJson(response.data['user']);
      await _apiClient.saveToken(token);
      return user;
    }
    throw Exception('Login failed');
  }

  Future<User> updateProfile({
    String? telephone,
    String? email,
    String? nom,
    int? quartierId,
    List<int>? categories,
    String? details,
    String? photoPath,
  }) async {
    if (photoPath != null && photoPath.isNotEmpty) {
      final Map<String, dynamic> formDataMap = {};
      if (telephone != null && telephone.isNotEmpty) formDataMap['telephone'] = telephone;
      if (email != null && email.isNotEmpty) formDataMap['email'] = email;
      if (nom != null) formDataMap['nom'] = nom;
      if (quartierId != null) formDataMap['quartier_id'] = quartierId;
      if (details != null && details.isNotEmpty) formDataMap['details'] = details;
      if (categories != null) {
        for (int i = 0; i < categories.length; i++) {
          formDataMap['categories[$i]'] = categories[i];
        }
      }
      // Laravel best practice for multipart updates
      formDataMap['_method'] = 'PUT';
      formDataMap['photo'] = await dio.MultipartFile.fromFile(photoPath);

      final payload = dio.FormData.fromMap(formDataMap);

      final response = await _apiClient.post(
        ApiConstants.userProfileEndpoint,
        data: payload,
      );

      if (response.statusCode == 200) {
        return User.fromJson(response.data['user']);
      }
      throw Exception('Profile update failed');
    } else {
      final Map<String, dynamic> body = {};
      if (telephone != null && telephone.isNotEmpty) body['telephone'] = telephone;
      if (email != null && email.isNotEmpty) body['email'] = email;
      if (nom != null) body['nom'] = nom;
      if (quartierId != null) body['quartier_id'] = quartierId;
      if (categories != null) body['categories'] = categories;
      if (details != null && details.isNotEmpty) body['details'] = details;

      final response = await _apiClient.put(
        ApiConstants.userProfileEndpoint,
        data: body,
      );

      if (response.statusCode == 200) {
        return User.fromJson(response.data['user']);
      }
      throw Exception('Profile update failed');
    }
  }

  Future<String> requestPasswordReset(String telephone) async {
    final response = await _apiClient.post(
      ApiConstants.forgotPasswordEndpoint,
      data: {'telephone': telephone},
    );
    if (response.statusCode == 200) {
      return response.data['message'] ?? 'Code envoyé';
    }
    throw Exception('Request failed');
  }

  Future<String> resetPassword(String telephone, String code, String password) async {
    final response = await _apiClient.post(
      ApiConstants.resetPasswordEndpoint,
      data: {
        'telephone': telephone,
        'code': code,
        'password': password,
      },
    );
    if (response.statusCode == 200) {
      return response.data['message'] ?? 'Mot de passe réinitialisé';
    }
    throw Exception('Reset failed');
  }

  // --- SOCIAL AUTHENTICATION --- //

  Future<User> socialLogin(String provider, String idToken, {String? nom, String? email}) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.socialAuthEndpoint,
        data: {
          'provider': provider,
          'token': idToken,
          if (nom != null && nom.isNotEmpty) 'nom': nom,
          if (email != null && email.isNotEmpty) 'email': email,
        },
      );

      if (response.statusCode == 200) {
        final token = response.data['token'];
        final user = User.fromJson(response.data['user']);
        await _apiClient.saveToken(token);
        return user;
      }
      throw Exception('Backend returned ${response.statusCode}: ${response.data}');
    } catch (e) {
      print('SocialLogin API Error: $e');
      rethrow;
    }
  }

  bool _isGoogleSignInInitialized = false;

  // Helper integration with google_sign_in package
  Future<User?> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn.instance;
      
      if (!_isGoogleSignInInitialized) {
        await googleSignIn.initialize(
          serverClientId: '837496328760-601482t0kgr95ce28915k6j23mphsie4.apps.googleusercontent.com', // Web Client ID from google-services.json
        );
        _isGoogleSignInInitialized = true;
      }

      final GoogleSignInAccount account = await googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );
      
      final GoogleSignInAuthentication auth = await account.authentication;
      if (auth.idToken != null) {
        // Send to our Laravel backend
        return await socialLogin(
          'google', 
          auth.idToken!,
          nom: account.displayName,
          email: account.email,
        );
      } else {
        throw Exception('Google Auth SUCCESS but idToken is null. Check Web Client ID.');
      }
    } catch (e) {
      throw Exception('Google Auth failed: $e');
    }
  }
  
  Future<void> logout() async {
    try {
      // On invalide le token côté serveur
      await _apiClient.post('/auth/logout');
    } catch (_) {
      // Ignorer si la session serveur est déjà invalide ou expirée
    } finally {
      // Suppression stricte du token côté local en toutes circonstances
      await _apiClient.deleteToken();
    }
  }
}
