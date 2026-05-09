import 'package:cloud_firestore/cloud_firestore.dart';

class ChatSession {
  final String id;
  
  /// Liste des deux IDs participants [userId1, userId2]
  final List<String> participants;
  
  /// Map {userId: nom} pour chaque participant
  final Map<String, String> participantNames;
  
  /// Map {userId: avatarUrl} pour chaque participant
  final Map<String, String> participantAvatars;
  
  /// Infos sur le produit lié à la conversation
  final String? productId;
  final String? productTitle;
  final String? productImage;
  
  final String lastMessage;
  final DateTime lastMessageTime;
  final String lastMessageSenderId;
  
  /// Map {userId: count} pour les non-lus de chaque participant
  final Map<String, int> unreadCounts;

  ChatSession({
    required this.id,
    required this.participants,
    this.participantNames = const {},
    this.participantAvatars = const {},
    this.productId,
    this.productTitle,
    this.productImage,
    required this.lastMessage,
    required this.lastMessageTime,
    this.lastMessageSenderId = '',
    this.unreadCounts = const {},
  });

  /// Retourne le nombre de non-lus pour un utilisateur donné
  int unreadCountFor(String userId) => unreadCounts[userId] ?? 0;

  /// Retourne l'ID de l'autre participant
  String otherParticipantId(String myId) {
    return participants.firstWhere((id) => id != myId, orElse: () => '');
  }

  /// Retourne le nom de l'autre participant
  String otherParticipantName(String myId) {
    final otherId = otherParticipantId(myId);
    return participantNames[otherId] ?? 'Utilisateur';
  }

  /// Retourne l'avatar de l'autre participant
  String otherParticipantAvatar(String myId) {
    final otherId = otherParticipantId(myId);
    return participantAvatars[otherId] ?? '';
  }

  factory ChatSession.fromJson(Map<String, dynamic> json, String id) {
    // Parsing participants
    List<String> participants = [];
    if (json['participants'] is List) {
      participants = List<String>.from(
        (json['participants'] as List).map((e) => e.toString()),
      );
    } else {
      // Backward compat: old buyerId/sellerId format
      final buyerId = json['buyerId']?.toString() ?? '';
      final sellerId = json['sellerId']?.toString() ?? '';
      if (buyerId.isNotEmpty) participants.add(buyerId);
      if (sellerId.isNotEmpty) participants.add(sellerId);
    }

    // Parsing participant names
    Map<String, String> names = {};
    if (json['participantNames'] is Map) {
      names = Map<String, String>.from(json['participantNames']);
    }

    // Parsing participant avatars
    Map<String, String> avatars = {};
    if (json['participantAvatars'] is Map) {
      avatars = Map<String, String>.from(json['participantAvatars']);
    }

    // Parsing unread counts
    Map<String, int> unreads = {};
    if (json['unreadCounts'] is Map) {
      unreads = Map<String, int>.from(
        (json['unreadCounts'] as Map).map(
          (k, v) => MapEntry(k.toString(), (v is int) ? v : int.tryParse(v.toString()) ?? 0),
        ),
      );
    } else {
      // Backward compat
      if (json['unreadCount_buyer'] != null && participants.isNotEmpty) {
        unreads[participants.first] = json['unreadCount_buyer'] ?? 0;
      }
      if (json['unreadCount_seller'] != null && participants.length > 1) {
        unreads[participants.last] = json['unreadCount_seller'] ?? 0;
      }
    }

    return ChatSession(
      id: id,
      participants: participants,
      participantNames: names,
      participantAvatars: avatars,
      productId: json['productId']?.toString(),
      productTitle: json['productTitle'],
      productImage: json['productImage'],
      lastMessage: json['lastMessage'] ?? '',
      lastMessageTime: (json['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessageSenderId: json['lastMessageSenderId']?.toString() ?? '',
      unreadCounts: unreads,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participants': participants,
      'participantNames': participantNames,
      'participantAvatars': participantAvatars,
      'productId': productId,
      'productTitle': productTitle,
      'productImage': productImage,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCounts': unreadCounts,
    };
  }
}

class ChatMessageData {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool seen;
  final DateTime? seenAt;
  final String? productId;
  
  /// Type de message : 'text', 'image', 'voice'
  final String type;
  
  /// URL du média (image ou vocal) stocké dans Firebase Storage
  final String? mediaUrl;
  
  /// Durée du vocal en secondes
  final int? mediaDuration;

  ChatMessageData({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.seen = false,
    this.seenAt,
    this.productId,
    this.type = 'text',
    this.mediaUrl,
    this.mediaDuration,
  });

  factory ChatMessageData.fromJson(Map<String, dynamic> json, String id) {
    return ChatMessageData(
      id: id,
      senderId: json['senderId']?.toString() ?? '',
      content: json['content'] ?? '',
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      seen: json['seen'] ?? json['isRead'] ?? false,
      seenAt: (json['seenAt'] as Timestamp?)?.toDate(),
      productId: json['productId'],
      type: json['type'] ?? 'text',
      mediaUrl: json['mediaUrl'],
      mediaDuration: json['mediaDuration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'seen': seen,
      if (seenAt != null) 'seenAt': Timestamp.fromDate(seenAt!),
      'productId': productId,
      'type': type,
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
      if (mediaDuration != null) 'mediaDuration': mediaDuration,
    };
  }
}
