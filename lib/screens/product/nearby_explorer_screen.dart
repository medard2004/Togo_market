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
    final nearbyProds = ctrl.nearbyProducts.toList();
    final zone = ctrl.selectedZone.value ?? 'Autour de vous';

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
            SliverToBoxAdapter(
                child: SizedBox(
                    height: MediaQuery.of(context).padding.top +
                        kToolbarHeight +
                        10)),

            // ── Location & Filters ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            color: AppTheme.primary, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            zone,
                            style: TextStyle(
                              fontSize: r.fs(14),
                              fontWeight: FontWeight.w700,
                              color: AppTheme.foreground,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
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
                    final product = nearbyProds[i];
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
                              // Removed Distance Badge
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: nearbyProds.length,
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
          backgroundColor: AppTheme.cardColor.withOpacity(0.85),
          elevation: 0,
          leadingWidth: 60,
          leading: Center(
            child: AppBackButton(onTap: onBack),
          ),
          title: Text(
            title,
            style: TextStyle(
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
