import 'package:cloud_firestore/cloud_firestore.dart';

class ChatSession {
  final String id;
  final String conversationType; // 'personal' | 'shop'

  // Array of composite UIDs for querying (e.g., ['user_123', 'shop_456'])
  final List<String> participantUids;
  
  // List of UIDs for whom this chat is hidden
  final List<String> hiddenForUids;

  // Map {uid: name} e.g. {'user_5': 'Jean', 'shop_10': 'Ma Boutique'}
  final Map<String, String> participantNames;

  // Map {uid: avatarUrl}
  final Map<String, String> participantAvatars;

  final String? productId;
  final String? productTitle;
  final String? productImage;
  final String? relatedShopId;

  final String lastMessage;
  final DateTime lastMessageTime;
  final String lastMessageSenderId; // raw entityId for display logic

  // Map {uid: unreadCount}
  final Map<String, int> unreadCounts;

  ChatSession({
    required this.id,
    required this.conversationType,
    required this.participantUids,
    this.participantNames = const {},
    this.participantAvatars = const {},
    this.productId,
    this.productTitle,
    this.productImage,
    this.relatedShopId,
    required this.lastMessage,
    required this.lastMessageTime,
    this.lastMessageSenderId = '',
    this.hiddenForUids = const [],
    this.unreadCounts = const {},
  });

  int unreadCountFor(String uid) => unreadCounts[uid] ?? 0;

  /// Returns the other participant's composite UID (e.g. 'shop_10')
  String otherParticipantUid(String myUid) {
    return participantUids.firstWhere((uid) => uid != myUid,
        orElse: () => '');
  }

  String otherParticipantName(String myUid) {
    final otherUid = otherParticipantUid(myUid);
    return participantNames[otherUid] ?? 'Utilisateur';
  }

  String otherParticipantAvatar(String myUid) {
    final otherUid = otherParticipantUid(myUid);
    return participantAvatars[otherUid] ?? '';
  }

  factory ChatSession.fromJson(Map<String, dynamic> json, String id) {
    List<String> uids = [];
    if (json['participantUids'] is List) {
      uids = List<String>.from(
        (json['participantUids'] as List).map((e) => e.toString()),
      );
    }

    List<String> hiddenFor = [];
    if (json['hiddenForUids'] is List) {
      hiddenFor = List<String>.from(
        (json['hiddenForUids'] as List).map((e) => e.toString()),
      );
    }

    Map<String, String> names = {};
    if (json['participantNames'] is Map) {
      names = Map<String, String>.from(json['participantNames']);
    }

    Map<String, String> avatars = {};
    if (json['participantAvatars'] is Map) {
      avatars = Map<String, String>.from(json['participantAvatars']);
    }

    Map<String, int> unreads = {};
    if (json['unreadCounts'] is Map) {
      unreads = Map<String, int>.from(
        (json['unreadCounts'] as Map).map(
          (k, v) => MapEntry(
              k.toString(), (v is int) ? v : int.tryParse(v.toString()) ?? 0),
        ),
      );
    }

    return ChatSession(
      id: id,
      conversationType: json['conversationType'] ?? 'personal',
      participantUids: uids,
      participantNames: names,
      participantAvatars: avatars,
      productId: json['productId']?.toString(),
      productTitle: json['productTitle'],
      productImage: json['productImage'],
      relatedShopId: json['relatedShopId']?.toString(),
      lastMessage: json['lastMessage'] ?? '',
      lastMessageTime:
          (json['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessageSenderId: json['lastMessageSenderId']?.toString() ?? '',
      hiddenForUids: hiddenFor,
      unreadCounts: unreads,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationType': conversationType,
      'participantUids': participantUids,
      'participantNames': participantNames,
      'participantAvatars': participantAvatars,
      'productId': productId,
      'productTitle': productTitle,
      'productImage': productImage,
      'relatedShopId': relatedShopId,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'lastMessageSenderId': lastMessageSenderId,
      'hiddenForUids': hiddenForUids,
      'unreadCounts': unreadCounts,
    };
  }
}

class ChatMessageData {
  final String id;
  final String senderEntityId;
  final String senderEntityType;
  final String content;
  final DateTime timestamp;
  final bool seen;
  final DateTime? seenAt;
  final String? productId;
  final String type; // 'text', 'image', 'voice'
  final String? mediaUrl;
  final int? mediaDuration;
  final bool isDeletedGlobally;
  final List<String> deletedForUids;

  ChatMessageData({
    required this.id,
    required this.senderEntityId,
    required this.senderEntityType,
    required this.content,
    required this.timestamp,
    this.seen = false,
    this.seenAt,
    this.productId,
    this.type = 'text',
    this.mediaUrl,
    this.mediaDuration,
    this.isDeletedGlobally = false,
    this.deletedForUids = const [],
  });

  factory ChatMessageData.fromJson(Map<String, dynamic> json, String id) {
    List<String> deletedFor = [];
    if (json['deletedForUids'] is List) {
      deletedFor = List<String>.from(
        (json['deletedForUids'] as List).map((e) => e.toString()),
      );
    }

    return ChatMessageData(
      id: id,
      senderEntityId: json['senderEntityId']?.toString() ?? '',
      senderEntityType: json['senderEntityType']?.toString() ?? 'user',
      content: json['content'] ?? '',
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      seen: json['seen'] ?? json['isRead'] ?? false,
      seenAt: (json['seenAt'] as Timestamp?)?.toDate(),
      productId: json['productId'],
      type: json['type'] ?? 'text',
      mediaUrl: json['mediaUrl'],
      mediaDuration: json['mediaDuration'],
      isDeletedGlobally: json['isDeletedGlobally'] ?? false,
      deletedForUids: deletedFor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderEntityId': senderEntityId,
      'senderEntityType': senderEntityType,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'seen': seen,
      if (seenAt != null) 'seenAt': Timestamp.fromDate(seenAt!),
      'productId': productId,
      'type': type,
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
      if (mediaDuration != null) 'mediaDuration': mediaDuration,
      'isDeletedGlobally': isDeletedGlobally,
      'deletedForUids': deletedForUids,
    };
  }
}
