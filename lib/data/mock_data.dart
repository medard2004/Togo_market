import '../models/models.dart';

// ── Catégories ────────────────────────────────────────────────────────────────
final List<Category> mockCategories = [
  Category(id: 'all', label: 'Tout', emoji: '🛍️'),
  Category(id: 'friperie', label: 'Friperie', emoji: '👗'),
  Category(id: 'mode', label: 'Mode', emoji: '👠'),
  Category(id: 'electronique', label: 'Électronique', emoji: '📱'),
  Category(id: 'maison', label: 'Maison', emoji: '🏠'),
  Category(id: 'beaute', label: 'Beauté', emoji: '💄'),
  Category(id: 'services', label: 'Services', emoji: '🔧'),
];

// ── Vendeurs ──────────────────────────────────────────────────────────────────
final List<Seller> mockSellers = [
  Seller(
    id: 's1',
    name: 'Kofi Mensah',
    shopName: 'Kofi Tech Shop',
    avatar:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop',
    rating: 4.8,
    responseTime: '~10 min',
    location: 'Tokoin, Lomé',
    products: ['p1', 'p4', 'p7'],
  ),
  Seller(
    id: 's2',
    name: 'Ama Koffi',
    shopName: 'Ama Fashion',
    avatar:
        'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=150&h=150&fit=crop',
    rating: 4.6,
    responseTime: '~5 min',
    location: 'Bè, Lomé',
    products: ['p2', 'p5', 'p8'],
  ),
  Seller(
    id: 's3',
    name: 'Yao Attiogbé',
    shopName: 'Yao Market',
    avatar:
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop',
    rating: 4.5,
    responseTime: '~20 min',
    location: 'Adidogomé, Lomé',
    products: ['p3', 'p6', 'p9'],
  ),
];

// ── Produits ──────────────────────────────────────────────────────────────────
final List<Product> mockProducts = [
  Product(
    id: 'p1',
    title: 'iPhone 13 128GB Noir',
    price: 285000,
    location: 'Tokoin, Lomé',
    image:
        'https://images.unsplash.com/photo-1632661674596-df8be070a5c5?w=400&h=400&fit=crop',
    category: 'electronique',
    condition: 'Occasion',
    description:
        'iPhone 13 en excellent état, batterie à 89%. Vendu avec chargeur original et coque de protection. Aucune rayure sur l\'écran.',
    sellerId: 's1',
    isFavorite: true,
  ),
  Product(
    id: 'p2',
    title: 'Robe Ankara Élégante',
    price: 18500,
    location: 'Bè, Lomé',
    image:
        'https://images.unsplash.com/photo-1594938298603-c8148c4b4f67?w=400&h=400&fit=crop',
    category: 'mode',
    condition: 'Neuf',
    description:
        'Magnifique robe Ankara taillée sur mesure. Tissu wax de haute qualité. Disponible en tailles S, M, L. Livraison possible dans tout Lomé.',
    sellerId: 's2',
  ),
  Product(
    id: 'p3',
    title: 'Canapé Cuir 3 Places',
    price: 125000,
    location: 'Adidogomé, Lomé',
    image:
        'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400&h=400&fit=crop',
    category: 'maison',
    condition: 'Occasion',
    description:
        'Canapé en cuir véritable, très bon état. Couleur marron chocolat. Dimensions : 220cm x 95cm. À récupérer sur place.',
    sellerId: 's3',
  ),
  Product(
    id: 'p4',
    title: 'Samsung Galaxy A54',
    price: 195000,
    location: 'Tokoin, Lomé',
    image:
        'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=400&h=400&fit=crop',
    category: 'electronique',
    condition: 'Neuf',
    description:
        'Samsung Galaxy A54 5G tout neuf, sous emballage. Double SIM, 128GB stockage, 8GB RAM. Garantie 1 an.',
    sellerId: 's1',
    isFavorite: true,
  ),
  Product(
    id: 'p5',
    title: 'Sneakers Nike Air Max',
    price: 35000,
    location: 'Bè, Lomé',
    image:
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&h=400&fit=crop',
    category: 'mode',
    condition: 'Neuf',
    description:
        'Nike Air Max 270, pointure 42. Jamais portées, achetées en Europe. Coloris blanc/rouge. Boîte d\'origine incluse.',
    sellerId: 's2',
  ),
  Product(
    id: 'p6',
    title: 'Kit Beauté Complet',
    price: 22000,
    location: 'Adidogomé, Lomé',
    image:
        'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=400&h=400&fit=crop',
    category: 'beaute',
    condition: 'Neuf',
    description:
        'Kit beauté professionnel : fond de teint, mascara, rouge à lèvres, fards à paupières. Marques premium. Parfait pour offrir.',
    sellerId: 's3',
  ),
  Product(
    id: 'p7',
    title: 'Laptop HP EliteBook',
    price: 320000,
    location: 'Tokoin, Lomé',
    image:
        'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=400&h=400&fit=crop',
    category: 'electronique',
    condition: 'Occasion',
    description:
        'HP EliteBook 840 G7, Intel Core i7, 16GB RAM, 512GB SSD. Windows 11 Pro. Écran 14" Full HD. Idéal pour le télétravail.',
    sellerId: 's1',
  ),
  Product(
    id: 'p8',
    title: 'Ensemble Wax Traditionnel',
    price: 28000,
    location: 'Bè, Lomé',
    image:
        'https://images.unsplash.com/photo-1590744816866-cdc8f2f1bcc5?w=400&h=400&fit=crop',
    category: 'friperie',
    condition: 'Neuf',
    description:
        'Ensemble 3 pièces wax: haut, jupe et foulard. Tissu importé, motifs traditionnels togolais. Cousu à la main par artisane locale.',
    sellerId: 's2',
  ),
  Product(
    id: 'p9',
    title: 'Ventilateur Sur Pied',
    price: 28500,
    location: 'Adidogomé, Lomé',
    image:
        'https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?w=400&h=400&fit=crop',
    category: 'maison',
    condition: 'Neuf',
    description:
        'Ventilateur sur pied 3 vitesses, oscillation 180°. Silencieux, parfait pour chambre ou salon. Marque Rowenta.',
    sellerId: 's3',
  ),
];

