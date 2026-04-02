class Category {
  final int id;
  final String nom;
  final String? emoji;
  final int? parentId;

  Category({
    required this.id,
    required this.nom,
    this.emoji,
    this.parentId,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      nom: json['nom'],
      emoji: json['emoji'],
      parentId: json['parent_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'emoji': emoji,
      'parent_id': parentId,
    };
  }
}
