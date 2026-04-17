import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Api/model/category_model.dart';
import '../theme/app_theme.dart';
import '../utils/category_icon_helper.dart';

class CategoryPickerBottomSheet extends StatelessWidget {
  final List<Category> categories;
  final Function(Category) onCategorySelected;
  
  const CategoryPickerBottomSheet({
    super.key,
    required this.categories,
    required this.onCategorySelected,
  });

  static void show(BuildContext context, {
    required List<Category> categories,
    required Function(Category) onCategorySelected,
  }) {
    Get.bottomSheet(
      CategoryPickerBottomSheet(
        categories: categories,
        onCategorySelected: (cat) {
          Get.back(); // close bottom sheet
          onCategorySelected(cat);
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _CategoryList(
      categories: categories,
      onCategorySelected: onCategorySelected,
      level: 0,
    );
  }
}

class _CategoryList extends StatefulWidget {
  final List<Category> categories;
  final Function(Category) onCategorySelected;
  final int level;
  final Category? parent;

  const _CategoryList({
    required this.categories,
    required this.onCategorySelected,
    required this.level,
    this.parent,
  });

  @override
  State<_CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<_CategoryList> {
  final List<Category> _breadcrumbs = [];

  List<Category> get _currentCategories {
    if (_breadcrumbs.isEmpty) return widget.categories;
    return _breadcrumbs.last.children;
  }

  @override
  Widget build(BuildContext context) {
    final currentLevel = _breadcrumbs.length;
    final parent = _breadcrumbs.isEmpty ? null : _breadcrumbs.last;
    final cats = _currentCategories;

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: AppTheme.border,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (currentLevel > 0)
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppTheme.foreground),
                    onPressed: () {
                      setState(() {
                        _breadcrumbs.removeLast();
                      });
                    },
                  )
                else
                  const SizedBox(width: 48), // Padding equivalent to icon button
                Expanded(
                  child: Text(
                    parent != null 
                        ? parent.nom 
                        : 'Choisissez une catégorie',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.foreground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48), // balance back button
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: cats.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final cat = cats[i];
                final hasChildren = cat.children.isNotEmpty;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CategoryIconHelper.getIcon(cat.slug),
                      color: AppTheme.primary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    cat.nom,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.foreground,
                    ),
                  ),
                  trailing: hasChildren 
                      ? const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.mutedForeground)
                      : null,
                  onTap: () {
                    if (hasChildren) {
                      setState(() {
                        _breadcrumbs.add(cat);
                      });
                    } else {
                      widget.onCategorySelected(cat);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

