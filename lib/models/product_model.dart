class Product {
  final dynamic id;
  final String title;
  final double price;
  final String location;
  final String image;
  final dynamic category;
  final String condition; // 'Neuf' | 'Occasion'
  final String description;
  final dynamic sellerId; // Keeping for backward compatibility
  final dynamic boutiqueId;
  final int stock;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.location,
    required this.image,
    required this.category,
    required this.condition,
    required this.description,
    required this.sellerId,
    this.boutiqueId,
    this.stock = 1,
    this.isFavorite = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['nom'] ?? json['title'] ?? '',
      price: double.tryParse((json['prix'] ?? json['price'] ?? 0).toString()) ?? 0.0,
      location: json['location'] ?? 'Lomé',
      image: json['image_url'] ?? json['image'] ?? '',
      category: json['categorie_id'] ?? json['category'] ?? '',
      condition: json['condition'] ?? 'Neuf',
      description: json['description'] ?? '',
      sellerId: json['boutique_id'] ?? json['sellerId'] ?? '',
      boutiqueId: json['boutique_id'],
      stock: int.tryParse((json['stock'] ?? 1).toString()) ?? 1,
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': title,
      'prix': price,
      'location': location,
      'image_url': image,
      'categorie_id': category,
      'condition': condition,
      'description': description,
      'boutique_id': boutiqueId ?? sellerId,
      'stock': stock,
    };
  }
}
