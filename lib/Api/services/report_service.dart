import 'package:get/get.dart';
import '../core/api_client.dart';

class ReportService extends GetxService {
  final ApiClient _apiClient;

  ReportService(this._apiClient);

  static ReportService get to => Get.find();

  /// Envoie un signalement au backend.
  /// [type] doit être 'product' ou 'shop'.
  /// [targetId] est l'identifiant du produit ou de la boutique.
  /// [reason] est le motif sélectionné.
  /// [comment] est le commentaire optionnel.
  Future<void> submitReport({
    required String type,
    required String targetId,
    required String reason,
    String? comment,
  }) async {
    try {
      // Préparation du payload
      final payload = {
        'type': type,
        'target_id': targetId,
        'reason': reason,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      };

      // TODO: Remplacer par le vrai endpoint quand le backend sera prêt.
      // Par exemple : await _apiClient.post('/reports', data: payload);
      
      // Simulation temporaire du succès de l'appel API
      await Future.delayed(const Duration(seconds: 1));
      
      // Décommenter la ligne ci-dessous lorsque la route backend est disponible.
      // await _apiClient.post('/reports', data: payload);
      
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi du signalement : $e');
    }
  }
}
