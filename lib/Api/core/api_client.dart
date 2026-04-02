import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_constants.dart';

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
      headers: {
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Attach Bearer token if available
          final token = await _storage.read(key: 'auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // You can handle global errors here (e.g., 401 Unauthorized -> logout)
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;

  // Utility to save token
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  // Utility to delete token
  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }

  /// General GET request
  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  /// General POST request
  Future<Response> post(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  /// General PUT request
  Future<Response> put(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  // --- ERROR HANDLING --- //

  Exception _handleException(DioException e) {
    if (e.response != null) {
      final int statusCode = e.response?.statusCode ?? 500;
      final data = e.response?.data;
      String message = "Une erreur s'est produite";

      if (data is Map<String, dynamic> && data.containsKey('message')) {
        message = data['message'];
      }

      // Handle Laravel 422 Validation Errors specifically
      if (statusCode == 422) {
        if (data is Map<String, dynamic> && data.containsKey('errors')) {
           // We extract the first error message as a default readable message
           final Map<String, dynamic> errors = data['errors'];
           if (errors.isNotEmpty) {
             final firstError = errors.values.first;
             if (firstError is List && firstError.isNotEmpty) {
               message = firstError.first;
             } else {
               message = firstError.toString();
             }
           }
        }
        return ValidationException(message, data['errors']);
      }

      if (statusCode == 401) {
        return UnauthorizedException(message);
      }

      return ServerException('$statusCode: $message');
    } else {
      // Network errors, Timeouts, etc.
      return NetworkException("Erreur de connexion. Veuillez vérifier votre réseau.");
    }
  }
}

// Custom Exception Classes
class ValidationException implements Exception {
  final String message;
  final dynamic errors;
  ValidationException(this.message, this.errors);
  
  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
  
  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => message;
}
