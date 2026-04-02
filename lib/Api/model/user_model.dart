class User {
  final int? id;
  final String? nom;
  final String? email;
  final String telephone;
  final String? avatarUrl;
  final String? role;
  final bool? actif;

  User({
    this.id,
    this.nom,
    this.email,
    required this.telephone,
    this.avatarUrl,
    this.role,
    this.actif,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nom: json['nom'],
      email: json['email'],
      telephone: json['telephone'] ?? '',
      avatarUrl: json['avatar_url'],
      role: json['role'],
      actif: json['actif'] == 1 || json['actif'] == true, // Handle boolean or tinyint
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'email': email,
      'telephone': telephone,
      'avatar_url': avatarUrl,
      'role': role,
      'actif': actif,
    };
  }

  // Helper method to copy user with new properties
  User copyWith({
    int? id,
    String? nom,
    String? email,
    String? telephone,
    String? avatarUrl,
    String? role,
    bool? actif,
  }) {
    return User(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      actif: actif ?? this.actif,
    );
  }
}
