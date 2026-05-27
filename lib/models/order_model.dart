import '../utils/app_utils.dart';
// lib/models/order_model.dart
// Modèle de commande utilisé pour l'affichage acheteur et vendeur.

class OrderModel {
  final int id;
  final int userId;
  final int sellerId;
  final int productId;
  final int quantity;
  final double totalPrice;
  final String? paymentMethod;
  final String? deliveryMethod;
  final String? deliveryAddress;
  final double? deliveryLat;
  final double? deliveryLon;
  final String? phone;
  final String? notes;
  String status; // mutable pour les mises à jour optimistes
  final DateTime createdAt;

  // Objets imbriqués
  final OrderProduct? product;
  final OrderUser? user; // acheteur (visible pour le vendeur)
  final OrderUser? seller; // vendeur  (visible pour l'acheteur)

  OrderModel({
    required this.id,
    required this.userId,
    required this.sellerId,
    required this.productId,
    required this.quantity,
    required this.totalPrice,
    this.paymentMethod,
    this.deliveryMethod,
    this.deliveryAddress,
    this.deliveryLat,
    this.deliveryLon,
    this.phone,
    this.notes,
    required this.status,
    required this.createdAt,
    this.product,
    this.user,
    this.seller,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      sellerId: json['seller_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      quantity: json['quantity'] ?? 1,
      totalPrice: double.tryParse(json['total_price']?.toString() ?? '0') ?? 0,
      paymentMethod: json['payment_method'],
      deliveryMethod: json['delivery_method'],
      deliveryAddress: json['delivery_address'],
      deliveryLat: json['delivery_lat'] != null
          ? double.tryParse(json['delivery_lat'].toString())
          : null,
      deliveryLon: json['delivery_lon'] != null
          ? double.tryParse(json['delivery_lon'].toString())
          : null,
      phone: json['phone'],
      notes: json['notes'],
      status: json['status'] ?? 'En attente',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      product: json['product'] != null
          ? OrderProduct.fromJson(json['product'])
          : null,
      user: json['user'] != null ? OrderUser.fromJson(json['user']) : null,
      seller:
          json['seller'] != null ? OrderUser.fromJson(json['seller']) : null,
    );
  }

  /// Prix formaté façon "350 000 FCFA"
  String get formattedPrice {
    return formatPrice(totalPrice);
  }

  /// Date formatée "10/05/2026 à 09:30"
  String get formattedDate {
    return '${createdAt.day.toString().padLeft(2, '0')}/'
        '${createdAt.month.toString().padLeft(2, '0')}/'
        '${createdAt.year} à '
        '${createdAt.hour.toString().padLeft(2, '0')}:'
        '${createdAt.minute.toString().padLeft(2, '0')}';
  }
}

class OrderProduct {
  final int id;
  final String titre;
  final String? image;
  final int? boutiqueId;
  final String? boutiqueNom;
  final double? boutiqueLat;
  final double? boutiqueLon;
  final String? boutiqueAdresse;
  final String? boutiqueDetailsAdresse;
  final String? boutiqueLogo;

  OrderProduct({
    required this.id,
    required this.titre,
    this.image,
    this.boutiqueId,
    this.boutiqueNom,
    this.boutiqueLat,
    this.boutiqueLon,
    this.boutiqueAdresse,
    this.boutiqueDetailsAdresse,
    this.boutiqueLogo,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    // L'image vient via images[0].chemin_image (colonne réelle dans images_produit)
    String? img;
    if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      img = json['images'][0]['chemin_image']?.toString();
    }

    int? bId = json['boutique_id'] != null
        ? int.tryParse(json['boutique_id'].toString())
        : null;
    String? bNom;
    double? bLat;
    double? bLon;
    String? bAdresse;
    String? bDetails;
    String? bLogo;
    if (json['boutique'] != null) {
      bNom = json['boutique']['nom']?.toString();
      if (bId == null && json['boutique']['id'] != null) {
        bId = int.tryParse(json['boutique']['id'].toString());
      }
      if (json['boutique']['latitude'] != null) {
        bLat = double.tryParse(json['boutique']['latitude'].toString());
      }
      if (json['boutique']['longitude'] != null) {
        bLon = double.tryParse(json['boutique']['longitude'].toString());
      }
      bAdresse = json['boutique']['adresse']?.toString();
      bDetails = json['boutique']['details_adresse']?.toString();
      bLogo = json['boutique']['logo_url']?.toString() ?? json['boutique']['logo']?.toString();
    }

    return OrderProduct(
      id: json['id'] ?? 0,
      titre: json['titre'] ?? json['title'] ?? '',
      image: img,
      boutiqueId: bId,
      boutiqueNom: bNom,
      boutiqueLat: bLat,
      boutiqueLon: bLon,
      boutiqueAdresse: bAdresse,
      boutiqueDetailsAdresse: bDetails,
      boutiqueLogo: bLogo,
    );
  }
}

class OrderUser {
  final int id;
  final String nom;
  final String? avatar;
  final String? email;
  final String? telephone;

  OrderUser({
    required this.id,
    required this.nom,
    this.avatar,
    this.email,
    this.telephone,
  });

  factory OrderUser.fromJson(Map<String, dynamic> json) {
    return OrderUser(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? json['name'] ?? 'Utilisateur',
      avatar: json['avatar_url'] ?? json['avatar'],
      email: json['email'],
      telephone: json['telephone'] ?? json['phone'],
    );
  }
}
