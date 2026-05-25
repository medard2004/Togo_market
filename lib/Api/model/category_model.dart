class Category {
  final int id;
  final String name;
  final String slug;
  final String? icon;
  final String? image;
  final int sortOrder;
  final bool isActive;
  final int? parentId;
  final List<Category> children;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
    this.image,
    this.sortOrder = 0,
    this.isActive = true,
    this.parentId,
    List<Category>? children,
  }) : children = children ?? [];

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      icon: json['icon'],
      image: json['image'],
      sortOrder: json['sort_order'] ?? 0,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      parentId: json['parent_id'],
      children: json['children'] != null
          ? (json['children'] as List).map((i) => Category.fromJson(i)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'icon': icon,
      'image': image,
      'sort_order': sortOrder,
      'is_active': isActive,
      'parent_id': parentId,
      'children': children.map((i) => i.toJson()).toList(),
    };
  }
}
