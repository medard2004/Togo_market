import '../Api/config/api_constants.dart';

class RefundModel {
  final int id;
  final int orderId;
  final int userId;
  final int sellerId;
  final String reason;
  final String? description;
  final List<String> images;
  final String status;
  final DateTime createdAt;

  RefundModel({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.sellerId,
    required this.reason,
    this.description,
    this.images = const [],
    required this.status,
    required this.createdAt,
  });

  factory RefundModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedImages = [];
    if (json['images'] != null && json['images'] is List) {
      for (var img in json['images']) {
        if (img != null && img.toString().isNotEmpty) {
          parsedImages.add(ApiConstants.resolveImageUrl(img.toString()));
        }
      }
    }

    return RefundModel(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      sellerId: json['seller_id'] ?? 0,
      reason: json['reason'] ?? '',
      description: json['description'],
      images: parsedImages,
      status: json['status'] ?? 'demande envoyée',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
