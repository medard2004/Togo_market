import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  /// Défini dans `.env` (clé `API_BASE_URL`), chargé au démarrage dans `main()`.
  static String get baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw StateError(
        'API_BASE_URL est absent ou vide dans le fichier .env à la racine du projet.',
      );
    }
    return url;
  }

  /// Root URL (sans /api) pour construire les URLs de storage
  static String get storageBaseUrl {
    final base = baseUrl;
    return base.endsWith('/api')
        ? base.substring(0, base.length - 4)
        : base;
  }

  /// Résout un chemin image vers une URL complète.
  /// Accepte : URLs absolues (http...), chemins /storage/... ou relatifs produits/...
  static String resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    if (path.startsWith('/storage/')) return '$storageBaseUrl$path';
    // Chemin relatif type "produits/xxxx.png"
    return '$storageBaseUrl/storage/$path';
  }

  // Public Endpoints
  static const String categoriesEndpoint = '/categories';
  static const String locationsEndpoint = '/locations';

  // Authentication Endpoints
  static const String verifyPhoneEndpoint = '/auth/verify-phone';
  static const String registerEndpoint = '/auth/register';
  static const String loginEndpoint = '/auth/login';
  static const String socialAuthEndpoint = '/auth/social';
  static const String forgotPasswordEndpoint = '/auth/forgot-password';
  static const String resetPasswordEndpoint = '/auth/reset-password';

  // Profile Endpoints
  static const String userProfileEndpoint = '/user/profile';
  static const String boutiqueEndpoint = '/boutique';
  static const String boutiqueMeEndpoint = '/boutique/me';

  // Example Endpoints
  static const String productsEndpoint = '/produits';
  static const String ordersEndpoint = '/commandes';

  // API Configuration
  static const int connectTimeout = 10000;
  static const int receiveTimeout = 10000;
}
