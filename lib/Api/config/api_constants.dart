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

  // Example Endpoints
  static const String productsEndpoint = '/produits';
  static const String ordersEndpoint = '/commandes';

  // API Configuration
  static const int connectTimeout = 10000;
  static const int receiveTimeout = 10000;
}
