import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get/get.dart';
import 'dart:math';
import '../models/chat_model.dart';
import '../../core/api_client.dart';
import 'firebase_auth_bridge_service.dart';

class ChatService extends GetxService {
  static ChatService get to => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Génère un ID unique et déterministe pour la conversation entre deux entités.
  String getChatId({
    required String conversationType,
    required String entity1Id,
    required String entity2Id,
  }) {
    final sorted = [entity1Id, entity2Id]..sort();
    if (conversationType == 'shop') {
      return 'shop_${sorted[0]}_${sorted[1]}';
    } else {
      return 'personal_${sorted[0]}_${sorted[1]}';
    }
  }

  /// Récupère ou crée la session de chat avec les infos des entités participantes.
  Future<String> getOrCreateChat({
    required String conversationType,
    required String myEntityId,
    required String myEntityType,
    required String myName,
    required String myAvatar,
    required String otherEntityId,
    required String otherEntityType,
    required String otherName,
    required String otherAvatar,
    String? productId,
    String? productTitle,
    String? productImage,
    String? relatedShopId,
  }) async {
    final chatId = getChatId(
      conversationType: conversationType,
      entity1Id: myEntityId,
      entity2Id: otherEntityId,
    );
    final docRef = _db.collection('chats').doc(chatId);

    final docSnap = await docRef.get();
    if (!docSnap.exists) {
      // Créer une nouvelle conversation
      final myUid = '${myEntityType}_$myEntityId';
      final otherUid = '${otherEntityType}_$otherEntityId';

      final newChat = ChatSession(
        id: chatId,
        conversationType: conversationType,
        participantUids: [myUid, otherUid],
        participantNames: {
          myUid: myName,
          otherUid: otherName,
        },
        participantAvatars: {
          myUid: myAvatar,
          otherUid: otherAvatar,
        },
        productId: productId,
        productTitle: productTitle,
        productImage: productImage,
        relatedShopId: relatedShopId,
        lastMessage: '',
        lastMessageTime: DateTime.now(),
        unreadCounts: {myUid: 0, otherUid: 0},
      );
      await docRef.set(newChat.toJson());
    } else {
      // La conversation existe déjà.
      // Mettre à jour les noms/avatars si changés (les profils peuvent évoluer).
      final myUid = '${myEntityType}_$myEntityId';
      final otherUid = '${otherEntityType}_$otherEntityId';
      
      final updates = <String, dynamic>{};
      updates['participantNames.$myUid'] = myName;
      updates['participantAvatars.$myUid'] = myAvatar;
      updates['participantNames.$otherUid'] = otherName;
      updates['participantAvatars.$otherUid'] = otherAvatar;

      // Assurer que le champ participantUids existe (au cas où)
      final data = docSnap.data()!;
      if (data['participantUids'] == null) {
        updates['participantUids'] = [myUid, otherUid];
      }

      await docRef.update(updates);
    }
    return chatId;
  }

