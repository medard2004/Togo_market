import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get/get.dart';
import '../models/chat_model.dart';
import '../../core/api_client.dart';

class ChatService extends GetxService {
  static ChatService get to => Get.find();
  
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Génère un ID unique et déterministe pour la conversation entre deux utilisateurs.
  /// On trie les IDs pour garantir un seul ID par paire.
  String getChatId(String userId1, String userId2) {
    final sorted = [userId1, userId2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  /// Récupère ou crée la session de chat avec les infos des participants.
  Future<String> getOrCreateChat({
    required String myId,
    required String myName,
    required String myAvatar,
    required String otherId,
    required String otherName,
    required String otherAvatar,
    String? productId,
    String? productTitle,
    String? productImage,
  }) async {
    final chatId = getChatId(myId, otherId);
    final docRef = _db.collection('chats').doc(chatId);
    
    final docSnap = await docRef.get();
    if (!docSnap.exists) {
      // Créer une nouvelle conversation
      final newChat = ChatSession(
        id: chatId,
        participants: [myId, otherId],
        participantNames: {
          myId: myName,
          otherId: otherName,
        },
        participantAvatars: {
          myId: myAvatar,
          otherId: otherAvatar,
        },
        productId: productId,
        productTitle: productTitle,
        productImage: productImage,
        lastMessage: '',
        lastMessageTime: DateTime.now(),
        unreadCounts: {myId: 0, otherId: 0},
      );
      await docRef.set(newChat.toJson());
    } else {
      // La conversation existe déjà.
      // Mettre à jour les noms/avatars si changés (les profils peuvent évoluer).
      final updates = <String, dynamic>{};
      updates['participantNames.$myId'] = myName;
      updates['participantAvatars.$myId'] = myAvatar;
      updates['participantNames.$otherId'] = otherName;
      updates['participantAvatars.$otherId'] = otherAvatar;
      
      // Assurer que le champ participants existe (backward compat)
      final data = docSnap.data()!;
      if (data['participants'] == null) {
        updates['participants'] = [myId, otherId];
      }
      
      await docRef.update(updates);
    }
    return chatId;
  }

  /// Écoute TOUTES les conversations d'un utilisateur (acheteur OU vendeur).
  /// Utilise le champ `participants` array-contains.
  Stream<List<ChatSession>> getAllChatsStream(String userId) {
    return _db.collection('chats')
      .where('participants', arrayContains: userId)
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

  /// DEPRECATED: Conservé pour backward compat mais utiliser getAllChatsStream
  Stream<List<ChatSession>> getUserChatsStream(String buyerId) {
    return getAllChatsStream(buyerId);
  }

  /// DEPRECATED: Conservé pour backward compat mais utiliser getAllChatsStream
  Stream<List<ChatSession>> getShopChatsStream(String sellerId) {
    return getAllChatsStream(sellerId);
  }

  /// Écoute les messages d'une conversation spécifique
  Stream<List<ChatMessageData>> getMessagesStream(String chatId) {
    return _db.collection('chats').doc(chatId).collection('messages')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => ChatMessageData.fromJson(doc.data(), doc.id)).toList());
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

  /// Upload un fichier média vers Firebase Storage
  Future<String> uploadMedia(String chatId, File file, String type) async {
    try {
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
        throw Exception("Fichier introuvable après nettoyage: ${cleanFile.path}");
      }
      
      final fileSize = await cleanFile.length();
      if (fileSize == 0) {
        throw Exception("Le fichier généré est vide (0 octet). L'enregistrement a probablement échoué.");
      }
      
      debugPrint('ChatService.uploadMedia: type=$type, size=${fileSize}B, path=${cleanFile.path}');
      
      final ext = type == 'image' ? 'jpg' : 'm4a';
      final contentType = type == 'image' ? 'image/jpeg' : 'audio/mp4';
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      final storagePath = 'chats/$chatId/$type/$fileName';
      
      debugPrint('ChatService.uploadMedia: Uploading to Firebase Storage path -> $storagePath');
      final ref = _storage.ref().child(storagePath);
      
      final metadata = SettableMetadata(contentType: contentType);
      
      // Utilisation de putData au lieu de putFile pour contourner les problèmes de permissions
      // de fichiers sur certains appareils qui causent un échec silencieux de putFile,
      // ce qui entraîne ensuite une erreur "object-not-found" lors de getDownloadURL.
      final bytes = await cleanFile.readAsBytes();
      final snapshot = await ref.putData(bytes, metadata);
      
      if (snapshot.state != TaskState.success) {
        throw Exception("L'upload a échoué avec l'état: ${snapshot.state}");
      }
      
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      debugPrint('ChatService.uploadMedia: Upload réussi → $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ ChatService.uploadMedia ERREUR: $e');
      rethrow;
    }
  }

  /// Envoie un message dans une conversation
  Future<void> sendMessage(String chatId, String senderId, String receiverId, String content, {String? productId, required bool isBuyerSending, String type = 'text', String? mediaUrl, int? mediaDuration}) async {
    final msgRef = _db.collection('chats').doc(chatId).collection('messages').doc();
    final now = DateTime.now();

    final msg = ChatMessageData(
      id: msgRef.id,
      senderId: senderId,
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
          'lastMessageSenderId': senderId,
          'unreadCounts.$receiverId': FieldValue.increment(1),
        });
      } else {
        // Créer le chat s'il n'existe pas (fallback de sécurité)
        transaction.set(chatRef, {
          'participants': [senderId, receiverId],
          'lastMessage': lastMessageText,
          'lastMessageTime': Timestamp.fromDate(now),
          'lastMessageSenderId': senderId,
          'unreadCounts': {receiverId: 1, senderId: 0},
        }, SetOptions(merge: true));
      }
    });

    // Envoyer la notification push via le backend Laravel
    _sendChatPushNotification(receiverId, chatId, lastMessageText, productId);
  }

  Future<void> _sendChatPushNotification(String receiverId, String chatId, String content, String? productId) async {
    try {
      final apiClient = Get.find<ApiClient>();
      await apiClient.post('/notifications/send-chat-push', data: {
        'receiver_id': receiverId,
        'chat_id': chatId,
        'content': content,
        'product_id': productId ?? '',
      });
    } catch (e) {
      debugPrint('ChatService: Erreur envoi push notification: $e');
    }
  }

  /// Marque les messages comme lus (backward compat)
  Future<void> markAsRead(String chatId, {required bool isBuyer}) async {
    final chatRef = _db.collection('chats').doc(chatId);
    if (isBuyer) {
      await chatRef.update({'unreadCount_buyer': 0});
    } else {
      await chatRef.update({'unreadCount_seller': 0});
    }
  }

  /// Marque comme lu pour un userId spécifique (nouveau format)
  Future<void> markAsReadForUser(String chatId, String userId) async {
    final chatRef = _db.collection('chats').doc(chatId);
    try {
      final batch = _db.batch();
      
      // 1. Remettre le compteur global à 0
      batch.update(chatRef, {'unreadCounts.$userId': 0});
      
      // 2. Mettre à jour les messages non lus (dont l'expéditeur n'est pas userId)
      final unreadMsgs = await chatRef.collection('messages')
          .where('seen', isEqualTo: false)
          .get();
          
      for (var doc in unreadMsgs.docs) {
        if (doc.data()['senderId'] != userId) {
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
