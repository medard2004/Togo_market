import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../controllers/app_controller.dart';
import '../../utils/responsive.dart';

class NearbyExplorerScreen extends StatefulWidget {
  const NearbyExplorerScreen({super.key});

  @override
  State<NearbyExplorerScreen> createState() => _NearbyExplorerScreenState();
}

class _NearbyExplorerScreenState extends State<NearbyExplorerScreen> {
  String _selectedDistance = '1 km';
  final List<String> _distances = ['500 m', '1 km', '5 km', '10 km'];

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    final ctrl = Get.find<AppController>();
    final allProducts = ctrl.products.toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBodyBehindAppBar: true,
      appBar: _ExplorerAppBar(
        title: 'Près de vous',
        onBack: () => Get.back(),
      ),
      body: AnimationLimiter(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Standard spacing for the extended app bar
            SliverToBoxAdapter(child: SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight + 10)),

            // ── Location & Filters ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: AppTheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Lomé, Tokoin',
                          style: TextStyle(
                            fontSize: r.fs(14),
                            fontWeight: FontWeight.w700,
                            color: AppTheme.foreground,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.mutedForeground, size: 18),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _distances.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          final dist = _distances[i];
                          final active = _selectedDistance == dist;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedDistance = dist),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: active ? AppTheme.primary : AppTheme.cardColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: active ? AppTheme.shadowPrimary : AppTheme.shadowCard,
                              ),
                              child: Center(
                                child: Text(
                                  dist,
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
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: Stack(
                            children: [
                              ProductCard(product: product),
                              // Distance Badge
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: AppTheme.shadowCard,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.directions_walk_rounded, size: 10, color: AppTheme.primary),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${(i + 1) * 0.3} km',
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: 10,
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
