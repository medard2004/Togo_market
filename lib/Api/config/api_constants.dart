class ApiConstants {
  // Base URL
  static const String baseUrl = 'http://192.168.1.73:8000/api';

  // Public Endpoints
  static const String categoriesEndpoint = '/categories';
  static const String locationsEndpoint = '/locations';

  // Authentication Endpoints
  static const String verifyPhoneEndpoint = '/auth/verify-phone';
  static const String registerEndpoint = '/auth/register';
  static const String loginEndpoint = '/auth/login';
  static const String socialAuthEndpoint = '/auth/social';

  // Profile Endpoints
  static const String userProfileEndpoint = '/user/profile';

  // Example Endpoints
  static const String productsEndpoint = '/produits';
  static const String ordersEndpoint = '/commandes';

  // API Configuration
  static const int connectTimeout = 10000;
  static const int receiveTimeout = 10000;
}
