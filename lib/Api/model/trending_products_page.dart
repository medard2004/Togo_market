import 'product_model.dart';

/// Réponse paginée Laravel (`LengthAwarePaginator`) pour `/produits/trending/paginated`.
class TrendingProductsPage {
  final List<Product> items;
  final int currentPage;
  final int lastPage;

  TrendingProductsPage({
    required this.items,
    required this.currentPage,
    required this.lastPage,
  });

  bool get hasMore => currentPage < lastPage;

  int? get nextPage => hasMore ? currentPage + 1 : null;

  factory TrendingProductsPage.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final list = raw is List ? raw : <dynamic>[];
    final items = list
        .map((e) => Product.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    final current = _asInt(json['current_page']) ?? 1;
    final last = _asInt(json['last_page']) ?? current;

    return TrendingProductsPage(
      items: items,
      currentPage: current,
      lastPage: last,
    );
  }

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}
