import '../core/api_client.dart';

abstract class BaseService {
  final ApiClient apiClient;

  BaseService(this.apiClient);

  // Common methods for all services can be defined here
}
