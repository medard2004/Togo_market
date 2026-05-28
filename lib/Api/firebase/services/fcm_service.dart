import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toastification/toastification.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../provider/auth_controller.dart';
import '../../core/api_client.dart';
import '../../../controllers/notification_controller.dart';
import '../../../controllers/order_controller.dart';
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
          
          // Vérifier si l'utilisateur est déjà dans la discussion concernée
          final type = notif.type.toLowerCase();
          final data = notif.customData ?? {};
          final chatId = data['chat_id']?.toString();
          
          bool shouldMute = false;
          if (type == 'message' && chatId != null && chatId.isNotEmpty) {
            final currentRoute = Get.currentRoute;
            final receiverType = data['receiver_type']?.toString().toLowerCase();
            final isSaleStr = data['is_sale']?.toString().toLowerCase();
            
            bool isShopContext = false;
            if (receiverType == 'shop') {
              isShopContext = true;
            } else if (receiverType == 'user') {
              isShopContext = false;
            } else if (isSaleStr == 'true') {
              isShopContext = true;
            } else if (isSaleStr == 'false') {
              isShopContext = false;
            } else {
              final hasBoutiqueId = data['boutique_id'] != null && data['boutique_id'].toString().isNotEmpty && data['boutique_id'].toString() != 'null';
              isShopContext = (type == 'boutique' || type == 'shop') ? true : hasBoutiqueId;
            }
            
            // Si on est dans le chat actuel AVEC le bon contexte, on mute la notification
            if (currentRoute.startsWith('/chat/$chatId') && currentRoute.contains('asBoutique=$isShopContext')) {
              shouldMute = true;
              debugPrint('FCM: Utilisateur déjà dans le chat $chatId (Boutique: $isShopContext), notification mutée.');
            }
          }

          if (!shouldMute) {
            if (Get.isRegistered<NotificationController>()) {
              NotificationController.to.addForegroundNotification(notif);
            }

            // Rafraîchir silencieusement les commandes si c'est une notification de commande
            if (['order', 'order_status', 'status'].contains(type)) {
              if (Get.isRegistered<OrderController>()) {
                Get.find<OrderController>().fetchOrders();
              }
            }

            // Afficher une toast notification cliquable
            _showNotificationToast(notif);
          }
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
    final data = notif.customData ?? {};
    
    // Détection du contexte (Boutique ou Particulier)
    final receiverType = data['receiver_type']?.toString().toLowerCase();
    final isSaleStr = data['is_sale']?.toString().toLowerCase();
    
    bool isShopContext = false;
    if (receiverType == 'shop') {
      isShopContext = true;
    } else if (receiverType == 'user') {
      isShopContext = false;
    } else if (isSaleStr == 'true') {
      isShopContext = true;
    } else if (isSaleStr == 'false') {
      isShopContext = false;
    } else {
      final hasBoutiqueId = data['boutique_id'] != null && data['boutique_id'].toString().isNotEmpty && data['boutique_id'].toString() != 'null';
      isShopContext = (type == 'boutique' || type == 'shop') ? true : hasBoutiqueId;
    }

    // Choisir l'icône, la couleur et le label selon le contexte et le type
    IconData icon;
    Color accentColor;
    String contextLabel;
    
    if (isShopContext) {
      icon = (type == 'order' || type == 'order_status' || type == 'status')
          ? PhosphorIcons.shoppingBag(PhosphorIconsStyle.fill)
          : PhosphorIcons.storefront(PhosphorIconsStyle.fill);
      accentColor = Colors.orange.shade700;
      contextLabel = 'Boutique';
    } else {
      icon = (type == 'order' || type == 'order_status' || type == 'status')
          ? PhosphorIcons.package(PhosphorIconsStyle.fill)
          : PhosphorIcons.user(PhosphorIconsStyle.fill);
      accentColor = AppTheme.primary;
      contextLabel = 'Personnel';
    }

    toastification.dismissAll();
    toastification.show(
      type: ToastificationType.info,
      style: ToastificationStyle.flat,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: accentColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              contextLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              notif.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      description: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          notif.body,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12),
        ),
      ),
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: accentColor, size: 24),
      ),
      primaryColor: accentColor,
      backgroundColor: AppTheme.cardColor,
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 5),
      animationBuilder: (context, animation, alignment, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
      ],
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
      id: data['notification_id']?.toString() ?? data['id']?.toString() ?? message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: data['type']?.toString() ?? 'message',
      title: notification?.title ?? data['title']?.toString() ?? 'Nouvelle notification',
      body: notification?.body ?? data['body']?.toString() ?? '',
      time: 'À l\'instant',
      isRead: false,
      customData: Map<String, dynamic>.from(data),
    );
  }
}
