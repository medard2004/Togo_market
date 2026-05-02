import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../provider/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FCMService extends GetxService {
  static FCMService get to => Get.find();
  
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<FCMService> init() async {
    // Ne pas bloquer l'initialisation avec la demande de permission
    _initMessaging();
    return this;
  }

  Future<void> _initMessaging() async {
    try {
      // Demander les permissions
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('FCM: Permission accordée');
        
        // Récupérer le token
        String? token = await _messaging.getToken();
        if (token != null) {
          await _saveToken(token);
        }

        // Écouter les changements de token
        _messaging.onTokenRefresh.listen(_saveToken);

        // Gérer les messages quand l'application est au premier plan
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('Message reçu: ${message.notification?.title}');
          if (message.notification != null) {
            Get.snackbar(
              message.notification!.title ?? 'Nouveau message',
              message.notification!.body ?? '',
              snackPosition: SnackPosition.TOP,
            );
          }
        });
      }
    } catch (e) {
      debugPrint('FCM init error: $e');
    }
  }

  Future<void> _saveToken(String token) async {
    final auth = Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;
    final user = auth?.currentUser.value;
    
    if (user != null) {
      // Sauvegarder le token dans une collection users par exemple
      await _db.collection('users').doc(user.id.toString()).set({
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }
}
