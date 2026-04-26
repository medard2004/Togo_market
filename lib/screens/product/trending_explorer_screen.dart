import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../utils/responsive.dart';
import '../../Api/services/produit_service.dart';
import '../../models/models.dart';

class TrendingExplorerScreen extends StatefulWidget {
  const TrendingExplorerScreen({super.key});

  @override
  State<TrendingExplorerScreen> createState() => _TrendingExplorerScreenState();
}

class _TrendingExplorerScreenState extends State<TrendingExplorerScreen> {
  String _selectedFilter = 'Tout';
  final List<String> _filters = ['Tout', 'Vêtements', 'Électronique', 'Friperie'];

  final ScrollController _scroll = ScrollController();

  final List<Product> _items = [];
  bool _firstLoad = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _nextPage = 1;
  String? _error;
  bool _requestBusy = false;

  static const int _perPage = 20;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPage(1, reset: true));
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients || _loadingMore || !_hasMore || _requestBusy) return;
    if (_items.isEmpty) return;
    final pos = _scroll.position;
    if (pos.pixels >= pos.maxScrollExtent - 480) {
      _loadPage(_nextPage, reset: false);
    }
  }

  Future<void> _loadPage(int page, {required bool reset}) async {
    if (_requestBusy) return;
    if (!reset && (!_hasMore || page < 1 || _loadingMore)) return;

    _requestBusy = true;

    setState(() {
      _error = null;
      if (reset) {
        _firstLoad = true;
      } else {
        _loadingMore = true;
      }
    });

    try {
      final res = await ProduitService.to.getTrendingProductsPage(
        page: page,
        perPage: _perPage,
      );

      if (!mounted) return;

      setState(() {
        if (reset) {
          _items
            ..clear()
            ..addAll(res.items);
        } else {
          final existing = _items.map((p) => p.id).toSet();
          for (final p in res.items) {
            if (!existing.contains(p.id)) {
              _items.add(p);
              existing.add(p.id);
            }
          }
        }
        _hasMore = res.hasMore;
        _nextPage = res.nextPage ?? page;
        _firstLoad = false;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _firstLoad = false;
        _loadingMore = false;
        if (reset) {
          _items.clear();
          _hasMore = false;
        }
      });
    } finally {
      _requestBusy = false;
    }
  }

  Future<void> _onRefresh() async {
    await _loadPage(1, reset: true);
  }

  List<Product> get _visibleItems {
    if (_selectedFilter == 'Tout') return _items;
    // Filtres démo : correspondance approximative sur le libellé de catégorie
    return _items.where((p) {
      final name = p.categoryObj?.nom ?? '';
      return name.toLowerCase().contains(_selectedFilter.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    final visible = _visibleItems;

    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBodyBehindAppBar: true,
      appBar: _ExplorerAppBar(
        title: '🔥 Tendances',
        onBack: () => Get.back(),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            color: Colors.orange,
            displacement: 40,
            onRefresh: _onRefresh,
            child: AnimationLimiter(
              child: CustomScrollView(
                controller: _scroll,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.of(context).padding.top + kToolbarHeight + 10,
                    ),
                  ),
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
                  if (_error != null && _items.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(
                              'Impossible de charger les tendances.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppTheme.mutedForeground, fontSize: r.fs(14)),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () => _loadPage(1, reset: true),
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (visible.isEmpty && !_firstLoad && _error == null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            _selectedFilter == 'Tout'
                                ? 'Aucun produit pour le moment.'
                                : 'Aucun produit dans cette catégorie.',
                            style: TextStyle(color: AppTheme.mutedForeground, fontSize: r.fs(14)),
                          ),
                        ),
                      ),
                    ),
                  if (visible.isNotEmpty)
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
                            final product = visible[i];
                            return AnimationConfiguration.staggeredGrid(
                              position: i,
                              duration: const Duration(milliseconds: 375),
                              columnCount: 2,
                              child: ScaleAnimation(
                                child: FadeInAnimation(
                                  child: Stack(
                                    children: [
                                      ProductCard(product: product),
                                      Positioned(
                                        top: 8,
                                        left: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withValues(alpha: 0.9),
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
                          childCount: visible.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_firstLoad && _items.isEmpty)
            const LinearProgressIndicator(
              minHeight: 2,
              color: Colors.orange,
              backgroundColor: Colors.transparent,
            ),
        ],
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
          backgroundColor: Colors.white.withValues(alpha: 0.85),
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
