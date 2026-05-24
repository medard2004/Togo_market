import 'package:flutter/widgets.dart';

export '../Api/model/product_model.dart';
export '../Api/model/boutique_model.dart';
export '../Api/model/category_model.dart';
export '../Api/model/user_model.dart';

// ── Seller ───────────────────────────────────────────────────────────────────
class Seller {
  final String id;
  final String name;
  final String shopName;
  final String avatar;
  final String coverUrl;
  final double rating;
  final String responseTime;
  final String location;
  final bool isShop;
  final List<String> products;

  const Seller({
    required this.id,
    required this.name,
    required this.shopName,
    required this.avatar,
    required this.coverUrl,
    required this.rating,
    required this.responseTime,
    required this.location,
    required this.isShop,
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
  final String? productId;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.timestamp,
    required this.isMe,
    this.productId,
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

// ── AppCategory (UI only) ────────────────────────────────────────────────────
class AppCategory {
  final String id;
  final String label;
  final IconData icon;

  const AppCategory({
    required this.id,
    required this.label,
    required this.icon,
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
  final Map<String, dynamic>? customData;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
    this.customData,
  });
}

// ── Order ────────────────────────────────────────────────────────────────────
class Order {
  final String id;
  final String productId;
  final String buyerId;
  final String sellerId;
  final String status; // 'En attente', 'Confirmé', 'Terminé', 'Annulé'
  final String date;
  final String deliveryMode; // 'livraison', 'retrait'
  final String phone;
  final String? note;
  final String? location; // GPS coordinates or address
  final double totalPrice;

  const Order({
    required this.id,
    required this.productId,
    required this.buyerId,
    required this.sellerId,
    required this.status,
    required this.date,
    required this.deliveryMode,
    required this.phone,
    this.note,
    this.location,
    required this.totalPrice,
  });
}
