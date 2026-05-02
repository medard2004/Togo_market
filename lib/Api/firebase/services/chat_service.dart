import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get/get.dart';
import '../models/chat_model.dart';

class ChatService extends GetxService {
  static ChatService get to => Get.find();
  
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
      .orderBy('timestamp', descending: false)
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

  /// Envoie un message dans une conversation
  Future<void> sendMessage(String chatId, String senderId, String receiverId, String content, {String? productId, required bool isBuyerSending}) async {
    final msgRef = _db.collection('chats').doc(chatId).collection('messages').doc();
    final now = DateTime.now();

    final msg = ChatMessageData(
      id: msgRef.id,
      senderId: senderId,
      content: content,
      timestamp: now,
      productId: productId,
    );

    await _db.runTransaction((transaction) async {
      final chatRef = _db.collection('chats').doc(chatId);
      
      // Ajouter le message
      transaction.set(msgRef, msg.toJson());
      
      // Mettre à jour le chat (dernier message, date, compteur non-lu du destinataire)
      transaction.update(chatRef, {
        'lastMessage': content,
        'lastMessageTime': Timestamp.fromDate(now),
        'unreadCounts.$receiverId': FieldValue.increment(1),
      });
    });
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
    await chatRef.update({'unreadCounts.$userId': 0});
  }
}
