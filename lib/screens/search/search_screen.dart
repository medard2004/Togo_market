import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/bottom_nav.dart';
import '../../controllers/app_controller.dart';
import '../../utils/category_icon_helper.dart';
import '../../utils/responsive.dart';
import '../../Api/config/api_constants.dart';
import '../../Api/model/boutique_model.dart';

import '../../controllers/search_history_controller.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  String _query = '';

  // 0 = Produits, 1 = Boutiques
  int _activeTab = 0;

  @override
  void initState() {
    super.initState();
    _focus.requestFocus();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submitSearch(String term) {
    if (term.trim().isNotEmpty) {
      SearchHistoryController.to.addSearch(term);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appCtrl = Get.find<AppController>();
    final productResults =
        _query.isEmpty ? [] : appCtrl.searchProducts(_query);
    final boutiqueResults =
        _query.isEmpty ? <Boutique>[] : appCtrl.searchBoutiques(_query);

    final totalResults = productResults.length + boutiqueResults.length;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Get.offAllNamed('/home');
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    AppBackButton(onTap: () => Get.offAllNamed('/home')),
                    SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppTheme.shadowCard,
                        ),
                        child: TextField(
                          controller: _ctrl,
                          focusNode: _focus,
                          decoration: InputDecoration(
                            hintText: 'Produits, boutiques...',
                            prefixIcon: Icon(Icons.search,
                                color: AppTheme.mutedForeground, size: 20),
                            suffixIcon: _query.isNotEmpty
                                ? GestureDetector(
                                    onTap: () {
                                      _ctrl.clear();
                                      setState(() => _query = '');
                                    },
                                    child: Icon(Icons.close,
                                        color: AppTheme.mutedForeground,
                                        size: 18),
                                  )
                                : null,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 14),
                            fillColor: Colors.transparent,
                            filled: false,
                          ),
                          onChanged: (v) => setState(() => _query = v),
                          onSubmitted: (v) {
                            _submitSearch(v);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Tab bar (only shown when there are results)
              if (_query.isNotEmpty && totalResults > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _SearchTabBar(
                    activeTab: _activeTab,
                    productCount: productResults.length,
                    boutiqueCount: boutiqueResults.length,
                    onTabChanged: (tab) => setState(() => _activeTab = tab),
                  ),
                ),

              // Content
              Expanded(
                child: _query.isEmpty
                    ? _EmptyQueryContent(
                        onSearch: (s) {
                          _ctrl.text = s;
                          setState(() => _query = s);
                          _submitSearch(s);
                        },
                      )
                    : totalResults == 0
                        ? const _EmptyResults()
                        : _activeTab == 0
                            ? productResults.isEmpty
                                ? _EmptyTabResults(
                                    icon: Icons.shopping_bag_outlined,
                                    label: 'Aucun produit trouvé',
                                    suggestion:
                                        'Essayez l\'onglet Boutiques',
                                    onAction: () =>
                                        setState(() => _activeTab = 1),
                                  )
                                : _ResultsList(
                                    results: productResults,
                                    count: productResults.length)
                            : boutiqueResults.isEmpty
                                ? _EmptyTabResults(
                                    icon: Icons.storefront_outlined,
                                    label: 'Aucune boutique trouvée',
                                    suggestion:
                                        'Essayez l\'onglet Produits',
                                    onAction: () =>
                                        setState(() => _activeTab = 0),
                                  )
                                : _BoutiqueResultsList(
                                    boutiques: boutiqueResults,
                                    count: boutiqueResults.length),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      ),
    );
  }
}

// ── Tab Bar ──────────────────────────────────────────────────────────────────────
class _SearchTabBar extends StatelessWidget {
  final int activeTab;
  final int productCount;
  final int boutiqueCount;
  final ValueChanged<int> onTabChanged;

