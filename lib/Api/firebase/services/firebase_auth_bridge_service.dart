import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get/get.dart';
import '../../config/api_constants.dart';
import '../../core/api_client.dart';
import '../../../controllers/boutique_controller.dart';
import '../../provider/auth_controller.dart';

/// Pont Laravel Sanctum → Firebase Auth (custom tokens pour Storage).
class FirebaseAuthBridgeService extends GetxService {
  static FirebaseAuthBridgeService get to => Get.find();

  final ApiClient _apiClient;

  FirebaseAuthBridgeService(this._apiClient);

  Future<void> signInWithBackendToken({bool asBoutique = false}) async {
    final response = await _apiClient.get(
      ApiConstants.firebaseTokenEndpoint,
      queryParameters: asBoutique ? {'acting_as': 'boutique'} : null,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Token Firebase refusé (${response.statusCode}): ${response.data}',
      );
    }

    final token = response.data['token']?.toString();
    if (token == null || token.isEmpty) {
      throw Exception('Réponse Firebase sans token.');
    }

    await FirebaseAuth.instance.signInWithCustomToken(token);
    debugPrint(
      'FirebaseAuthBridge: connecté uid=${FirebaseAuth.instance.currentUser?.uid}',
    );
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      debugPrint('FirebaseAuthBridge: déconnecté');
    } catch (e) {
      debugPrint('FirebaseAuthBridge signOut: $e');
    }
  }

  static bool uidMatchesChatId(String uid, String chatId) {
    if (!chatId.contains('_')) return false;
    final parts = chatId.split('_');
    if (parts.length == 3) {
      return parts[1] == uid || parts[2] == uid;
    } else if (parts.length == 2) {
      return parts[0] == uid || parts[1] == uid;
    }
    return false;
  }

  /// Garantit une session Firebase valide pour le chat avant upload Storage.
  Future<void> ensureSignedInForChat(String chatId, {bool asBoutique = false}) async {
    // Auto-détection de sécurité pour asBoutique si la conversation est de type 'shop' et que l'utilisateur possède cette boutique
    bool resolvedAsBoutique = asBoutique;
    if (!resolvedAsBoutique && chatId.startsWith('shop_')) {
      if (Get.isRegistered<BoutiqueController>()) {
        final b = Get.find<BoutiqueController>().myBoutique.value;
        if (b != null) {
          final shopId = b.id.toString();
          final parts = chatId.split('_');
          if (parts.length == 3) {
            if (parts[1] == shopId || parts[2] == shopId) {
              resolvedAsBoutique = true;
              debugPrint('FirebaseAuthBridgeService: Auto-détecté asBoutique = true pour $chatId');
            }
          }
        }
      }
    }

    final current = FirebaseAuth.instance.currentUser;
    if (current != null && uidMatchesChatId(current.uid, chatId)) {
      // Si on est déjà connecté avec le bon UID Firebase pour le rôle attendu, on est bon !
      if (resolvedAsBoutique) {
        if (Get.isRegistered<BoutiqueController>()) {
          final b = Get.find<BoutiqueController>().myBoutique.value;
          if (b != null && current.uid == b.id.toString()) {
            return;
          }
        }
      } else {
        if (Get.isRegistered<AuthController>()) {
          final myUser = Get.find<AuthController>().currentUser.value;
          if (myUser != null && current.uid == myUser.id.toString()) {
            return;
          }
        }
      }
    }

    await signInWithBackendToken(asBoutique: resolvedAsBoutique);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw Exception(
        'Connexion Firebase échouée : aucun utilisateur après le custom token.',
      );
    }
    if (!uidMatchesChatId(uid, chatId)) {
      throw Exception(
        'UID Firebase ($uid) ne correspond pas à la conversation ($chatId). '
        'Vérifiez le mode boutique (asBoutique) ou rouvrez la discussion.',
      );
    }
  }

  /// @deprecated Préférer [ensureSignedInForChat].
  Future<void> ensureSignedIn({bool asBoutique = false}) async {
    final current = FirebaseAuth.instance.currentUser;
    if (current != null && !asBoutique) return;
    await signInWithBackendToken(asBoutique: asBoutique);
  }
}
