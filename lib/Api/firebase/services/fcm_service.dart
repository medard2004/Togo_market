import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toastification/toastification.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../provider/auth_controller.dart';
import '../../core/api_client.dart';
import '../../../controllers/notification_controller.dart';
import '../../../models/models.dart';
import '../../../theme/app_theme.dart';

class FCMService extends GetxService {
  static FCMService get to => Get.find();
  
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<FCMService> init() async {
    _initMessaging();
    _setupAuthListener();
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
        
        // Récupérer le token initial
        String? token = await _messaging.getToken();
        if (token != null) {
          await _saveToken(token);
        }

        // Écouter les changements de token
        _messaging.onTokenRefresh.listen(_saveToken);

        // 1. Gérer les messages quand l'application est au premier plan (Foreground)
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('FCM: Message reçu en premier plan : ${message.notification?.title}');
          
          final notif = _parseRemoteMessage(message);
          
          // Ajouter au contrôleur pour persistance locale instantanée
          if (Get.isRegistered<NotificationController>()) {
            NotificationController.to.addForegroundNotification(notif);
          }

          // Afficher une toast notification cliquable
          _showNotificationToast(notif);
        });

        // 2. Gérer le clic quand l'application est en arrière-plan (Background)
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          debugPrint('FCM: Clic sur notification en arrière-plan');
          _handleNotificationClick(message);
        });

        // 3. Gérer le clic quand l'application était fermée (Terminated)
        _messaging.getInitialMessage().then((RemoteMessage? message) {
          if (message != null) {
            debugPrint('FCM: Lancement depuis une notification (Terminated)');
            // Petit délai pour s'assurer que la navigation est prête
            Future.delayed(const Duration(milliseconds: 1500), () {
              _handleNotificationClick(message);
            });
          }
        });
      }
    } catch (e) {
      debugPrint('FCM init error: $e');
    }
  }

  /// Affiche une toast notification premium et cliquable en foreground
  void _showNotificationToast(AppNotification notif) {
    final String type = notif.type.toLowerCase();
    
    // Choisir l'icône et la couleur selon le type
    IconData icon;
    Color accentColor;
    switch (type) {
      case 'order':
        icon = PhosphorIcons.shoppingBag(PhosphorIconsStyle.fill);
        accentColor = AppTheme.secondary;
        break;
      case 'message':
        icon = PhosphorIcons.chatCircle(PhosphorIconsStyle.fill);
        accentColor = AppTheme.primary;
        break;
      default:
        icon = PhosphorIcons.bell(PhosphorIconsStyle.fill);
        accentColor = AppTheme.primary;
    }

    toastification.dismissAll();
    toastification.show(
      type: ToastificationType.info,
      style: ToastificationStyle.flat,
      title: Text(
        notif.title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      description: Text(
        notif.body,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12),
      ),
      icon: Icon(icon, color: accentColor, size: 24),
      primaryColor: accentColor,
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 5),
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      borderRadius: BorderRadius.circular(14),
      boxShadow: highModeShadow,
      showProgressBar: true,
      dragToClose: true,
      closeButtonShowType: CloseButtonShowType.onHover,
      callbacks: ToastificationCallbacks(
        onTap: (item) {
          toastification.dismissById(item.id);
          if (Get.isRegistered<NotificationController>()) {
            NotificationController.to.handleNotificationTap(notif);
          }
        },
      ),
    );
  }

  void _setupAuthListener() {
    if (Get.isRegistered<AuthController>()) {
      ever(Get.find<AuthController>().currentUser, (user) async {
        if (user != null) {
          // Si l'utilisateur se connecte, on récupère le token FCM courant et on le synchronise
          try {
            String? token = await _messaging.getToken();
            if (token != null) {
              await _saveToken(token);
            }
          } catch (e) {
            debugPrint('FCM error on auth listener: $e');
          }
        }
      });
    }
  }

  Future<void> _saveToken(String token) async {
    final auth = Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;
    final user = auth?.currentUser.value;
    
    if (user != null) {
      // 1. Sauvegarder dans Firestore (pour compatibilité Chat existante)
      try {
        await _db.collection('users').doc(user.id.toString()).set({
          'fcmToken': token,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        debugPrint('FCM: Token sauvegardé dans Firestore');
      } catch (e) {
        debugPrint('FCM: Erreur sauvegarde Firestore : $e');
      }

      // 2. Sauvegarder dans le backend Laravel via l'API
      try {
        final api = Get.find<ApiClient>();
        final response = await api.post('/user/fcm-token', data: {'fcm_token': token});
        if (response.statusCode == 200) {
          debugPrint('FCM: Token synchronisé avec succès sur le backend Laravel');
        }
      } catch (e) {
        debugPrint('FCM: Erreur synchronisation Laravel backend : $e');
      }
    }
  }

  void _handleNotificationClick(RemoteMessage message) {
    final notif = _parseRemoteMessage(message);
    if (Get.isRegistered<NotificationController>()) {
      NotificationController.to.handleNotificationTap(notif);
    }
  }

  AppNotification _parseRemoteMessage(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;

    return AppNotification(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: data['type']?.toString() ?? 'message',
      title: notification?.title ?? data['title']?.toString() ?? 'Nouvelle notification',
      body: notification?.body ?? data['body']?.toString() ?? '',
      time: 'À l\'instant',
      isRead: false,
      customData: Map<String, dynamic>.from(data),
    );
  }
}