  const _SearchTabBar({
    required this.activeTab,
    required this.productCount,
    required this.boutiqueCount,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    return Container(
      height: r.s(44),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          _buildTab(r, 0, Icons.shopping_bag_outlined, 'Produits',
              productCount),
          const SizedBox(width: 4),
          _buildTab(
              r, 1, Icons.storefront_outlined, 'Boutiques', boutiqueCount),
        ],
      ),
    );
  }

  Widget _buildTab(R r, int index, IconData icon, String label, int count) {
    final isActive = activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChanged(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive ? AppTheme.shadowPrimary : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: r.s(16),
                  color: isActive ? Colors.white : AppTheme.mutedForeground),
              SizedBox(width: r.s(6)),
              Text(
                label,
                style: TextStyle(
                  fontSize: r.fs(12),
                  fontWeight: FontWeight.w700,
                  color: isActive ? Colors.white : AppTheme.mutedForeground,
                ),
              ),
              if (count > 0) ...[
                SizedBox(width: r.s(4)),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: r.s(6), vertical: r.s(2)),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white.withOpacity(0.25)
                        : AppTheme.muted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: r.fs(10),
                      fontWeight: FontWeight.w800,
                      color:
                          isActive ? Colors.white : AppTheme.mutedForeground,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty query (recent searches + categories) ──────────────────────────────────
class _EmptyQueryContent extends StatelessWidget {
  final Function(String) onSearch;

  const _EmptyQueryContent({required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            final recentSearches = SearchHistoryController.to.searches;
            if (recentSearches.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recherches récentes',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    GestureDetector(
                      onTap: () {
                        SearchHistoryController.to.clearSearches();
                      },
                      child: Text(
                        'Tout effacer',
                        style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: recentSearches
                      .map((sq) => GestureDetector(
                            onTap: () => onSearch(sq.query),
                            child: Container(
                              padding: const EdgeInsets.only(
                                  left: 14, right: 8, top: 8, bottom: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.cardColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.history,
                                      size: 14,
                                      color: AppTheme.mutedForeground),
                                  SizedBox(width: 6),
                                  Text(sq.query,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500)),
                                  SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () => SearchHistoryController.to
                                        .removeSearch(sq),
                                    child: Icon(Icons.close,
                                        size: 16,
                                        color: AppTheme.mutedForeground),
                                  ),
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                ),
                SizedBox(height: 24),
              ],
            );
          }),
          Text(
            'Catégories',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final apiCats = Get.find<AppController>().categories;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.1,
              ),
              itemCount: apiCats.length,
              itemBuilder: (_, i) {
                final cat = apiCats[i];
                return GestureDetector(
                  onTap: () => onSearch(cat.name),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.shadowCard,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                            CategoryIconHelper.getIconFromString(cat.icon),
                            size: 26,
                            color: AppTheme.primary),
                        const SizedBox(height: 4),
                        Text(cat.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.foreground)),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

// ── Empty results (no results at all) ───────────────────────────────────────────
class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_rounded,
              size: 48, color: AppTheme.mutedForeground),
          SizedBox(height: 12),
          Text('Aucun résultat',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.foreground)),
          SizedBox(height: 4),
          Text('Essayez un autre mot-clé',
              style: TextStyle(
                  fontSize: 14, color: AppTheme.mutedForeground)),
        ],
      ),
    );
  }
}

// ── Empty results for a specific tab ────────────────────────────────────────────
class _EmptyTabResults extends StatelessWidget {
  final IconData icon;
  final String label;
  final String suggestion;
  final VoidCallback? onAction;

  const _EmptyTabResults({
    required this.icon,
    required this.label,
    required this.suggestion,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: AppTheme.mutedForeground),
          SizedBox(height: 12),
          Text(label,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.foreground)),
          SizedBox(height: 8),
          if (onAction != null)
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  suggestion,
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
    );
  }
}

// ── Product Results ─────────────────────────────────────────────────────────────
class _ResultsList extends StatelessWidget {
  final List results;
  final int count;

  const _ResultsList({required this.results, required this.count});

  @override
  Widget build(BuildContext context) {
    final r = R(context);
    // Largeur d'une colonne (2 colonnes + 1 gap + 2x padding horizontal)
    final cardW = (r.screenW - 32 - 12) / 2;
    // Hauteur info section (mesurée depuis ProductCard):
    //   padding top r.s(8) + titre 1 ligne + gap r.s(3) + localisation + padding bas r.s(9) + marge
    final infoH = r.s(8) +
        r.fs(12) * 1.3 +
        r.s(3) +
        r.fs(10) * 1.3 +
        r.s(9) +
        r.s(14);
    final cardH = r.cardImageH + infoH;
    final ratio = (cardW / cardH).clamp(0.55, 0.90);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: ratio,
            ),
            itemCount: results.length,
            itemBuilder: (_, i) => ProductCard(product: results[i]),
          ),
        ),
      ],
    );
  }
}

// ── Boutique Results ────────────────────────────────────────────────────────────
class _BoutiqueResultsList extends StatelessWidget {
  final List<Boutique> boutiques;
  final int count;

  const _BoutiqueResultsList(
      {required this.boutiques, required this.count});

