import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/bottom_nav.dart';
import '../../controllers/app_controller.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String _selectedCat = 'all';
  String _conditionFilter = 'Tous'; // Tous | Neuf | Occasion
  final _minPriceCtrl = TextEditingController();
  final _maxPriceCtrl = TextEditingController();
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-select category from route args if provided
    final args = Get.arguments;
    if (args is Map && args['categoryId'] != null) {
      _selectedCat = args['categoryId'] as String;
    }
  }

  @override
  void dispose() {
    _minPriceCtrl.dispose();
    _maxPriceCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Product> get _filteredProducts {
    final ctrl = Get.find<AppController>();
    var list = ctrl.getFilteredProducts(_selectedCat);

    // Condition filter
    if (_conditionFilter != 'Tous') {
      list = list.where((p) => p.condition == _conditionFilter).toList();
    }

    // Price filter
    final minPrice = double.tryParse(_minPriceCtrl.text) ?? 0;
    final maxPrice = double.tryParse(_maxPriceCtrl.text) ?? double.infinity;
    if (minPrice > 0 || maxPrice < double.infinity) {
      list = list
          .where((p) => p.price >= minPrice && p.price <= maxPrice)
          .toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((p) =>
              p.title.toLowerCase().contains(q) ||
              p.description.toLowerCase().contains(q))
          .toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;

    return Scaffold(
        resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  AppBackButton(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: AppTheme.shadowCard,
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: 'Rechercher dans les catégories...',
                          prefixIcon: const Icon(Icons.search,
                              size: 18, color: AppTheme.mutedForeground),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _searchCtrl.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                  child: const Icon(Icons.close,
                                      size: 16,
                                      color: AppTheme.mutedForeground),
                                )
                              : null,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 13),
                          fillColor: Colors.transparent,
                          filled: false,
                        ),
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Category pills ────────────────────────────────────────────────
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: mockCategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final cat = mockCategories[i];
                  final isActive = _selectedCat == cat.id;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCat = cat.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppTheme.primary
                            : AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isActive
                            ? AppTheme.shadowPrimary
                            : AppTheme.shadowCard,
                      ),
                      child: Text(
                        '${cat.emoji} ${cat.label}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? Colors.white
                              : AppTheme.foreground,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── Filters ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.shadowCard,
                ),
                child: Column(
                  children: [
                    // Condition toggle
                    Row(
                      children: ['Tous', 'Neuf', 'Occasion'].map((c) {
                        final isActive = _conditionFilter == c;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _conditionFilter = c),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: EdgeInsets.only(
                                  right: c != 'Occasion' ? 6 : 0),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppTheme.primary
                                    : AppTheme.muted,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  c,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isActive
                                        ? Colors.white
                                        : AppTheme.mutedForeground,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    // Price range
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: TextField(
                              controller: _minPriceCtrl,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Prix min (F)',
                                hintStyle:
                                    const TextStyle(fontSize: 12),
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                fillColor: AppTheme.muted,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('—',
                              style: TextStyle(
                                  color: AppTheme.mutedForeground)),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: TextField(
                              controller: _maxPriceCtrl,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Prix max (F)',
                                hintStyle:
                                    const TextStyle(fontSize: 12),
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                fillColor: AppTheme.muted,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Results count ─────────────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Text(
                    '${products.length} résultat${products.length != 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),

            // ── Product grid ──────────────────────────────────────────────────
            Expanded(
              child: products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('😕',
                              style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          const Text(
                            'Aucun produit trouvé',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.foreground,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Modifiez vos filtres',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.mutedForeground,
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _conditionFilter = 'Tous';
                                _minPriceCtrl.clear();
                                _maxPriceCtrl.clear();
                                _searchCtrl.clear();
                                _searchQuery = '';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Réinitialiser les filtres',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: products.length,
                      itemBuilder: (_, i) =>
                          ProductCard(product: products[i]),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}
