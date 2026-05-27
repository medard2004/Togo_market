import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get/get.dart';
import 'dart:io';
import 'dart:async';
import '../models/chat_model.dart';
import '../services/chat_service.dart';
import '../../provider/auth_controller.dart';
import '../../../utils/image_optimization_service.dart';
import '../../../controllers/boutique_controller.dart';

class PendingMessage {
  final String id;
  final String senderEntityId;
  final String senderEntityType;
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
    required this.senderEntityId,
    required this.senderEntityType,
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

  /// ID boutique de l'utilisateur courant (null s'il n'a pas de boutique)
  String? get _myShopId {
    if (!Get.isRegistered<BoutiqueController>()) return null;
    return Get.find<BoutiqueController>().myBoutique.value?.id.toString();
  }

  @override
  void onInit() {
    super.onInit();
    _migrateLegacyChats();

    if (Get.isRegistered<AuthController>()) {
      final auth = Get.find<AuthController>();

      // Initialize immediately if user is already present
      if (auth.currentUser.value != null) {
        _initAllChats(auth.currentUser.value!.id.toString());
      }

      ever(auth.currentUser, (user) {
        if (user != null) {
          _initAllChats(user.id.toString());
        } else {
          userChats.clear();
          shopChats.clear();
        }
      });
    }

    // Quand la boutique se charge/change → rebind les deux streams
    if (Get.isRegistered<BoutiqueController>()) {
      ever(Get.find<BoutiqueController>().myBoutique, (_) {
        if (Get.isRegistered<AuthController>()) {
          final auth = Get.find<AuthController>();
          if (auth.currentUser.value != null) {
            _initAllChats(auth.currentUser.value!.id.toString());
          }
        }
      });
    }
  }

  /// Point d'entrée unique : initialise les deux streams (personnel + boutique)
  void _initAllChats(String userId) {
    _initUserChats(userId);

    // Auto-démarrer le stream boutique si l'utilisateur en possède une
    final shopId = _myShopId;
    if (shopId != null && shopId.isNotEmpty) {
      _initShopChats(shopId);
    }
  }

