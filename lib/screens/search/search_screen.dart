import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/bottom_nav.dart';
import '../../controllers/app_controller.dart';
import '../../data/mock_data.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  String _query = '';

  final _recentSearches = ['iPhone 13', 'Robe Ankara', 'Canapé', 'Samsung'];

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

  @override
  Widget build(BuildContext context) {
    final appCtrl = Get.find<AppController>();
    final results = _query.isEmpty ? [] : appCtrl.searchProducts(_query);

    return Scaffold(
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
                  AppBackButton(),
                  const SizedBox(width: 12),
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
                          prefixIcon: const Icon(Icons.search,
                              color: AppTheme.mutedForeground, size: 20),
                          suffixIcon: _query.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _ctrl.clear();
                                    setState(() => _query = '');
                                  },
                                  child: const Icon(Icons.close,
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
                      recentSearches: _recentSearches,
                      onSearch: (s) {
                        _ctrl.text = s;
                        setState(() => _query = s);
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
    );
  }
}

class _EmptyQueryContent extends StatelessWidget {
  final List<String> recentSearches;
  final Function(String) onSearch;

  const _EmptyQueryContent(
      {required this.recentSearches, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recherches récentes',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recentSearches
                .map((s) => GestureDetector(
                      onTap: () => onSearch(s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.history,
                                size: 14, color: AppTheme.mutedForeground),
                            const SizedBox(width: 6),
                            Text(s,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
          const Text(
            'Catégories',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.1,
            ),
            itemCount: mockCategories.length - 1,
            itemBuilder: (_, i) {
              final cat = mockCategories[i + 1];
              return GestureDetector(
                onTap: () => onSearch(cat.label),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.shadowCard,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(cat.emoji,
                          style: const TextStyle(fontSize: 26)),
                      const SizedBox(height: 4),
                      Text(cat.label,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.foreground)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🔍', style: TextStyle(fontSize: 48)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            '$count résultat${count > 1 ? 's' : ''}',
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.mutedForeground),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.65,
            ),
            itemCount: results.length,
            itemBuilder: (_, i) => ProductCard(product: results[i]),
          ),
        ),
      ],
    );
  }
}