  @override
  Widget build(BuildContext context) {
    final r = R(context);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: boutiques.length,
      separatorBuilder: (_, __) => SizedBox(height: r.s(12)),
      itemBuilder: (_, i) {
        final boutique = boutiques[i];
        return _BoutiqueSearchTile(boutique: boutique, r: r);
      },
    );
  }
}

// ── Boutique Search Tile ────────────────────────────────────────────────────────
class _BoutiqueSearchTile extends StatelessWidget {
  final Boutique boutique;
  final R r;

  const _BoutiqueSearchTile({required this.boutique, required this.r});

  @override
  Widget build(BuildContext context) {
    final logoUrl = ApiConstants.resolveImageUrl(boutique.logoUrl);
    final bannerUrl = ApiConstants.resolveImageUrl(boutique.bannerUrl);

    // Catégories textuelles
    final cats = (boutique.categories ?? []).take(3).map((c) {
      return (c is Map ? c['nom']?.toString() : c.toString()) ?? '';
    }).where((s) => s.isNotEmpty).toList();

    return GestureDetector(
      onTap: () => Get.toNamed('/seller/${boutique.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(r.rad(20)),
          boxShadow: AppTheme.shadowCard,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // ── Banner ──────────────────────────────────────────────────
            SizedBox(
              height: r.s(90),
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (bannerUrl.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: bannerUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _bannerFallback(),
                      errorWidget: (_, __, ___) => _bannerFallback(),
                    )
                  else
                    _bannerFallback(),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                        ],
                      ),
                    ),
                  ),
                  // Rating badge
                  if (boutique.noteMoyenne > 0)
                    Positioned(
                      top: r.s(8),
                      right: r.s(8),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: r.s(8), vertical: r.s(4)),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(r.rad(12)),
                          boxShadow: AppTheme.shadowSm,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded,
                                color: Colors.amber, size: r.s(13)),
                            SizedBox(width: r.s(3)),
                            Text(
                              boutique.noteMoyenne.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: r.fs(11),
                                fontWeight: FontWeight.w800,
                                color: AppTheme.foreground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Info section ────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                  r.s(14), r.s(12), r.s(14), r.s(14)),
              child: Row(
                children: [
                  // Logo
                  Container(
                    padding: EdgeInsets.all(r.s(3)),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.border.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: r.s(22),
                      backgroundColor: AppTheme.primaryLight,
                      backgroundImage: logoUrl.isNotEmpty
                          ? CachedNetworkImageProvider(logoUrl)
                          : null,
                      child: logoUrl.isEmpty
                          ? Icon(Icons.storefront,
                              color: AppTheme.primary, size: r.s(22))
                          : null,
                    ),
                  ),
                  SizedBox(width: r.s(12)),
                  // Name + details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          boutique.nom,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: r.fs(14),
                            fontWeight: FontWeight.w800,
                            color: AppTheme.foreground,
                          ),
                        ),
                        SizedBox(height: r.s(3)),
                        Row(
                          children: [
                            Icon(Icons.location_on_rounded,
                                size: r.s(12),
                                color: AppTheme.mutedForeground),
                            SizedBox(width: r.s(3)),
                            Expanded(
                              child: Text(
                                boutique.adresse ?? 'Lomé, Togo',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: r.fs(11),
                                  color: AppTheme.mutedForeground,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (cats.isNotEmpty) ...[
                          SizedBox(height: r.s(6)),
                          Wrap(
                            spacing: r.s(4),
                            runSpacing: r.s(4),
                            children: cats
                                .map(
                                  (c) => Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: r.s(8),
                                        vertical: r.s(3)),
                                    decoration: BoxDecoration(
                                      color:
                                          AppTheme.primary.withOpacity(0.08),
                                      borderRadius:
                                          BorderRadius.circular(r.rad(10)),
                                    ),
                                    child: Text(
                                      c,
                                      style: TextStyle(
                                        fontSize: r.fs(9),
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: r.s(8)),
                  // Visit button
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: r.s(12), vertical: r.s(8)),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(r.rad(12)),
                      boxShadow: AppTheme.shadowPrimary,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.storefront_rounded,
                            size: r.s(14), color: Colors.white),
                        SizedBox(width: r.s(4)),
                        Text(
                          'Visiter',
                          style: TextStyle(
                            fontSize: r.fs(11),
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bannerFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary.withOpacity(0.15),
            AppTheme.secondary.withOpacity(0.08),
          ],
        ),
      ),
      child: Center(
        child: Opacity(
          opacity: 0.12,
          child: const Icon(Icons.storefront_rounded,
              size: 54, color: AppTheme.primary),
        ),
      ),
    );
  }
}
