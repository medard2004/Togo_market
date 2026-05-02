import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get/get.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';
import '../../provider/auth_controller.dart';

class ChatController extends GetxController {
  static ChatController get to => Get.find();

  /// Conversations de l'utilisateur (en tant qu'acheteur ou vendeur particulier)
  final userChats = <ChatSession>[].obs;

  /// Conversations de la boutique du vendeur
  final shopChats = <ChatSession>[].obs;

  /// Messages de la conversation active
  final currentMessages = <ChatMessageData>[].obs;

  /// Metadata de la conversation active (pour afficher noms etc.)
  final Rx<ChatSession?> currentChatSession = Rx<ChatSession?>(null);

  String get currentUserId {
    final auth =
        Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;
    return auth?.currentUser.value?.id.toString() ?? '';
  }

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<AuthController>()) {
      final auth = Get.find<AuthController>();
      
      // Initialize immediately if user is already present
      if (auth.currentUser.value != null) {
        _initChats(auth.currentUser.value!.id.toString());
      }
      
      ever(auth.currentUser, (user) {
        if (user != null) {
          _initChats(user.id.toString());
        } else {
          userChats.clear();
          shopChats.clear();
        }
      });
    }
  }

  /// Initialise l'écoute des conversations de l'utilisateur
  void _initChats(String userId) {
    userChats.bindStream(
      ChatService.to.getAllChatsStream(userId).handleError((error) {
        debugPrint('ChatController: Erreur chargement chats: $error');
        userChats.clear();
      }),
    );
  }

  /// Initialise l'écoute des conversations de la boutique
  void initShopChats(String shopId) {
    shopChats.bindStream(
      ChatService.to.getAllChatsStream(shopId).handleError((error) {
        debugPrint('ChatController: Erreur chargement shop chats: $error');
        shopChats.clear();
      }),
    );
  }

  /// Efface les conversations de la boutique (ex: déconnexion)
  void clearShopChats() {
    shopChats.clear();
  }

  /// Charge une conversation (s'abonne aux messages + charge metadata)
  void loadConversation(String chatId, {required bool isBuyer}) {
    currentMessages.bindStream(
      ChatService.to.getMessagesStream(chatId).handleError((error) {
        debugPrint('ChatController: Erreur chargement messages: $error');
        currentMessages.clear();
      }),
    );

    // Charger les metadata de la conversation
    _loadChatSession(chatId);

    // Marquer comme lu pour l'utilisateur actuel
    final userId = currentUserId;
    if (userId.isNotEmpty) {
      ChatService.to.markAsReadForUser(chatId, userId);
    }
  }

  Future<void> _loadChatSession(String chatId) async {
    try {
      final session = await ChatService.to.getChatSession(chatId);
      currentChatSession.value = session;
    } catch (e) {
      debugPrint('ChatController: Erreur chargement session: $e');
    }
  }

  /// Envoie un message
  Future<void> sendMessage(
      String chatId, String senderId, String receiverId, String content,
      {String? productId, required bool isBuyerSending}) async {
    try {
      await ChatService.to.sendMessage(
        chatId,
        senderId,
        receiverId,
        content,
        productId: productId,
        isBuyerSending: isBuyerSending,
      );
    } catch (e) {
      debugPrint('ChatController: Erreur envoi message: $e');
      Get.snackbar('Erreur', 'Impossible d\'envoyer le message.');
    }
  }
}
