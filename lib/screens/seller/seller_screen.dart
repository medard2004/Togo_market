import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:togo_market/theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../../utils/responsive.dart';
import 'widgets/seller_product_card.dart';

class SellerScreen extends StatelessWidget {
  SellerScreen({super.key});

  final RxString selectedCategory = 'all'.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedSort = 'newest'.obs;
  final RxString selectedCondition = 'all'.obs;
  final RxDouble minPrice = 0.0.obs;
  final RxDouble maxPrice = 1000000.0.obs;
  final RxInt minRating = 0.obs;
  final RxBool isSearching = false.obs;
  final TextEditingController searchController = TextEditingController();

  void _showFilterSheet(BuildContext context, R r) {
    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        padding: EdgeInsets.fromLTRB(r.s(20), r.s(16), r.s(20), r.s(30)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(r.rad(40))),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filtrer & Trier',
                      style: TextStyle(
                          fontSize: r.fs(22),
                          fontWeight: FontWeight.w900,
                          color: Colors.black)),
                  TextButton(
                    onPressed: () {
                      selectedCategory.value = 'all';
                      selectedSort.value = 'newest';
                      selectedCondition.value = 'all';
                      minPrice.value = 0.0;
                      maxPrice.value = 1000000.0;
                      minRating.value = 0;
                    },
                    child: Text('Réinitialiser',
                        style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: r.fs(14))),
                  ),
                ],
              ),
              SizedBox(height: r.s(20)),

              // Categories
              _buildSectionTitle('Catégorie', r),
              SizedBox(height: r.s(12)),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterChip('Tout', 'all', selectedCategory, r,
                        icon: Icons.grid_view_rounded),
                    ...mockCategories.where((c) => c.id != 'all').map((cat) =>
                        _buildFilterChip(cat.label, cat.id, selectedCategory, r,
                            icon: cat.icon)),
                  ],
                ),
              ),
              SizedBox(height: r.s(20)),

              // Price Range
              _buildSectionTitle('Tranche de prix', r),
              SizedBox(height: r.s(8)),
              Obx(() => Column(
                    children: [
                      RangeSlider(
                        values: RangeValues(minPrice.value, maxPrice.value),
                        min: 0,
                        max: 1000000,
                        divisions: 100,
                        activeColor: AppTheme.primary,
                        inactiveColor: const Color(0xFFF5F6F8),
                        labels: RangeLabels(
                          '${minPrice.value.toInt()} F',
                          '${maxPrice.value.toInt()} F',
                        ),
                        onChanged: (values) {
                          minPrice.value = values.start;
                          maxPrice.value = values.end;
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('0 F',
                              style: TextStyle(
                                  fontSize: r.fs(12), color: Colors.grey)),
                          Text('1M+ F',
                              style: TextStyle(
                                  fontSize: r.fs(12), color: Colors.grey)),
                        ],
                      ),
                    ],
                  )),
              SizedBox(height: r.s(20)),

              // Sort By
              _buildSectionTitle('Trier par', r),
              SizedBox(height: r.s(12)),
              Wrap(
                spacing: r.s(10),
                runSpacing: r.s(10),
                children: [
                  _buildFilterChip('Plus récent', 'newest', selectedSort, r),
                  _buildFilterChip(
                      'Prix croissant', 'price_asc', selectedSort, r),
                  _buildFilterChip(
                      'Prix décroissant', 'price_desc', selectedSort, r),
                ],
              ),
              SizedBox(height: r.s(20)),

              // Condition & Rating
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('État', r),
                        SizedBox(height: r.s(12)),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip(
                                  'Tous', 'all', selectedCondition, r),
                              _buildFilterChip(
                                  'Neuf', 'Neuf', selectedCondition, r),
                              _buildFilterChip(
                                  'Occasion', 'Occasion', selectedCondition, r),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: r.s(32)),

              // Apply Button
              SizedBox(
                width: double.infinity,
                height: r.s(56),
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(r.rad(20))),
                    elevation: 0,
                  ),
                  child: Text('Appliquer les filtres',
                      style: TextStyle(
                          fontSize: r.fs(16),
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, R r) {
    return Text(title,
        style: TextStyle(
            fontSize: r.fs(16),
            fontWeight: FontWeight.w800,
            color: Colors.black.withOpacity(0.8)));
  }

  Widget _buildFilterChip(String label, String value, RxString groupValue, R r,
      {IconData? icon}) {
    return Obx(() {
      final isSelected = groupValue.value == value;
      return GestureDetector(
        onTap: () => groupValue.value = value,
        child: Container(
          margin: EdgeInsets.only(right: r.s(8)),
          padding: EdgeInsets.symmetric(horizontal: r.s(16), vertical: r.s(10)),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : const Color(0xFFF5F6F8),
            borderRadius: BorderRadius.circular(r.rad(14)),
            border: Border.all(
              color: isSelected ? AppTheme.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: r.s(16),
                  color: isSelected ? Colors.white : Colors.black54,
                ),
                SizedBox(width: r.s(8)),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: r.fs(13),
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    final id = Get.parameters['id'] ?? 's1';
    final seller = getSellerById(id);
    if (seller == null) {
      return const Scaffold(body: Center(child: Text('Vendeur introuvable')));
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: r.s(64),
        leading: Padding(
          padding: EdgeInsets.only(left: r.s(16)),
          child: Center(
            child: GestureDetector(
              onTap: () {
                if (isSearching.value) {
                  isSearching.value = false;
                  searchQuery.value = '';
                  searchController.clear();
                } else {
                  Get.back();
                }
              },
              child: Container(
                width: r.s(40),
                height: r.s(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                ),
                child: Obx(() => Icon(
                    isSearching.value
                        ? Icons.close_rounded
                        : Icons.arrow_back_ios_new_rounded,
                    size: r.s(16),
                    color: Colors.black)),
              ),
            ),
          ),
        ),
        title: Obx(() {
          if (isSearching.value) {
            return TextField(
              controller: searchController,
              autofocus: true,
              onChanged: (v) => searchQuery.value = v,
              style: TextStyle(fontSize: r.fs(15), color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Rechercher un produit...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: r.fs(14)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            );
          }
          return Text(seller.shopName,
              style: TextStyle(
                  fontSize: r.fs(16),
                  fontWeight: FontWeight.w700,
                  color: Colors.black));
        }),
        centerTitle: true,
        actions: [
          Obx(() => isSearching.value
              ? const SizedBox()
              : Row(
                  children: [
                    Container(
                      width: r.s(40),
                      height: r.s(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.black.withOpacity(0.05)),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.search_rounded,
                            size: r.s(20), color: Colors.black),
                        onPressed: () => isSearching.value = true,
                      ),
                    ),
                    SizedBox(width: r.s(8)),
                    Padding(
                      padding: EdgeInsets.only(right: r.s(16)),
                      child: Container(
                        width: r.s(40),
                        height: r.s(40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.black.withOpacity(0.05)),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.ios_share,
                              size: r.s(20), color: Colors.black),
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ],
                )),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Orange Banner ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  height: r.s(120),
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: seller.coverUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppTheme.primary,
                            Color(0xFFFF7E4D),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Seller Card Floating
                Positioned(
                  top: r.s(40),
                  left: r.s(16),
                  right: r.s(16),
                  child: Container(
                    padding: EdgeInsets.all(r.s(20)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(r.rad(32)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Profile Picture (Rounded Square)
                            Container(
                              width: r.s(80),
                              height: r.s(80),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEEEE8),
                                borderRadius: BorderRadius.circular(r.rad(24)),
                                border: Border.all(
                                    color: AppTheme.primary.withOpacity(0.1),
                                    width: 2),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(r.rad(22)),
                                child: CachedNetworkImage(
                                  imageUrl: seller.avatar,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: r.s(16)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(seller.shopName,
                                      style: TextStyle(
                                          fontSize: r.fs(20),
                                          fontWeight: FontWeight.w800,
                                          color: Colors.black)),
                                  Text(seller.location.split(',').last.trim(),
                                      style: TextStyle(
                                          fontSize: r.fs(18),
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black)),
                                  SizedBox(height: r.s(4)),
                                  Row(children: [
                                    Icon(Icons.star,
                                        size: r.s(16), color: AppTheme.primary),
                                    SizedBox(width: r.s(4)),
                                    Text('${seller.rating}',
                                        style: TextStyle(
                                            fontSize: r.fs(14),
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.primary)),
                                    Text(' (124 avis)',
                                        style: TextStyle(
                                            fontSize: r.fs(13),
                                            color: const Color(0xFF9E8E87))),
                                  ]),
                                  SizedBox(height: r.s(2)),
                                  Row(children: [
                                    Icon(Icons.location_on,
                                        size: r.s(14),
                                        color: const Color(0xFF9E8E87)),
                                    SizedBox(width: r.s(4)),
                                    Flexible(
                                      child: Text('Grand Marché, Lomé, Togo',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: r.fs(12),
                                              color: const Color(0xFF9E8E87))),
                                    ),
                                  ]),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: r.s(20)),
                        // Action Button
                        GestureDetector(
                          onTap: () => Get.toNamed('/chat/${seller.id}',
                              arguments: seller),
                          child: Container(
                            height: r.s(54),
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(r.rad(16)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_rounded,
                                    color: Colors.white, size: r.s(18)),
                                SizedBox(width: r.s(10)),
                                Text('Discuter avec le vendeur',
                                    style: TextStyle(
                                        fontSize: r.fs(14),
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Spacer for floating card
          SliverToBoxAdapter(child: SizedBox(height: r.s(160))),

          // ── Stats Row ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: r.s(16)),
              child: Row(
                children: [
                  _StatBox(label: 'Ventes', value: '1.2k', r: r),
                  SizedBox(width: r.s(12)),
                  _StatBox(label: 'Réponse', value: '< 1h', r: r),
                  SizedBox(width: r.s(12)),
                  _StatBox(
                      label: 'Actif', value: 'Maintenant', r: r, isBold: true),
                ],
              ),
            ),
          ),

          // ── Articles Section Header ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(r.s(16), r.s(24), r.s(16), r.s(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() {
                    final filteredProducts = mockProducts
                        .where((p) =>
                            p.sellerId == id &&
                            (selectedCategory.value == 'all' ||
                                p.category == selectedCategory.value) &&
                            (selectedCondition.value == 'all' ||
                                p.condition == selectedCondition.value) &&
                            (p.price >= minPrice.value &&
                                p.price <= maxPrice.value) &&
                            (searchQuery.value.isEmpty ||
                                p.title
                                    .toLowerCase()
                                    .contains(searchQuery.value.toLowerCase())))
                        .toList();
                    return Text('Articles (${filteredProducts.length})',
                        style: TextStyle(
                            fontSize: r.fs(15),
                            fontWeight: FontWeight.w800,
                            color: Colors.black));
                  }),
                  GestureDetector(
                    onTap: () => _showFilterSheet(context, r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: r.s(16), vertical: r.s(8)),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEEEE8),
                        borderRadius: BorderRadius.circular(r.rad(20)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.tune_rounded,
                              size: r.s(12), color: AppTheme.primary),
                          SizedBox(width: r.s(6)),
                          Text('Filtrer',
                              style: TextStyle(
                                  fontSize: r.fs(12),
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Grid ───────────────────────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.fromLTRB(r.s(16), 0, r.s(16), r.s(40)),
            sliver: Obx(() {
              var filteredProducts = mockProducts
                  .where((p) =>
                      p.sellerId == id &&
                      (selectedCategory.value == 'all' ||
                          p.category == selectedCategory.value) &&
                      (selectedCondition.value == 'all' ||
                          p.condition == selectedCondition.value) &&
                      (p.price >= minPrice.value &&
                          p.price <= maxPrice.value) &&
                      (searchQuery.value.isEmpty ||
                          p.title
                              .toLowerCase()
                              .contains(searchQuery.value.toLowerCase())))
                  .toList();

              // Sorting logic
              if (selectedSort.value == 'price_asc') {
                filteredProducts.sort((a, b) => a.price.compareTo(b.price));
              } else if (selectedSort.value == 'price_desc') {
                filteredProducts.sort((a, b) => b.price.compareTo(a.price));
              } else {
                // Newest (using ID as proxy or just keeping default if mock data has no date)
                filteredProducts.sort((a, b) => b.id.compareTo(a.id));
              }

              if (filteredProducts.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                      child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: r.s(48), color: Colors.grey.withOpacity(0.5)),
                        SizedBox(height: r.s(12)),
                        Text(
                          searchQuery.value.isNotEmpty
                              ? 'Aucun produit ne correspond à "${searchQuery.value}"'
                              : 'Aucun produit dans cette catégorie',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: Colors.grey, fontSize: r.fs(12)),
                        ),
                      ],
                    ),
                  )),
                );
              }

              return SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: r.s(16),
                  crossAxisSpacing: r.s(12),
                  childAspectRatio: 0.88,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, i) =>
                      SellerProductCard(product: filteredProducts[i], r: r),
                  childCount: filteredProducts.length,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final R r;
  final bool isBold;
  const _StatBox(
      {required this.label,
      required this.value,
      required this.r,
      this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: r.s(16)),
        decoration: BoxDecoration(
          color: const Color(0xFFFDFDFD),
          borderRadius: BorderRadius.circular(r.rad(20)),
          border: Border.all(color: Colors.black.withOpacity(0.03)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: r.fs(12),
                    color: const Color(0xFF9E8E87),
                    fontWeight: FontWeight.w600)),
            SizedBox(height: r.s(4)),
            Text(value,
                style: TextStyle(
                    fontSize: r.fs(14),
                    fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
                    color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
