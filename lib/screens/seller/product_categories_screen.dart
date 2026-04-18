import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';

class ProductCategoriesScreen extends StatefulWidget {
  const ProductCategoriesScreen({super.key});

  @override
  State<ProductCategoriesScreen> createState() =>
      _ProductCategoriesScreenState();
}

class _ProductCategoriesScreenState extends State<ProductCategoriesScreen> {
  final List<_CategoryRow> _categories = [
    _CategoryRow(
        id: 'electronique', label: 'Électronique', icon: Icons.devices),
    _CategoryRow(id: 'mode', label: 'Mode & Vêtements', icon: Icons.checkroom),
    _CategoryRow(id: 'maison', label: 'Maison & Déco', icon: Icons.home),
    _CategoryRow(
        id: 'beaute', label: 'Beauté & Santé', icon: Icons.health_and_safety),
    _CategoryRow(id: 'auto', label: 'Auto & Moto', icon: Icons.directions_car),
    _CategoryRow(
        id: 'alimentation',
        label: 'Alimentation',
        icon: Icons.local_grocery_store),
    _CategoryRow(
        id: 'sports', label: 'Sports & Loisirs', icon: Icons.sports_basketball),
    _CategoryRow(id: 'livres', label: 'Livres & Éducation', icon: Icons.book),
    _CategoryRow(
        id: 'enfants', label: 'Enfants & Bébés', icon: Icons.child_care),
    _CategoryRow(id: 'services', label: 'Services', icon: Icons.build),
  ];

  final Set<String> _selectedCategories = {};

  void _toggleCategory(String id) {
    setState(() {
      if (_selectedCategories.contains(id)) {
        _selectedCategories.remove(id);
      } else {
        _selectedCategories.add(id);
      }
    });
  }

  int _countCategory(String id) {
    return mockProducts.where((product) => product.category == id).length;
  }

  @override
  Widget build(BuildContext context) {
    final hasSelected = _selectedCategories.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: Get.back,
        ),
        title: const Text(
          'Catégories de produits',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: hasSelected ? Get.back : null,
            style: TextButton.styleFrom(
              foregroundColor:
                  hasSelected ? AppTheme.primary : AppTheme.mutedForeground,
            ),
            child: const Text(
              'Sauvegarder',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: _categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildHeader();
          }
          final category = _categories[index - 1];
          final count = _countCategory(category.id);
          return _buildCategoryItem(category, count);
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight.withOpacity(0.18),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.category_outlined,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Choisissez les catégories correspondant à vos produits.',
                      style: TextStyle(fontSize: 14, height: 1.6),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Sélectionnez la ou les catégories qui décrivent le mieux vos articles.',
                      style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.mutedForeground,
                          height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Chaque catégorie affiche le nombre d’articles déjà publiés.',
          style: TextStyle(
              fontSize: 13, color: AppTheme.mutedForeground, height: 1.5),
        ),
        if (_selectedCategories.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Catégories sélectionnées : ${_selectedCategories.length}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ],
    );
  }

  Widget _buildCategoryItem(_CategoryRow category, int count) {
    final bool selected = _selectedCategories.contains(category.id);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _toggleCategory(category.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color:
              selected ? AppTheme.primaryLight.withOpacity(0.25) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border:
              Border.all(color: selected ? AppTheme.primary : AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected ? AppTheme.primary : AppTheme.cardColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(category.icon,
                  color: selected ? Colors.white : AppTheme.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: selected ? AppTheme.primary : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$count articles publiés',
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.mutedForeground),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: selected ? AppTheme.primary : AppTheme.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow {
  final String id;
  final String label;
  final IconData icon;

  const _CategoryRow({
    required this.id,
    required this.label,
    required this.icon,
  });
}
