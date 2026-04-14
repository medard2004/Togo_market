/// Modèle de données d'une boutique — utilisé par EditShopScreen et les routes.
class ShopInfo {
  final String name;
  final String slogan;
  final String description;
  final String category;
  final String location;
  final String phone;
  final String openingTime;
  final String closingTime;
  final List<String> openingDays;
  final List<String> zones;
  final String coverUrl;
  final String logoUrl;

  const ShopInfo({
    required this.name,
    required this.slogan,
    required this.description,
    required this.category,
    required this.location,
    required this.phone,
    required this.openingTime,
    required this.closingTime,
    required this.openingDays,
    required this.zones,
    required this.coverUrl,
    required this.logoUrl,
  });

  static const sample = ShopInfo(
    name: 'Kofi Tech Shop',
    slogan: 'Électronique de qualité à Lomé',
    description:
        'Boutique spécialisée dans la vente de produits électroniques neufs et d\u2019occasion. Livraison rapide sur Lomé et service client disponible 7j/7.',
    category: 'Électronique',
    location: 'Tokoin, Lomé',
    phone: '+228 90 00 00 00',
    openingTime: '08:00',
    closingTime: '18:00',
    openingDays: ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven'],
    zones: ['Tokoin', 'Adidogomé', 'Bè'],
    coverUrl:
        'https://images.unsplash.com/photo-1556740738-b6a63e27c4df?q=80&w=600&auto=format&fit=crop',
    logoUrl:
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=200&auto=format&fit=crop',
  );
}
