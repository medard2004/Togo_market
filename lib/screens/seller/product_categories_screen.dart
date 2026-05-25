import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../utils/category_icon_helper.dart';
import '../../controllers/app_controller.dart';

class ProductCategoriesScreen extends StatefulWidget {
  const ProductCategoriesScreen({super.key});

  @override
  State<ProductCategoriesScreen> createState() =>
      _ProductCategoriesScreenState();
}

class _ProductCategoriesScreenState extends State<ProductCategoriesScreen> {
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
    // Dans une version complète, on filtrerait les vrais produits de l'API.
    // Ici on garde le mock ou on met 0 si le mock ne correspond pas.
    return mockProducts.where((product) => product.category == id).length;
  }

  @override
  Widget build(BuildContext context) {
    final hasSelected = _selectedCategories.isNotEmpty;
    // On utilise Obx pour réagir aux changements de catégories si nécessaire
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: Get.back,
        ),
        title: Text(
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
            child: Text(
              'Sauvegarder',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        final categories = Get.find<AppController>().categories;
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: categories.length + 1,
          separatorBuilder: (_, __) => SizedBox(height: 14),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildHeader();
            }
            final category = categories[index - 1];
            final count = _countCategory(category.slug);
            return _buildCategoryItem(category, count);
          },
        );
      }),
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
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.category_outlined,
                    color: Colors.white, size: 24),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
        SizedBox(height: 12),
        Text(
          'Chaque catégorie affiche le nombre d’articles déjà publiés.',
          style: TextStyle(
              fontSize: 13, color: AppTheme.mutedForeground, height: 1.5),
        ),
        if (_selectedCategories.isNotEmpty) ...[
          SizedBox(height: 12),
          Text(
            'Catégories sélectionnées : ${_selectedCategories.length}',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ],
    );
  }

  Widget _buildCategoryItem(category, int count) {
    final bool selected = _selectedCategories.contains(category.slug);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _toggleCategory(category.slug),
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
              child: Icon(
                CategoryIconHelper.getIconFromString(category.icon),
                color: selected ? Colors.white : AppTheme.primary, size: 24),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: selected ? AppTheme.primary : Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '$count articles publiés',
                    style: TextStyle(
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
