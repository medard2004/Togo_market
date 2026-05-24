import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get/get.dart';
import 'dart:io';
import 'dart:async';
import '../models/chat_model.dart';
import '../services/chat_service.dart';
import '../../provider/auth_controller.dart';
import '../../../utils/image_optimization_service.dart';

class PendingMessage {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final String type; // 'image', 'voice', 'location'
  final String? localFilePath;
  final String? mediaUrl;
  final int? mediaDuration;
  final String? productId;
  final RxDouble progress = 0.0.obs;
  final RxString status = 'sending'.obs; // 'sending', 'error', 'success'
  final File? originalFile;

  PendingMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.type,
    this.localFilePath,
    this.mediaUrl,
    this.mediaDuration,
    this.productId,
    this.originalFile,
  });
}

class ChatController extends GetxController {
  static ChatController get to => Get.find();

  /// Conversations de l'utilisateur (en tant qu'acheteur ou vendeur particulier)
  final userChats = <ChatSession>[].obs;

  /// Conversations de la boutique du vendeur
  final shopChats = <ChatSession>[].obs;

  /// Messages de la conversation active
  final currentMessages = <ChatMessageData>[].obs;

  /// Messages locaux en cours d'upload
  final pendingMessages = <PendingMessage>[].obs;

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
  void loadConversation(String chatId, {required bool isBuyer, String? actingUserId}) {
    // Clear pending messages when switching conversations to avoid displaying old ones
    pendingMessages.clear();
    currentMessages.bindStream(
      ChatService.to.getMessagesStream(chatId).handleError((error) {
        debugPrint('ChatController: Erreur chargement messages: $error');
        currentMessages.clear();
      }),
    );

    // Charger les metadata de la conversation
    _loadChatSession(chatId);

    // Marquer comme lu pour l'utilisateur actuel (ou la boutique)
    final userId = actingUserId ?? currentUserId;
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
      {String? productId, required bool isBuyerSending, String type = 'text', String? mediaUrl, int? mediaDuration}) async {
    try {
      await ChatService.to.sendMessage(
        chatId,
        senderId,
        receiverId,
        content,
        productId: productId,
        isBuyerSending: isBuyerSending,
        type: type,
        mediaUrl: mediaUrl,
        mediaDuration: mediaDuration,
      );
    } catch (e) {
      debugPrint('ChatController: Erreur envoi message: $e');
      Get.snackbar('Erreur', 'Impossible d\'envoyer le message.');
    }
  }

  void _startProgressSimulation(PendingMessage pm) {
    Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (pm.status.value != 'sending') {
        timer.cancel();
        return;
      }
      if (pm.progress.value < 0.90) {
        pm.progress.value += 0.05;
      } else {
        timer.cancel();
      }
    });
  }

  /// Upload une image en arrière-plan avec optimistic UI
  Future<void> uploadAndSendImage(
    String chatId,
    String senderId,
    String receiverId,
    File file,
    String caption,
    bool isBuyerSending,
    bool asBoutique,
    {String? productId,
    PendingMessage? existing}
  ) async {
    PendingMessage pm;
    if (existing != null) {
      pm = existing;
      pm.status.value = 'sending';
      pm.progress.value = 0.0;
    } else {
      pm = PendingMessage(
        id: 'temp_${DateTime.now().microsecondsSinceEpoch}_${file.path.hashCode}',
        senderId: senderId,
        content: caption,
        timestamp: DateTime.now(),
        type: 'image',
        localFilePath: file.path,
        originalFile: file,
        productId: productId,
      );
      pendingMessages.add(pm);
    }

    _startProgressSimulation(pm);

    try {
      // 1. Optimiser l'image
      final optimizedFile = await ImageOptimizationService.optimizeImage(file);
      
      // 2. Uploader vers Supabase
      final downloadUrl = await ChatService.to.uploadMedia(
        chatId,
        optimizedFile,
        'image',
        asBoutique: asBoutique,
      );

      // 3. Envoyer dans Firestore
      await ChatService.to.sendMessage(
        chatId,
        senderId,
        receiverId,
        caption,
        isBuyerSending: isBuyerSending,
        type: 'image',
        mediaUrl: downloadUrl,
        productId: productId,
      );

      pm.progress.value = 1.0;
      pm.status.value = 'success';
      
      // Supprimer le pending après une courte transition
      Future.delayed(const Duration(milliseconds: 300), () {
        pendingMessages.remove(pm);
      });
    } catch (e) {
      debugPrint('❌ Erreur upload image background: $e');
      pm.status.value = 'error';
    }
  }

  /// Upload une note vocale en arrière-plan avec optimistic UI
  Future<void> uploadAndSendVoiceNote(
    String chatId,
    String senderId,
    String receiverId,
    File file,
    int duration,
    bool isBuyerSending,
    bool asBoutique,
    {PendingMessage? existing}
  ) async {
    PendingMessage pm;
    if (existing != null) {
      pm = existing;
      pm.status.value = 'sending';
      pm.progress.value = 0.0;
    } else {
      pm = PendingMessage(
        id: 'temp_${DateTime.now().microsecondsSinceEpoch}_${file.path.hashCode}',
        senderId: senderId,
        content: '🎤 Vocal',
        timestamp: DateTime.now(),
        type: 'voice',
        localFilePath: file.path,
        originalFile: file,
        mediaDuration: duration,
      );
      pendingMessages.add(pm);
    }

    _startProgressSimulation(pm);

    try {
      final downloadUrl = await ChatService.to.uploadMedia(
        chatId,
        file,
        'voice',
        asBoutique: asBoutique,
      );

      await ChatService.to.sendMessage(
        chatId,
        senderId,
        receiverId,
        '',
        isBuyerSending: isBuyerSending,
        type: 'voice',
        mediaUrl: downloadUrl,
        mediaDuration: duration,
      );

      pm.progress.value = 1.0;
      pm.status.value = 'success';
      
      Future.delayed(const Duration(milliseconds: 300), () {
        pendingMessages.remove(pm);
      });
    } catch (e) {
      debugPrint('❌ Erreur upload vocal background: $e');
      pm.status.value = 'error';
    }
  }

  /// Envoie un message de localisation
  Future<void> sendLocationMessage(
    String chatId,
    String senderId,
    String receiverId,
    double latitude,
    double longitude,
    String address,
    bool isBuyerSending,
  ) async {
    await sendMessage(
      chatId,
      senderId,
      receiverId,
      address,
      isBuyerSending: isBuyerSending,
      type: 'location',
      mediaUrl: '$latitude,$longitude',
    );
  }
}
