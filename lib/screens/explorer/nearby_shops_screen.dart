import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../utils/responsive.dart';
import '../../controllers/app_controller.dart';

class NearbyShopsScreen extends StatefulWidget {
  const NearbyShopsScreen({super.key});

  @override
  State<NearbyShopsScreen> createState() => _NearbyShopsScreenState();
}

class _NearbyShopsScreenState extends State<NearbyShopsScreen> {
  String _selectedDistance = '1 km';
  final List<String> _distances = ['500 m', '1 km', '5 km', '10 km'];

  @override
  Widget build(BuildContext context) {
    final r = R(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBodyBehindAppBar: true,
      appBar: _ExplorerAppBar(
        title: 'Boutiques Proches',
        onBack: () => Get.back(),
      ),
      body: Obx(() {
        final ctrl = Get.find<AppController>();
        final boutiques = ctrl.nearbyBoutiques.toList();
        final zone = ctrl.selectedZone.value ?? 'Autour de vous';

        return AnimationLimiter(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                  child: SizedBox(
                      height: MediaQuery.of(context).padding.top + r.s(60))),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              color: AppTheme.primary, size: r.s(20)),
                          const SizedBox(width: 8),
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
                      SizedBox(height: r.s(22)),
                    ],
                  ),
                ),
              ),
              if (boutiques.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Aucune boutique disponible',
                      style: TextStyle(
                          color: AppTheme.mutedForeground,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final boutique = boutiques[i];
                        return AnimationConfiguration.staggeredGrid(
                          position: i,
                          duration: const Duration(milliseconds: 450),
                          columnCount: 2,
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: ShopCarouselCard(boutique: boutique),
                            ),
                          ),
                        );
                      },
                      childCount: boutiques.length,
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
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
