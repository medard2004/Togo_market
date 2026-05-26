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
      validateStatus: (status) {
        return status != null && status < 500;
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
          // Debug logging for failed requests
          print('=== DIO ERROR ===');
          print('URL: ${e.requestOptions.uri}');
          print('Method: ${e.requestOptions.method}');
          print('Status: ${e.response?.statusCode}');
          print('Request Data: ${e.requestOptions.data}');
          print('Response Body: ${e.response?.data}');
          print('=================');
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
      return _processResponse(response);
    } on DioException catch (e) {
      throw _handleNetworkError(e);
    }
  }

  /// General POST request
  Future<Response> post(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return _processResponse(response);
    } on DioException catch (e) {
      throw _handleNetworkError(e);
    }
  }

  /// General PUT request
  Future<Response> put(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return _processResponse(response);
    } on DioException catch (e) {
      throw _handleNetworkError(e);
    }
  }

  /// General PATCH request
  Future<Response> patch(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.patch(endpoint, data: data);
      return _processResponse(response);
    } on DioException catch (e) {
      throw _handleNetworkError(e);
    }
  }

  /// General DELETE request
  Future<Response> delete(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.delete(endpoint, data: data);
      return _processResponse(response);
    } on DioException catch (e) {
      throw _handleNetworkError(e);
    }
  }

  // --- ERROR HANDLING --- //

  Response _processResponse(Response response) {
    final int statusCode = response.statusCode ?? 500;
    
    // 2xx status codes are successful
    if (statusCode >= 200 && statusCode < 300) {
      return response;
    }

    final data = response.data;
    String message = "Une erreur s'est produite";

    if (data is Map<String, dynamic> && data.containsKey('message')) {
      message = data['message'];
    }

    // Handle Laravel 422 Validation Errors specifically
    if (statusCode == 422) {
      if (data is Map<String, dynamic> && data.containsKey('errors')) {
         print('=== VALIDATION ERROR 422 ===');
         print(data['errors']);
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
      throw ValidationException(message, data is Map<String, dynamic> ? data['errors'] : null);
    }

    if (statusCode == 401) {
      throw UnauthorizedException(message);
    }

    if (statusCode == 404) {
      throw NotFoundException(message);
    }

    throw ServerException('$statusCode: $message');
  }

  Exception _handleNetworkError(DioException e) {
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
           print('=== VALIDATION ERROR 422 ===');
           print(data['errors']);
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

      if (statusCode == 404) {
        return NotFoundException(message);
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

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);

  @override
  String toString() => message;
}
