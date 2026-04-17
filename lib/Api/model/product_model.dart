import 'category_model.dart';
import 'boutique_model.dart';

class Product {
  final dynamic id;
  final String title;
  final double price;
  final String location;
  final String image; // Main image
  final List<String> images; // All images
  final String category; // Currently storing categorie_id as String
  final String condition; // 'Neuf' | 'Occasion'
  final String description;
  final dynamic sellerId; 
  final dynamic boutiqueId;
  final int stock;
  final bool isPriceNegotiable;
  bool isFavorite;

  // Raw API objects (useful for IDs when editing)
  final List<dynamic> rawImages;

  // Relations
  Category? categoryObj;
  Boutique? boutiqueObj;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.location,
    required this.image,
    this.images = const [],
    this.rawImages = const [],
    required this.category,
    required this.condition,
    required this.description,
    required this.sellerId,
    this.boutiqueId,
    this.stock = 1,
    this.isPriceNegotiable = false,
    this.isFavorite = false,
    this.categoryObj,
    this.boutiqueObj,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Import is done via the config (called at runtime from ApiConstants)
    List<String> parsedImages = [];
    List<dynamic> rawImagesArray = [];
    String mainImage = '';

    if (json['images'] != null && json['images'] is List) {
      rawImagesArray = json['images'];
      for (var img in json['images']) {
        final path = img['chemin_image'] ?? '';
        if (path.isNotEmpty) {
          // Path is relative like "produits/xxxx.png" → handled via ApiConstants.resolveImageUrl at display time
          parsedImages.add(path as String);
          if (img['is_principale'] == true || img['is_principale'] == 1) {
            mainImage = path;
          }
        }
      }
      if (mainImage.isEmpty && parsedImages.isNotEmpty) {
        mainImage = parsedImages.first;
      }
    }

    // Fallback: legacy image field
    if (mainImage.isEmpty) {
      mainImage = json['image_url'] ?? json['image'] ?? '';
    }

    // Localisation: use boutique address as fallback when null
    final locRaw = json['localisation'] ?? json['location'];
    String location = (locRaw != null && locRaw.toString().isNotEmpty)
        ? locRaw.toString()
        : (json['boutique']?['adresse'] ?? 'Lomé');

    return Product(
      id: json['id'],
      title: json['nom'] ?? json['titre'] ?? json['title'] ?? '',
      price: double.tryParse((json['prix'] ?? json['price'] ?? 0).toString()) ?? 0.0,
      location: location,
      image: mainImage,
      images: parsedImages,
      rawImages: rawImagesArray,
      category: (json['categorie_id'] ?? json['category'] ?? '').toString(),
      condition: json['etat'] ?? json['condition'] ?? 'Neuf',
      description: json['description'] ?? '',
      sellerId: json['boutique_id'] ?? json['sellerId'] ?? '',
      boutiqueId: json['boutique_id'],
      stock: int.tryParse((json['stock'] ?? 1).toString()) ?? 1,
      isPriceNegotiable: json['prix_negociable'] == 1 || json['prix_negociable'] == true,
      isFavorite: json['isFavorite'] ?? false,
      categoryObj: json['categorie'] != null ? Category.fromJson(json['categorie']) : null,
      boutiqueObj: json['boutique'] != null ? Boutique.fromJson(json['boutique']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': title,
      'prix': price,
      'localisation': location,
      'categorie_id': category,
      'etat': condition,
      'description': description,
      'boutique_id': boutiqueId ?? sellerId,
      'stock': stock,
      'prix_negociable': isPriceNegotiable,
    };
  }
}
