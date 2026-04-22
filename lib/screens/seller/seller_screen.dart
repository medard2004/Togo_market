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
  final RxBool isSearching = false.obs;
  final TextEditingController searchController = TextEditingController();

  void _showFilterSheet(BuildContext context, R r) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(r.s(20)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(r.rad(30))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filtrer par catégorie',
                style: TextStyle(
                    fontSize: r.fs(18),
                    fontWeight: FontWeight.w800,
                    color: Colors.black)),
            SizedBox(height: r.s(16)),
            Wrap(
              spacing: r.s(10),
              runSpacing: r.s(10),
              children: mockCategories.map((cat) {
                return Obx(() {
                  final isSelected = selectedCategory.value == cat.id;
                  return GestureDetector(
                    onTap: () {
                      selectedCategory.value = cat.id;
                      Get.back();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: r.s(16), vertical: r.s(10)),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primary
                            : const Color(0xFFF5F6F8),
                        borderRadius: BorderRadius.circular(r.rad(12)),
                      ),
                      child: Text(
                        cat.label,
                        style: TextStyle(
                          fontSize: r.fs(14),
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                });
              }).toList(),
            ),
            SizedBox(height: r.s(20)),
          ],
        ),
      ),
    );
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
                          onTap: () => Get.toNamed('/chat/c1'),
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
              final filteredProducts = mockProducts
                  .where((p) =>
                      p.sellerId == id &&
                      (selectedCategory.value == 'all' ||
                          p.category == selectedCategory.value) &&
                      (searchQuery.value.isEmpty ||
                          p.title
                              .toLowerCase()
                              .contains(searchQuery.value.toLowerCase())))
                  .toList();

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
                              TextStyle(color: Colors.grey, fontSize: r.fs(14)),
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
                  childAspectRatio: 0.75,
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
                    fontSize: r.fs(18),
                    fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
                    color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
