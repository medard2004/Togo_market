import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/bottom_nav.dart';
import '../../controllers/app_controller.dart';
import '../../utils/category_icon_helper.dart';
import '../../utils/responsive.dart';

import '../../controllers/search_history_controller.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  String _query = '';

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
    final results = _query.isEmpty ? [] : appCtrl.searchProducts(_query);

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
                          hintText: 'Que cherchez-vous ?',
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
                  : results.isEmpty
                      ? const _EmptyResults()
                      : _ResultsList(results: results, count: results.length),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    ));
  }
}

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
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    GestureDetector(
                      onTap: () {
                        SearchHistoryController.to.clearSearches();
                      },
                      child: Text(
                        'Tout effacer',
                        style: TextStyle(fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.w600),
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
                              padding: const EdgeInsets.only(left: 14, right: 8, top: 8, bottom: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.cardColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.history,
                                      size: 14, color: AppTheme.mutedForeground),
                                  SizedBox(width: 6),
                                  Text(sq.query,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500)),
                                  SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () => SearchHistoryController.to.removeSearch(sq),
                                    child: Icon(Icons.close, size: 16, color: AppTheme.mutedForeground),
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
                        Icon(CategoryIconHelper.getIconFromString(cat.icon),
                            size: 26, color: AppTheme.primary),
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
    final infoH = r.s(8) + r.fs(12) * 1.3 + r.s(3) + r.fs(10) * 1.3 + r.s(9) + r.s(14);
    final cardH = r.cardImageH + infoH;
    final ratio = (cardW / cardH).clamp(0.55, 0.90);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            '$count résultat${count > 1 ? 's' : ''}',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.mutedForeground),
          ),
        ),
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