  /// Fire and forget migration for legacy chats
  Future<void> _migrateLegacyChats() async {
    try {
      final db = FirebaseFirestore.instance;
      final snap = await db.collection('chats').get();
      final batch = db.batch();
      int count = 0;

      for (var doc in snap.docs) {
        final data = doc.data();
        if (data['participantUids'] == null && data['participantEntities'] != null) {
          final entities = List<dynamic>.from(data['participantEntities']).map((e) => e.toString()).toList();
          final types = Map<String, dynamic>.from(data['participantEntityTypes'] ?? {});
          
          final uids = entities.map((e) {
            final type = types[e]?.toString() ?? 'user';
            return '${type}_$e';
          }).toList();
          
          final unreads = Map<String, dynamic>.from(data['unreadCounts'] ?? {});
          final names = Map<String, dynamic>.from(data['participantNames'] ?? {});
          final avatars = Map<String, dynamic>.from(data['participantAvatars'] ?? {});
          
          final newUnreads = <String, dynamic>{};
          final newNames = <String, dynamic>{};
          final newAvatars = <String, dynamic>{};

          for (var e in entities) {
            final type = types[e]?.toString() ?? 'user';
            final uid = '${type}_$e';
            newUnreads[uid] = unreads[e] ?? 0;
            if (names.containsKey(e)) newNames[uid] = names[e];
            if (avatars.containsKey(e)) newAvatars[uid] = avatars[e];
          }

          final updates = <String, dynamic>{
            'participantUids': uids,
            'unreadCounts': newUnreads,
          };
          if (newNames.isNotEmpty) updates['participantNames'] = newNames;
          if (newAvatars.isNotEmpty) updates['participantAvatars'] = newAvatars;

          batch.update(doc.reference, updates);
          count++;
        }
      }

      if (count > 0) {
        await batch.commit();
        debugPrint('ChatController: Migrated $count legacy chats to participantUids');
      }
    } catch (e) {
      debugPrint('ChatController: Error migrating legacy chats: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  STREAM PERSONNEL (userChats)
  //  Règle : JAMAIS de conversation dont l'utilisateur est le propriétaire
  //          de la boutique impliquée.
  // ──────────────────────────────────────────────────────────────────────────
  void _initUserChats(String userId) {
    final userUid = 'user_$userId';

    userChats.bindStream(
      ChatService.to.getAllChatsStream(userUid).map((chats) {
        final myShopId = _myShopId;
        
        // SÉCURITÉ RENFORCÉE : 
        // On filtre rigoureusement toute conversation de type 'shop' 
        // qui appartient à la propre boutique de l'utilisateur.
        // Ces conversations ne doivent apparaitre que dans shopChats,
        // SAUF si l'utilisateur est LUI-MÊME l'acheteur (il achète dans sa propre boutique).
        return chats.where((chat) {
          if (chat.conversationType == 'shop' && myShopId != null && myShopId.isNotEmpty) {
             bool isMyShop = false;
             
             // 1. Vérifier via le champ relatedShopId
             if (chat.relatedShopId == myShopId) isMyShop = true;
             
             // 2. Vérifier via les participants (Méthode la plus sûre)
             if (!isMyShop && chat.participantUids.contains('shop_$myShopId')) isMyShop = true;
             
             if (isMyShop) {
               // Cette conversation implique ma boutique.
               // Je dois la voir dans ma messagerie personnelle UNIQUEMENT 
               // si je suis l'acheteur. Mon UID d'utilisateur (user_$userId) 
               // doit être dans les participants.
               bool iAmBuyer = chat.participantUids.contains('user_$userId');
               
               if (iAmBuyer) {
                 // Je suis l'acheteur de ma propre boutique ! Je garde le chat ici.
                 return true;
               } else {
                 // Je ne suis PAS l'acheteur. Ce chat appartient à la vue vendeur.
                 return false;
               }
             }
          }
          return true;
        }).toList();
      }).handleError((error) {
        debugPrint('ChatController: Erreur chargement userChats: $error');
        userChats.clear();
      }),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  STREAM BOUTIQUE (shopChats)
  //  Règle : UNIQUEMENT les conversations de type 'shop' impliquant
  //          la boutique de l'utilisateur.
  // ──────────────────────────────────────────────────────────────────────────
  void _initShopChats(String shopId) {
    final shopUid = 'shop_$shopId';

    shopChats.bindStream(
      ChatService.to.getAllChatsStream(shopUid).map((chats) {
        // Idem, filtrage strict via 'shop_$shopId'
        return chats;
      }).handleError((error) {
        debugPrint('ChatController: Erreur chargement shopChats: $error');
        shopChats.clear();
      }),
    );
  }

  /// Appelé par le dashboard — garde la compatibilité, mais le stream
  /// est déjà initialisé automatiquement si la boutique est chargée.
  void initShopChats(String shopId) {
    _initShopChats(shopId);
  }

  /// Efface les conversations de la boutique (ex: déconnexion)
  void clearShopChats() {
    shopChats.clear();
  }

  /// Charge une conversation (s'abonne aux messages + charge metadata)
  void loadConversation(String chatId, {String? actingEntityId, String? actingEntityType}) {
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

    // Marquer comme lu pour l'entité actuelle
    final entityId = actingEntityId ?? currentUserId;
    final entityType = actingEntityType ?? 'user';
    if (entityId.isNotEmpty) {
      ChatService.to.markAsReadForEntity(chatId, '${entityType}_$entityId');
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
  Future<void> sendMessage(String chatId, String senderEntityId,
      String senderEntityType, String receiverEntityId, String receiverEntityType, String content,
      {String? productId,
      String type = 'text',
      String? mediaUrl,
      int? mediaDuration}) async {
    try {
      await ChatService.to.sendMessage(
        chatId,
        senderEntityId,
        senderEntityType,
        receiverEntityId,
        receiverEntityType,
        content,
        productId: productId,
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
      String senderEntityId,
      String senderEntityType,
      String receiverEntityId,
      String receiverEntityType,
      File file,
      String caption,
      bool asBoutique,
      {String? productId,
      PendingMessage? existing}) async {
    PendingMessage pm;
    if (existing != null) {
      pm = existing;
      pm.status.value = 'sending';
      pm.progress.value = 0.0;
    } else {
      pm = PendingMessage(
        id: 'temp_${DateTime.now().microsecondsSinceEpoch}_${file.path.hashCode}',
        senderEntityId: senderEntityId,
        senderEntityType: senderEntityType,
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
        senderEntityId,
        senderEntityType,
        receiverEntityId,
        receiverEntityType,
        caption,
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
      String senderEntityId,
      String senderEntityType,
      String receiverEntityId,
      String receiverEntityType,
      File file,
      int duration,
      bool asBoutique,
      {PendingMessage? existing}) async {
    PendingMessage pm;
    if (existing != null) {
      pm = existing;
      pm.status.value = 'sending';
      pm.progress.value = 0.0;
    } else {
      pm = PendingMessage(
        id: 'temp_${DateTime.now().microsecondsSinceEpoch}_${file.path.hashCode}',
        senderEntityId: senderEntityId,
        senderEntityType: senderEntityType,
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
        senderEntityId,
        senderEntityType,
        receiverEntityId,
        receiverEntityType,
        '',
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
    String senderEntityId,
    String senderEntityType,
    String receiverEntityId,
    String receiverEntityType,
    double latitude,
    double longitude,
    String address,
  ) async {
    await sendMessage(
      chatId,
      senderEntityId,
      senderEntityType,
      receiverEntityId,
      receiverEntityType,
      address,
      type: 'location',
      mediaUrl: '$latitude,$longitude',
    );
  }
}
