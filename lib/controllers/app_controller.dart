import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get/get.dart';
import '../models/models.dart'; // Re-exports Product, Boutique, Category + ChatMessage/Conversation
import '../Api/services/produit_service.dart';
import '../Api/services/boutique_service.dart';
import '../Api/services/category_service.dart';
import '../Api/services/favori_service.dart';
import '../Api/provider/auth_controller.dart';
import 'boutique_controller.dart';

// ── AppController (global state) ──────────────────────────────────────────────
class AppController extends GetxController {
  // Auth state
  final isLoggedIn = false.obs;

  // Fake Profile Data
  final userName = 'Utilisateur Test'.obs;
  final userLocation = 'Lomé, Togo'.obs;
  final userBio = 'Ceci est une fausse bio pour éviter les erreurs de compilation.'.obs;
  final userAvatar = 'https://i.pravatar.cc/150?img=11'.obs;

  // Products
  final products        = <Product>[].obs;
  final favorites       = <Product>[].obs;
  final trendingProducts = <Product>[].obs;

  // Boutiques
  final boutiques = <Boutique>[].obs;

  // Zone
  final selectedZone = RxnString(); // ville / quartier sélectionné (nullable)

  // Notifications badge
  final unreadNotifications = 2.obs;
  final unreadMessages      = 2.obs;

  // Selected category on Home
  final selectedCategory = 'all'.obs;

  // Categories
  final categories = <Category>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchBoutiques();
    // Produits puis tendances : évite course où les favoris ne sont pas encore chargés
    _bootstrapHomeFeed();

