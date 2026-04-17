import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../controllers/app_controller.dart';
import '../../utils/responsive.dart';

class TrendingExplorerScreen extends StatefulWidget {
  const TrendingExplorerScreen({super.key});

  @override
  State<TrendingExplorerScreen> createState() => _TrendingExplorerScreenState();
}

class _TrendingExplorerScreenState extends State<TrendingExplorerScreen> {
  String _selectedFilter = 'Tout';
  final List<String> _filters = ['Tout', 'Vêtements', 'Électronique', 'Friperie'];

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    final ctrl = Get.find<AppController>();
    final allProducts = ctrl.products.toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBodyBehindAppBar: true,
      appBar: _ExplorerAppBar(
        title: '🔥 Tendances',
        onBack: () => Get.back(),
      ),
      body: AnimationLimiter(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Safe area + AppBar spacing
            SliverToBoxAdapter(child: SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight + 10)),

            // ── Filters & Subtitle ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Découvrez ce qui fait fureur à Lomé en ce moment.',
                      style: TextStyle(
                        fontSize: r.fs(13),
                        color: AppTheme.mutedForeground,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filters.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          final f = _filters[i];
                          final active = _selectedFilter == f;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedFilter = f),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 18),
                              decoration: BoxDecoration(
                                color: active ? Colors.orange : AppTheme.cardColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: active ? AppTheme.shadowPrimary : AppTheme.shadowCard,
                              ),
                              child: Center(
                                child: Text(
                                  f,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: active ? Colors.white : AppTheme.mutedForeground,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // ── Product Grid ────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: _gridAspectRatio(context),
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final product = allProducts[i % allProducts.length];
                    return AnimationConfiguration.staggeredGrid(
                      position: i,
                      duration: const Duration(milliseconds: 375),
                      columnCount: 2,
                      child: ScaleAnimation(
                        child: FadeInAnimation(
                          child: Stack(
                            children: [
                              ProductCard(product: product),
                              // Popularity Badge (Subtle)
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.bolt_rounded, size: 10, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _gridAspectRatio(BuildContext context) {
    final r = R(context);
    final colW = (MediaQuery.of(context).size.width - 16 * 2 - 12) / 2;
    final imgH = colW * (3 / 4);
    final infoH = r.s(56);
    return colW / (imgH + infoH);
  }
}

class _ExplorerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onBack;

  const _ExplorerAppBar({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AppBar(
          backgroundColor: Colors.white.withOpacity(0.85),
          elevation: 0,
          leadingWidth: 60,
          leading: Center(
            child: AppBackButton(onTap: onBack),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: AppTheme.foreground,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          centerTitle: true,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
