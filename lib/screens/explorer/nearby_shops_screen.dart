import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../utils/responsive.dart';
import '../../data/mock_data.dart';

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
    final nearbySellers = mockSellers.toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBodyBehindAppBar: true,
      appBar: _ExplorerAppBar(
        title: 'Boutiques Proches',
        onBack: () => Get.back(),
      ),
      body: AnimationLimiter(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: MediaQuery.of(context).padding.top + r.s(60))),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, color: AppTheme.primary, size: r.s(20)),
                        SizedBox(width: 8),
                        Text(
                          'Lomé, Tokoin',
                          style: TextStyle(
                            fontSize: r.fs(14),
                            fontWeight: FontWeight.w700,
                            color: AppTheme.foreground,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.mutedForeground, size: r.s(18)),
                      ],
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      height: r.s(38),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _distances.length,
                        separatorBuilder: (_, __) => SizedBox(width: 10),
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
                                border: Border.all(
                                  color: active ? AppTheme.primary : AppTheme.border,
                                  width: 1.5,
                                ),
                                boxShadow: active ? AppTheme.shadowPrimary : AppTheme.shadowSm,
                              ),
                              child: Center(
                                child: Text(
                                  dist,
                                  style: TextStyle(
                                    fontSize: r.fs(12),
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
                    SizedBox(height: r.s(22)),
                  ],
                ),
              ),
            ),

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
                    final seller = nearbySellers[i % nearbySellers.length];
                    return AnimationConfiguration.staggeredGrid(
                      position: i,
                      duration: const Duration(milliseconds: 450),
                      columnCount: 2,
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: ShopCarouselCard(seller: seller),
                        ),
                      ),
                    );
                  },
                  childCount: nearbySellers.length,
                ),
              ),
            ),
          ],
        ),
      ),
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
