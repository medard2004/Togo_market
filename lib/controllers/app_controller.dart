import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get/get.dart';
import '../Api/model/product_model.dart';
import '../Api/model/boutique_model.dart';
import '../Api/model/category_model.dart';
import '../models/models.dart'; // Still needed for ChatMessage/Conversation
import '../Api/services/produit_service.dart';
import '../Api/services/category_service.dart';
import 'boutique_controller.dart';

// ── AppController (global state) ──────────────────────────────────────────────
class AppController extends GetxController {
  // Auth state
  final isLoggedIn = false.obs;

  // Products
  final products = <Product>[].obs;
  final favorites = <Product>[].obs;

  // Notifications badge
  final unreadNotifications = 2.obs;
  final unreadMessages = 2.obs;

  // Selected category on Home
  final selectedCategory = 'all'.obs;

  // Categories
  final categories = <Category>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Start with empty lists, then fetch from API
    fetchCategories();
    fetchProduits();
  }

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
        if (cat.children != null && cat.children!.isNotEmpty) {
          traverse(cat.children!);
        }
      }
    }

    traverse(categories);
    return flat;
  }

  Future<void> fetchProduits() async {
    try {
      final apiProducts = await ProduitService.to.getPublicProducts();
      if (apiProducts.isNotEmpty) {
        products.assignAll(apiProducts);
        favorites.assignAll(apiProducts.where((p) => p.isFavorite).toList());
      }
    } catch (e) {
      debugPrint("Error fetching products: $e");
    }
  }

  void toggleFavorite(dynamic productId) {
    final idStr = productId.toString();
    final idx = products.indexWhere((p) => p.id.toString() == idStr);
    if (idx == -1) return;
    products[idx].isFavorite = !products[idx].isFavorite;
    products.refresh();
    favorites.assignAll(products.where((p) => p.isFavorite).toList());
    update(); // déclenche GetBuilder (home, productCard, etc.)
  }

  bool isFavorite(dynamic productId) {
    final idStr = productId.toString();
    return products.any((p) => p.id.toString() == idStr && p.isFavorite);
  }

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
  final conversations = <Conversation>[].obs;
  final currentMessages = <ChatMessage>[].obs;
  final isTyping = false.obs;

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
  final myProducts = <Product>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadMyProducts();
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
      // Call API
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

