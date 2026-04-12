export 'product_model.dart';
export 'boutique_model.dart';

// ── Seller ───────────────────────────────────────────────────────────────────
class Seller {
  final String id;
  final String name;
  final String shopName;
  final String avatar;
  final double rating;
  final String responseTime;
  final String location;
  final List<String> products;

  const Seller({
    required this.id,
    required this.name,
    required this.shopName,
    required this.avatar,
    required this.rating,
    required this.responseTime,
    required this.location,
    required this.products,
  });
}

// ── Chat ─────────────────────────────────────────────────────────────────────
class ChatMessage {
  final String id;
  final String content;
  final String senderId;
  final String timestamp;
  final bool isMe;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.timestamp,
    required this.isMe,
  });
}

class Conversation {
  final String id;
  final String sellerId;
  final String productId;
  final String lastMessage;
  final String time;
  final int unread;
  final List<ChatMessage> messages;

  const Conversation({
    required this.id,
    required this.sellerId,
    required this.productId,
    required this.lastMessage,
    required this.time,
    required this.unread,
    required this.messages,
  });
}

// ── Category ─────────────────────────────────────────────────────────────────
class Category {
  final String id;
  final String label;
  final String emoji;

  const Category({
    required this.id,
    required this.label,
    required this.emoji,
  });
}

// ── Notification ─────────────────────────────────────────────────────────────
class AppNotification {
  final String id;
  final String type; // 'message' | 'order' | 'like'
  final String title;
  final String body;
  final String time;
  bool isRead;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
  });
}
