class Category {
  final int id;
  final String nom;
  final String slug;
  final int? parentId;
  final List<Category> children;

  Category({
    required this.id,
    required this.nom,
    required this.slug,
    this.parentId,
    List<Category>? children,
  }) : children = children ?? [];

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      nom: json['nom'],
      slug: json['slug'] ?? '',
      parentId: json['parent_id'],
      children: json['children'] != null
          ? (json['children'] as List).map((i) => Category.fromJson(i)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'slug': slug,
      'parent_id': parentId,
      'children': children.map((i) => i.toJson()).toList(),
    };
  }
}
