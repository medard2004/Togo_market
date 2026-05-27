import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Api/core/api_client.dart';
import '../Api/provider/auth_controller.dart';
import '../models/models.dart';
import 'boutique_controller.dart';

class NotificationController extends GetxController {
  static NotificationController get to => Get.find();

  final RxList<AppNotification> notifications = <AppNotification>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;

  final String _storageKey = 'cached_notifications_local';
  late SharedPreferences _prefs;
  
  final ApiClient _api = Get.find<ApiClient>();
  final AuthController _authCtrl = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    _initStorage();
  }

  Future<void> _initStorage() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await loadNotificationsFromLocal();
    } catch (e) {
      debugPrint('NotificationController storage error: $e');
    }

    // Écouter les changements de connexion
    ever(_authCtrl.currentUser, (user) {
      if (user != null) {
        fetchNotificationsFromServer();
      } else {
        notifications.clear();
        unreadCount.value = 0;
        _saveToLocal();
      }
    });
  }

  /// Charge les notifications depuis le stockage local (SharedPreferences)
  Future<void> loadNotificationsFromLocal() async {
    final String? localData = _prefs.getString(_storageKey);
    if (localData != null && localData.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(localData);
        notifications.value = decoded.map((e) => _mapJsonToNotification(e)).toList();
        _updateUnreadCount();
      } catch (e) {
        debugPrint('Erreur décodage notifications locales: $e');
      }
    }
  }

  /// Récupère les notifications depuis le serveur Laravel
  /// Le serveur est la source de vérité : on REMPLACE le cache local.
  Future<void> fetchNotificationsFromServer() async {
    if (!_authCtrl.isAuthenticated) return;
    
    isLoading.value = true;
    try {
      final response = await _api.get('/notifications');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['notifications'] ?? [];
        final int serverUnread = response.data['unread_count'] ?? 0;
        
        final List<AppNotification> serverNotifications = 
            data.map((e) => _mapJsonToNotification(e)).toList();
        
        // Le serveur est la source de vérité, on remplace entièrement
        notifications.value = serverNotifications;
        unreadCount.value = serverUnread;
        await _saveToLocal();
      }
    } catch (e) {
      debugPrint('Erreur chargement notifications distantes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Ajouter une notification reçue en direct (foreground FCM)
  /// On utilise un fingerprint (type+title+body) pour éviter les doublons
  Future<void> addForegroundNotification(AppNotification notif) async {
    // Anti-doublon par ID exact
    if (notifications.any((n) => n.id == notif.id)) return;

    // Anti-doublon par contenu identique reçu récemment
    final fingerprint = '${notif.type}_${notif.title}_${notif.body}';
    if (notifications.isNotEmpty) {
      final latest = notifications.first;
      final latestFingerprint = '${latest.type}_${latest.title}_${latest.body}';
      if (fingerprint == latestFingerprint) {
        // Même contenu déjà en tête de liste → ignorer le doublon
        return;
      }
    }

    notifications.insert(0, notif);
    _updateUnreadCount();
    await _saveToLocal();
  }

  /// Marquer une notification comme lue
  Future<void> markAsRead(AppNotification notif) async {
    if (notif.isRead) return;

    // Mise à jour optimiste
    notif.isRead = true;
    notifications.refresh();
    _updateUnreadCount();
    await _saveToLocal();

    if (_authCtrl.isAuthenticated) {
      try {
        await _api.post('/notifications/${notif.id}/mark-read');
      } catch (e) {
        debugPrint('Erreur marquage notification lue sur serveur: $e');
      }
    }
  }

  /// Marquer toutes les notifications comme lues
  Future<void> markAllAsRead() async {
    bool hasUnread = notifications.any((n) => !n.isRead);
    if (!hasUnread) return;

    // Mise à jour optimiste
    for (var n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
    unreadCount.value = 0;
    await _saveToLocal();

    if (_authCtrl.isAuthenticated) {
      try {
        await _api.post('/notifications/mark-all-read');
      } catch (e) {
        debugPrint('Erreur marquage total lu sur serveur: $e');
      }
    }
  }

  /// Gérer l'action de clic sur une notification (navigation intelligente)
  void handleNotificationTap(AppNotification notif) {
    markAsRead(notif);
    
    final String type = notif.type.toLowerCase();
    final data = notif.customData ?? {};

    // Détection du contexte (Boutique ou Particulier)
    final receiverType = data['receiver_type']?.toString().toLowerCase();
    final isShopContext = receiverType == 'shop' || data.containsKey('boutique_id');

    if (type == 'message') {
      final String? chatId = data['chat_id']?.toString();
      if (chatId != null && chatId.isNotEmpty) {
        Get.toNamed('/chat/$chatId?asBoutique=$isShopContext');
      } else {
        // Rediriger vers l'espace messages général ou dashboard
        if (isShopContext) {
          BoutiqueController.to.goToMyBoutique();
        } else {
          Get.toNamed('/messages');
        }
      }
    } else if (type == 'order') {
      _handleOrderNotificationTap(data, isShopContext);
    } else if (type == 'like') {
      final String? productId = data['product_id']?.toString();
      if (productId != null && productId.isNotEmpty) {
        Get.toNamed('/product/$productId');
      } else {
        Get.toNamed('/favorites');
      }
    } else if (type == 'boutique' || type == 'shop' || isShopContext) {
      // Redirection intelligente vers la boutique
      final String? boutiqueId = data['boutique_id']?.toString() ?? data['id']?.toString();
      if (boutiqueId != null && boutiqueId.isNotEmpty) {
        final myBoutiqueId = BoutiqueController.to.myBoutique.value?.id?.toString();
        if (myBoutiqueId == boutiqueId) {
          Get.toNamed('/dashboard');
        } else {
          Get.toNamed('/seller/$boutiqueId');
        }
      } else {
        BoutiqueController.to.goToMyBoutique();
      }
    }
  }

  /// Navigation intelligente pour les notifications de commande
  void _handleOrderNotificationTap(Map<String, dynamic> data, bool isShopContext) {
    final String? orderId = data['order_id']?.toString();
    final String? productId = data['product_id']?.toString();
    // Déduire isSale soit explicitement du payload, soit du contexte Boutique
    final bool isSale = data['is_sale']?.toString().toLowerCase() == 'true' || isShopContext;
    
    if (orderId != null && orderId.isNotEmpty && orderId != 'null') {
      // Rediriger vers le détail exact de la commande
      Get.toNamed('/order-details', arguments: {
        'orderId': orderId,
        'isSale': isSale,
      });
    } else if (isShopContext && productId != null && productId.isNotEmpty && productId != 'null') {
      // Fallback: rediriger vers le détail du produit si la commande n'a pas d'ID explicite mais qu'on a le produit
      Get.toNamed('/product/$productId');
    } else {
      // Rediriger vers l'espace global
      if (isSale) {
        Get.toNamed('/dashboard'); // Redirection vers le tableau de bord vendeur
      } else {
        Get.toNamed('/orders'); // Redirection vers les achats particuliers
      }
    }
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  Future<void> _saveToLocal() async {
    try {
      final List<Map<String, dynamic>> jsonList = 
          notifications.map((n) => _mapNotificationToJson(n)).toList();
      await _prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('NotificationController saveToLocal error: $e');
    }
  }

  AppNotification _mapJsonToNotification(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: json['type'] ?? 'message',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      time: json['time'] ?? 'À l\'instant',
      isRead: json['isRead'] ?? json['is_read'] ?? false,
      customData: json['customData'] != null 
          ? Map<String, dynamic>.from(json['customData'])
          : json['custom_data'] != null 
              ? Map<String, dynamic>.from(json['custom_data'])
              : null,
    );
  }

  Map<String, dynamic> _mapNotificationToJson(AppNotification notif) {
    return {
      'id': notif.id,
      'type': notif.type,
      'title': notif.title,
      'body': notif.body,
      'time': notif.time,
      'isRead': notif.isRead,
      'customData': notif.customData,
    };
  }
}