    if (Get.isRegistered<AuthController>()) {
      ever(Get.find<AuthController>().currentUser, (user) {
        if (user == null) {
          isLoggedIn.value = false;
          favorites.clear();
          for (var p in products) {
            p.isFavorite = false;
          }
          products.refresh();
          update();
        } else {
          isLoggedIn.value = true;
          fetchFavorites();
        }
      });
    }
  }

  Future<void> _bootstrapHomeFeed() async {
    await fetchProduits();
    await fetchTrendingProducts();
  }

  // ── Categories ──────────────────────────────────────────────────────────────

  Future<void> fetchCategories() async {
    try {
      final apiCategories = await CategoryService.to.getCategories();
      categories.assignAll(apiCategories);
    } catch (e) {
      debugPrint("Error fetching categories: $e");
    }
  }

  /// Returns a flat list of all categories (parents and children)
  List<Category> get allFlatCategories {
    List<Category> flat = [];
    void traverse(List<Category> list) {
      for (var cat in list) {
        flat.add(cat);
        if (cat.children.isNotEmpty) {
          traverse(cat.children);
        }
      }
    }
    traverse(categories);
    return flat;
  }

  // ── Products ────────────────────────────────────────────────────────────────

  Future<void> fetchProduits() async {
    try {
      final apiProducts = await ProduitService.to.getPublicProducts();
      // Toujours refléter la réponse API (pagination : souvent une seule page).
      products.assignAll(apiProducts);

      final auth = Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;
      if (auth != null && auth.isAuthenticated) {
        // is_favoris sur /produits ne couvre que la page courante : on resynchronise via /favoris
        await fetchFavorites();
      } else {
        favorites.clear();
        for (final p in products) {
          p.isFavorite = false;
        }
        for (final p in trendingProducts) {
          p.isFavorite = false;
        }
        products.refresh();
        trendingProducts.refresh();
      }
      update();
    } catch (e) {
      debugPrint("Error fetching products: $e");
    }
  }

  // ── Tendances ────────────────────────────────────────────────────────────────

  Future<void> fetchTrendingProducts() async {
    try {
      final trending = await ProduitService.to.getTrendingProducts();
      trendingProducts.assignAll(trending);
      _applyFavoriteFlagsToTrending();
      trendingProducts.refresh();
      update();
    } catch (e) {
      debugPrint("Error fetching trending products: $e");
      // Ne pas remplacer par products.take(8) : ordre = latest API, pas score tendance.
    }
  }

  /// Aligne les cœurs tendances avec `favorites` / drapeaux sur `products`.
  void _applyFavoriteFlagsToTrending() {
    final favIds = favorites.map((f) => f.id.toString()).toSet();
    for (final p in trendingProducts) {
      final id = p.id.toString();
      p.isFavorite =
          favIds.contains(id) || products.any((x) => x.id.toString() == id && x.isFavorite);
    }
  }

  void _rebuildFavoritesFromLocalLists() {
    final byId = <String, Product>{};
    for (final p in products) {
      if (p.isFavorite) byId[p.id.toString()] = p;
    }
    for (final p in trendingProducts) {
      if (p.isFavorite) byId[p.id.toString()] = p;
    }
    favorites.assignAll(byId.values.toList());
  }

  // ── Boutiques ───────────────────────────────────────────────────────────────

  Future<void> fetchBoutiques() async {
    try {
      final bts = await BoutiqueService.to.getBoutiques();
      boutiques.assignAll(bts);
    } catch (e) {
      debugPrint("Error fetching boutiques: $e");
    }
  }

  // ── Favoris ─────────────────────────────────────────────────────────────────

  /// Toggle favori avec mise à jour optimiste de l'UI.
  /// Si l'utilisateur n'est pas connecté, redirige vers l'authentification.
  Future<void> toggleFavorite(dynamic productId) async {
    // Vérifier si l'utilisateur est connecté
    final authCtrl = Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;
    if (authCtrl != null && !authCtrl.isAuthenticated) {
      Get.toNamed('/auth');
      return;
    }

    final idStr = productId.toString();
    final prodIdx = products.indexWhere((p) => p.id.toString() == idStr);
    final trendIdx = trendingProducts.indexWhere((p) => p.id.toString() == idStr);

    if (prodIdx == -1 && trendIdx == -1) return;

    final previousValue = prodIdx != -1
        ? products[prodIdx].isFavorite
        : trendingProducts[trendIdx].isFavorite;
    final newVal = !previousValue;

    // --- Optimistic update (flux principal + carrousel tendances) ---
    if (prodIdx != -1) products[prodIdx].isFavorite = newVal;
    if (trendIdx != -1) trendingProducts[trendIdx].isFavorite = newVal;
    products.refresh();
    trendingProducts.refresh();
    _rebuildFavoritesFromLocalLists();
    update();

    // --- Appel API en arrière-plan ---
    try {
      final newStatus = await FavoriService.to.toggleFavorite(productId);
      if (prodIdx != -1) products[prodIdx].isFavorite = newStatus;
      if (trendIdx != -1) trendingProducts[trendIdx].isFavorite = newStatus;
      products.refresh();
      trendingProducts.refresh();
      _rebuildFavoritesFromLocalLists();
      update();
    } catch (e) {
      debugPrint("Error toggling favorite: $e");
      if (prodIdx != -1) products[prodIdx].isFavorite = previousValue;
      if (trendIdx != -1) trendingProducts[trendIdx].isFavorite = previousValue;
      products.refresh();
      trendingProducts.refresh();
      _rebuildFavoritesFromLocalLists();
      update();
      Get.snackbar('Erreur', 'Impossible de mettre à jour les favoris. Vérifiez votre connexion.');
    }
  }

  /// Récupère les favoris depuis l'API (à appeler après login)
  Future<void> fetchFavorites() async {
    try {
      final favs = await FavoriService.to.getFavorites();
      favorites.assignAll(favs);
      final favIds = favs.map((f) => f.id.toString()).toSet();

      for (int i = 0; i < products.length; i++) {
        products[i].isFavorite = favIds.contains(products[i].id.toString());
      }

      for (final p in trendingProducts) {
        p.isFavorite = favIds.contains(p.id.toString());
      }

      // Favoris hors de la page courante de /produits : les ajouter au flux pour cohérence UI
      final existingIds = products.map((p) => p.id.toString()).toSet();
      for (final f in favs) {
        final id = f.id.toString();
        if (!existingIds.contains(id)) {
          f.isFavorite = true;
          products.add(f);
          existingIds.add(id);
        }
      }

      products.refresh();
      trendingProducts.refresh();
      update();
    } catch (e) {
      debugPrint("Error fetching favorites: $e");
    }
  }

  bool isFavorite(dynamic productId) {
    final idStr = productId.toString();
    if (favorites.any((p) => p.id.toString() == idStr)) return true;
    if (products.any((p) => p.id.toString() == idStr && p.isFavorite)) return true;
    return trendingProducts.any((p) => p.id.toString() == idStr && p.isFavorite);
  }

  // ── Zone ─────────────────────────────────────────────────────────────────────

  /// Liste des zones uniques extraites des produits chargés.
  List<String> get availableZones {
    final zones = products
        .map((p) => p.location.trim())
        .where((loc) => loc.isNotEmpty)
        .toSet()
        .toList();
    zones.sort();
    return zones;
  }

  /// Produits filtrés par zone (matching textuel sur localisation).
  List<Product> getProductsByZone(String zone) {
    if (zone.isEmpty) return products.take(10).toList();
    final q = zone.toLowerCase();
    return products.where((p) => p.location.toLowerCase().contains(q)).toList();
  }

  /// Change la zone active et met à jour la liste nearby.
  void setSelectedZone(String? zone) {
    selectedZone.value = zone;
    update();
  }

  // ── Filtres & Recherche ───────────────────────────────────────────────────────

  List<Product> getFilteredProducts(String categoryId) {
    if (categoryId == 'all') return products;
    return products.where((p) => p.category == categoryId).toList();
  }

  List<Product> searchProducts(String query) {
    final q = query.toLowerCase();
    return products
        .where(
          (p) =>
              p.title.toLowerCase().contains(q) ||
              p.description.toLowerCase().contains(q) ||
              p.category.toLowerCase().contains(q),
        )
        .toList();
  }

  List<Product> getSimilarProducts(String productId, String category) {
    return products
        .where((p) => p.category == category && p.id != productId)
        .take(4)
        .toList();
  }

  void login() {
    isLoggedIn.value = true;
  }
}

