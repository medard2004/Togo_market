import 'package:get/get.dart';
import '../models/models.dart';
import '../data/mock_data.dart';

// ── AppController (global state) ──────────────────────────────────────────────
class AppController extends GetxController {
  // Auth state
  final isLoggedIn = false.obs;
  final userName = 'Koffi Mensah'.obs;
  final userLocation = 'Tokoin, Lomé'.obs;
  final userAvatar =
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop'
          .obs;

  // Products
  final products = <Product>[].obs;
  final favorites = <Product>[].obs;

  // Notifications badge
  final unreadNotifications = 2.obs;
  final unreadMessages = 2.obs;

  // Selected category on Home
  final selectedCategory = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    products.assignAll(mockProducts);
    favorites.assignAll(mockProducts.where((p) => p.isFavorite).toList());
  }

  void toggleFavorite(String productId) {
    final idx = products.indexWhere((p) => p.id == productId);
    if (idx == -1) return;
    products[idx].isFavorite = !products[idx].isFavorite;
    products.refresh();
    favorites.assignAll(products.where((p) => p.isFavorite).toList());
    update(); // déclenche GetBuilder (home, productCard, etc.)
  }

  bool isFavorite(String productId) {
    return products.any((p) => p.id == productId && p.isFavorite);
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
    conversations.assignAll(mockConversations);
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
    final reply = replies[
        DateTime.now().millisecond % replies.length];

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

  @override
  void onInit() {
    super.onInit();
    myProducts.assignAll(sellerDashboardProducts);
  }

  void deleteProduct(String productId) {
    myProducts.removeWhere((p) => p.id == productId);
  }
}
