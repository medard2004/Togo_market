import '../Api/model/category_model.dart';

/// Extrait les IDs de catégories associées à une boutique (payload API `categories`).
Set<int> parseBoutiqueCategoryIds(List<dynamic>? raw) {
  if (raw == null || raw.isEmpty) return {};
  final out = <int>{};
  for (final e in raw) {
    if (e is Map) {
      final id = e['id'];
      if (id != null) {
        final v = id is int ? id : int.tryParse(id.toString());
        if (v != null && v > 0) out.add(v);
      }
    } else if (e is int && e > 0) {
      out.add(e);
    }
  }
  return out;
}

/// Liste plate (profondeur d'abord) pour résoudre les ancêtres via [Category.parentId].
List<Category> flattenCategoryTree(List<Category> roots) {
  final flat = <Category>[];
  void walk(List<Category> list) {
    for (final c in list) {
      flat.add(c);
      if (c.children.isNotEmpty) walk(c.children);
    }
  }
  walk(roots);
  return flat;
}

/// Règle B : la catégorie du produit est autorisée si elle est dans [boutiqueCategoryIds]
/// ou si l'un de ses ancêtres (via [parentId] dans [flatCategories]) est dans l'ensemble.
bool isProductCategoryAllowedForBoutique(
  int categoryId,
  Set<int> boutiqueCategoryIds,
  List<Category> flatCategories,
) {
  if (boutiqueCategoryIds.isEmpty) return false;

  final byId = {for (final c in flatCategories) c.id: c};
  int? current = categoryId;
  final visited = <int>{};
  while (current != null) {
    if (visited.contains(current)) break;
    visited.add(current);
    if (boutiqueCategoryIds.contains(current)) return true;
    final node = byId[current];
    current = node?.parentId;
  }
  return false;
}

/// Ne garde que les branches menant à une feuille autorisée (règle B sur les feuilles).
List<Category> filterCategoryTreeForBoutiqueProducts(
  List<Category> fullRoots,
  Set<int> boutiqueCategoryIds,
) {
  if (boutiqueCategoryIds.isEmpty) return [];
  final flat = flattenCategoryTree(fullRoots);

  Category? prune(Category node) {
    if (node.children.isEmpty) {
      return isProductCategoryAllowedForBoutique(node.id, boutiqueCategoryIds, flat)
          ? node
          : null;
    }
    final prunedChildren = <Category>[];
    for (final child in node.children) {
      final p = prune(child);
      if (p != null) prunedChildren.add(p);
    }
    if (prunedChildren.isEmpty) return null;
    return Category(
      id: node.id,
      nom: node.nom,
      slug: node.slug,
      parentId: node.parentId,
      children: prunedChildren,
    );
  }

  final out = <Category>[];
  for (final root in fullRoots) {
    final p = prune(root);
    if (p != null) out.add(p);
  }
  return out;
}