// ── ChatController ────────────────────────────────────────────────────────────
class ChatController extends GetxController {
  final conversations  = <Conversation>[].obs;
  final currentMessages = <ChatMessage>[].obs;
  final isTyping       = false.obs;

  @override
  void onInit() {
    super.onInit();
    conversations.assignAll([]);
  }

  void loadConversation(String conversationId) {
    final conv = conversations.firstWhereOrNull((c) => c.id == conversationId);
    if (conv != null) {
      currentMessages.assignAll(conv.messages);
    }
  }

  Future<void> sendMessage(
      String conversationId, String content, String sellerId) async {
    final newMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      senderId: 'me',
      timestamp: _formatTime(),
      isMe: true,
    );
    currentMessages.add(newMsg);

    // Simulate bot reply after 1.2s
    isTyping.value = true;
    await Future.delayed(const Duration(milliseconds: 1200));
    isTyping.value = false;

    final replies = [
      'Merci pour votre message ! Je vous réponds rapidement. 😊',
      'Oui, le produit est toujours disponible.',
      'Je peux vous faire un meilleur prix si vous venez le récupérer.',
      'Livraison possible dans tout Lomé pour 1 000 F.',
      'Contactez-moi au +228 90 00 00 00 pour plus d\'infos.',
    ];
    final reply = replies[DateTime.now().millisecond % replies.length];

    final botMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: reply,
      senderId: sellerId,
      timestamp: _formatTime(),
      isMe: false,
    );
    currentMessages.add(botMsg);
  }

  String _formatTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}

// ── DashboardController ───────────────────────────────────────────────────────
class DashboardController extends GetxController {
  final selectedTab = 0.obs;
  final myProducts  = <Product>[].obs;
  final isLoading   = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadMyProducts();

    if (Get.isRegistered<AuthController>()) {
      ever(Get.find<AuthController>().currentUser, (user) {
        if (user == null) {
          myProducts.clear();
        } else {
          loadMyProducts();
        }
      });
    }
  }

  Future<void> loadMyProducts() async {
    isLoading.value = true;
    try {
      final boutique = Get.isRegistered<BoutiqueController>()
          ? BoutiqueController.to.myBoutique.value
          : null;
      if (boutique != null) {
        final products = await ProduitService.to.getMyBoutiqueProducts(boutique.id.toString());
        myProducts.assignAll(products);
      }
    } catch (e) {
      debugPrint("Error loading boutique products: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await ProduitService.to.deleteProduct(productId);
      myProducts.removeWhere((p) => p.id.toString() == productId);
      // Also remove from global list
      if (Get.isRegistered<AppController>()) {
        Get.find<AppController>().products.removeWhere((p) => p.id.toString() == productId);
      }
      Get.snackbar('Succès', 'Produit supprimé avec succès');
    } catch (e) {
      Get.snackbar('Erreur', e.toString());
    }
  }
}