// ── Conversations ─────────────────────────────────────────────────────────────
final List<Conversation> mockConversations = [
  Conversation(
    id: 'c1',
    sellerId: 's1',
    productId: 'p1',
    lastMessage: 'Oui il est toujours disponible ! 😊',
    time: '09:45',
    unread: 2,
    messages: [
      ChatMessage(
        id: 'm1',
        content: 'Bonjour ! L\'iPhone 13 est toujours disponible ?',
        senderId: 'me',
        timestamp: '09:40',
        isMe: true,
      ),
      ChatMessage(
        id: 'm2',
        content: 'Oui il est toujours disponible ! 😊',
        senderId: 's1',
        timestamp: '09:45',
        isMe: false,
      ),
      ChatMessage(
        id: 'm3',
        content: 'Super ! Quel est votre meilleur prix ?',
        senderId: 'me',
        timestamp: '09:46',
        isMe: true,
      ),
      ChatMessage(
        id: 'm4',
        content: 'Je peux faire 270 000 F, c\'est mon dernier prix.',
        senderId: 's1',
        timestamp: '09:50',
        isMe: false,
      ),
    ],
  ),
  Conversation(
    id: 'c2',
    sellerId: 's2',
    productId: 'p2',
    lastMessage: 'La robe est disponible en taille M',
    time: 'Hier',
    unread: 0,
    messages: [
      ChatMessage(
        id: 'm5',
        content: 'Bonjour, avez-vous la robe Ankara en taille M ?',
        senderId: 'me',
        timestamp: 'Hier 15:20',
        isMe: true,
      ),
      ChatMessage(
        id: 'm6',
        content: 'La robe est disponible en taille M',
        senderId: 's2',
        timestamp: 'Hier 16:00',
        isMe: false,
      ),
    ],
  ),
];

// ── Notifications ─────────────────────────────────────────────────────────────
final List<AppNotification> mockNotifications = [
  AppNotification(
    id: 'n1',
    type: 'message',
    title: 'Nouveau message de Kofi Tech Shop',
    body: 'Je peux faire 270 000 F, c\'est mon dernier prix.',
    time: 'Il y a 5 min',
    isRead: false,
  ),
  AppNotification(
    id: 'n2',
    type: 'order',
    title: 'Commande confirmée !',
    body: 'Votre commande pour Samsung Galaxy A54 a été acceptée.',
    time: 'Il y a 1h',
    isRead: false,
  ),
  AppNotification(
    id: 'n3',
    type: 'like',
    title: 'Quelqu\'un aime votre annonce',
    body: 'Votre produit "Laptop HP EliteBook" a été ajouté en favori.',
    time: 'Hier',
    isRead: true,
  ),
  AppNotification(
    id: 'n4',
    type: 'message',
    title: 'Ama Fashion vous a répondu',
    body: 'La robe est disponible en taille M',
    time: 'Hier',
    isRead: true,
  ),
  AppNotification(
    id: 'n5',
    type: 'order',
    title: 'Nouveau client intéressé',
    body: 'Yao Market a reçu une demande pour Ventilateur Sur Pied.',
    time: 'Il y a 2 jours',
    isRead: true,
  ),
];

// ── Helper: formatPrice ───────────────────────────────────────────────────────
String formatPrice(double price) {
  final formatted = price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]} ',
      );
  return '$formatted F';
}

Seller? getSellerById(String id) {
  try {
    return mockSellers.firstWhere((s) => s.id == id);
  } catch (_) {
    return null;
  }
}

Product? getProductById(String id) {
  try {
    return mockProducts.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
}