  /// Écoute TOUTES les conversations d'une entité (utilisateur ou boutique).
  Stream<List<ChatSession>> getAllChatsStream(String entityUid) {
    return _db
        .collection('chats')
        .where('participantUids', arrayContains: entityUid)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => ChatSession.fromJson(doc.data(), doc.id))
          .where((chat) => chat.lastMessage.trim().isNotEmpty)
          .toList();
      // Tri local pour éviter d'exiger un index composite sur Firestore
      list.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      return list;
    });
  }

  /// Écoute les messages d'une conversation spécifique
  Stream<List<ChatMessageData>> getMessagesStream(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessageData.fromJson(doc.data(), doc.id))
            .toList());
  }

  /// Récupère les métadonnées d'une conversation (one-shot)
  Future<ChatSession?> getChatSession(String chatId) async {
    try {
      final doc = await _db.collection('chats').doc(chatId).get();
      if (doc.exists) {
        return ChatSession.fromJson(doc.data()!, doc.id);
      }
    } catch (e) {
      debugPrint('ChatService: Erreur récupération session $chatId: $e');
    }
    return null;
  }

  static void _validateChatId(String chatId) {
    if (chatId.isEmpty) {
      throw Exception('ID de conversation manquant.');
    }
    if (!chatId.contains('_')) {
      throw Exception(
        'ID de conversation invalide. Rechargez la conversation.',
      );
    }
  }

  /// Upload un fichier média vers Firebase Storage
  Future<String> uploadMedia(
    String chatId,
    File file,
    String type, {
    bool asBoutique = false,
  }) async {
    try {
      _validateChatId(chatId);

      if (Get.isRegistered<FirebaseAuthBridgeService>()) {
        await FirebaseAuthBridgeService.to.ensureSignedInForChat(
          chatId,
          asBoutique: asBoutique,
        );
        debugPrint(
          'ChatService.uploadMedia: Firebase uid=${FirebaseAuth.instance.currentUser?.uid}',
        );
      } else {
        throw Exception(
          'FirebaseAuthBridgeService non initialisé — impossible d\'uploader.',
        );
      }

      // Nettoyer le chemin d'accès au fichier pour s'assurer qu'il n'y a pas de préfixe "file://" ou "file:"
      String filePath = file.path;
      if (filePath.startsWith('file://')) {
        try {
          filePath = Uri.parse(filePath).toFilePath();
        } catch (e) {
          filePath = filePath.replaceFirst('file://', '');
        }
      } else if (filePath.startsWith('file:')) {
        filePath = filePath.replaceFirst('file:', '');
      }

      final cleanFile = File(filePath);

      if (!await cleanFile.exists()) {
        throw Exception(
            "Fichier introuvable après nettoyage: ${cleanFile.path}");
      }

      final fileSize = await cleanFile.length();
      if (fileSize == 0) {
        throw Exception(
            "Le fichier généré est vide (0 octet). L'enregistrement a probablement échoué.");
      }

      debugPrint(
          'ChatService.uploadMedia: type=$type, size=${fileSize}B, path=${cleanFile.path}');

      final ext = type == 'image' ? 'jpg' : 'm4a';
      final contentType = type == 'image' ? 'image/jpeg' : 'audio/mp4';
      final rand = Random().nextInt(100000);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$rand.$ext';
      final storagePath = 'chats/$chatId/$type/$fileName';

      debugPrint(
          'ChatService.uploadMedia: Uploading to Supabase Storage path -> $storagePath');

      final supabase = Supabase.instance.client;
      final bytes = await cleanFile.readAsBytes();

      await supabase.storage.from('chat_media').uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(contentType: contentType),
          );

      final downloadUrl =
          supabase.storage.from('chat_media').getPublicUrl(storagePath);

      debugPrint('ChatService.uploadMedia: Upload réussi → $downloadUrl');
      return downloadUrl;
    } on StorageException catch (e) {
      debugPrint(
        '❌ ChatService.uploadMedia Supabase StorageException: status=${e.statusCode}, message=${e.message}',
      );
      rethrow;
    } catch (e) {
      debugPrint('❌ ChatService.uploadMedia ERREUR: $e');
      rethrow;
    }
  }

  /// Envoie un message dans une conversation
  Future<void> sendMessage(String chatId, String senderEntityId,
      String senderEntityType, String receiverEntityId, String receiverEntityType, String content,
      {String? productId,
      String type = 'text',
      String? mediaUrl,
      int? mediaDuration}) async {
    final msgRef =
        _db.collection('chats').doc(chatId).collection('messages').doc();
    final now = DateTime.now();

    final msg = ChatMessageData(
      id: msgRef.id,
      senderEntityId: senderEntityId,
      senderEntityType: senderEntityType,
      content: content,
      timestamp: now,
      productId: productId,
      type: type,
      mediaUrl: mediaUrl,
      mediaDuration: mediaDuration,
    );

    // Texte de résumé pour la liste des conversations
    String lastMessageText;
    switch (type) {
      case 'image':
        lastMessageText = '📷 Photo';
        break;
      case 'voice':
        lastMessageText = '🎤 Vocal';
        break;
      case 'order':
        lastMessageText = '📦 Récapitulatif de commande';
        break;
      default:
        lastMessageText = content;
    }

    final senderUid = '${senderEntityType}_$senderEntityId';
    final receiverUid = '${receiverEntityType}_$receiverEntityId';

    await _db.runTransaction((transaction) async {
      final chatRef = _db.collection('chats').doc(chatId);
      final chatDoc = await transaction.get(chatRef);

      // Ajouter le message
      transaction.set(msgRef, msg.toJson());

      if (chatDoc.exists) {
        // Mettre à jour le chat
        transaction.update(chatRef, {
          'lastMessage': lastMessageText,
          'lastMessageTime': Timestamp.fromDate(now),
          'lastMessageSenderId': senderUid,
          'unreadCounts.$receiverUid': FieldValue.increment(1),
        });
      } else {
        // Créer le chat s'il n'existe pas (fallback de sécurité)
        // Normalement getOrCreateChat a été appelé avant.
        transaction.set(
            chatRef,
            {
              'participantUids': [senderUid, receiverUid],
              'lastMessage': lastMessageText,
              'lastMessageTime': Timestamp.fromDate(now),
              'lastMessageSenderId': senderUid,
              'unreadCounts': {receiverUid: 1, senderUid: 0},
            },
            SetOptions(merge: true));
      }
    });

    // Envoyer la notification push via le backend Laravel
    _sendChatPushNotification(
        receiverEntityId, receiverEntityType, chatId, lastMessageText, productId);
  }

  Future<void> _sendChatPushNotification(String receiverId, String receiverType, String chatId,
      String content, String? productId) async {
    try {
      final apiClient = Get.find<ApiClient>();
      await apiClient.post('/notifications/send-chat-push', data: {
        'receiver_id': receiverId,
        'receiver_type': receiverType,
        'chat_id': chatId,
        'content': content,
        'product_id': productId ?? '',
      });
    } catch (e) {
      debugPrint('ChatService: Erreur envoi push notification: $e');
    }
  }

  /// Marque comme lu pour une entité spécifique
  Future<void> markAsReadForEntity(String chatId, String entityUid) async {
    final chatRef = _db.collection('chats').doc(chatId);
    try {
      final batch = _db.batch();

      // 1. Remettre le compteur global à 0
      batch.update(chatRef, {'unreadCounts.$entityUid': 0});

      // 2. Mettre à jour les messages non lus (dont l'expéditeur n'est pas l'entité)
      // Note: we can't query by senderEntityUid easily unless we compute it from entityId and entityType.
      // Or we just check that seen == false and then ignore our own messages.
      final unreadMsgs = await chatRef
          .collection('messages')
          .where('seen', isEqualTo: false)
          .get();

      for (var doc in unreadMsgs.docs) {
        final data = doc.data();
        final msgSenderUid = '${data['senderEntityType']}_${data['senderEntityId']}';
        if (msgSenderUid != entityUid) {
          batch.update(doc.reference, {
            'seen': true,
            'seenAt': FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit();
    } catch (e) {
      debugPrint('ChatService: Impossible de marquer comme lu ($e)');
    }
  }
}
