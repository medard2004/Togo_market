import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../utils/responsive.dart';
import '../../data/mock_data.dart';

class TrendingShopsScreen extends StatefulWidget {
  const TrendingShopsScreen({super.key});

  @override
  State<TrendingShopsScreen> createState() => _TrendingShopsScreenState();
}

class _TrendingShopsScreenState extends State<TrendingShopsScreen> {
  String _selectedFilter = 'Tout';
  final List<String> _filters = ['Tout', 'Friperie', 'Mode', 'Électronique', 'Services'];

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    final trendingSellers = mockSellers.where((s) => s.rating >= 4.5).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBodyBehindAppBar: true,
      appBar: _ExplorerAppBar(
        title: '🔥 Boutiques Tendances',
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
                    Text(
                      'Les boutiques les plus populaires et les mieux notées de la semaine.',
                      style: TextStyle(
                        fontSize: r.fs(13),
                        color: AppTheme.mutedForeground,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      height: r.s(38),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filters.length,
                        separatorBuilder: (_, __) => SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          final f = _filters[i];
                          final active = _selectedFilter == f;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedFilter = f),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 18),
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
                                  f,
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
                    final seller = trendingSellers[i % trendingSellers.length];
                    return AnimationConfiguration.staggeredGrid(
                      position: i,
                      duration: const Duration(milliseconds: 450),
                      columnCount: 2,
                      child: ScaleAnimation(
                        child: FadeInAnimation(
                          child: ShopCarouselCard(seller: seller),
                        ),
                      ),
                    );
                  },
                  childCount: trendingSellers.length,
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
