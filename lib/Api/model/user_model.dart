class User {
  final int? id;
  final String? nom;
  final String? email;
  final String telephone;
  final String? avatarUrl;
  final String? role;
  final bool? actif;
  final String? providerName;

  /// Premier quartier renseigné sur une adresse (profil « local » côté API).
  final int? profileQuartierId;

  /// IDs des catégories d’intérêt synchronisées avec le backend.
  final List<int> profileCategoryIds;

  User({
    this.id,
    this.nom,
    this.email,
    required this.telephone,
    this.avatarUrl,
    this.role,
    this.actif,
    this.providerName,
    this.profileQuartierId,
    this.profileCategoryIds = const [],
  });

  /// L'utilisateur s'est inscrit via un réseau social (Google, Facebook, Apple)
  bool get isSocialLogin => providerName != null && providerName!.isNotEmpty;

  /// Profil d’usage (nom, téléphone réel, zone / quartier) — aligné sur l’assistant de configuration.
  bool get needsOnboardingProfile {
    if (telephone.isEmpty || telephone.startsWith('tmp_')) return true;
    if (nom == null || nom!.trim().isEmpty) return true;
    if (profileQuartierId == null || profileQuartierId! <= 0) return true;
    return false;
  }

  static int? _firstQuartierIdFromAdresses(dynamic raw) {
    if (raw is! List || raw.isEmpty) return null;
    for (final e in raw) {
      if (e is! Map) continue;
      final v = e['quartier_id'];
      if (v == null) continue;
      final id = v is int ? v : int.tryParse(v.toString());
      if (id != null && id > 0) return id;
    }
    return null;
  }

  static List<int> _categoryIdsFromPayload(dynamic raw) {
    if (raw is! List || raw.isEmpty) return const [];
    final out = <int>[];
    for (final e in raw) {
      if (e is int && e > 0) {
        out.add(e);
      } else if (e is Map && e['id'] != null) {
        final id = e['id'] is int ? e['id'] as int : int.tryParse(e['id'].toString());
        if (id != null && id > 0) out.add(id);
      }
    }
    return out;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nom: json['nom'],
      email: json['email'],
      telephone: json['telephone'] ?? '',
      avatarUrl: json['avatar_url'],
      role: json['role'],
      actif: json['actif'] == 1 || json['actif'] == true, // Handle boolean or tinyint
      providerName: json['provider_name'],
      profileQuartierId: _firstQuartierIdFromAdresses(json['adresses']),
      profileCategoryIds: _categoryIdsFromPayload(json['categories']),
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
      'provider_name': providerName,
      'adresses': profileQuartierId != null
          ? <Map<String, dynamic>>[
              {'quartier_id': profileQuartierId},
            ]
          : <Map<String, dynamic>>[],
      'categories':
          profileCategoryIds.map((id) => <String, dynamic>{'id': id}).toList(),
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
    String? providerName,
    int? profileQuartierId,
    List<int>? profileCategoryIds,
  }) {
    return User(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      actif: actif ?? this.actif,
      providerName: providerName ?? this.providerName,
      profileQuartierId: profileQuartierId ?? this.profileQuartierId,
      profileCategoryIds: profileCategoryIds ?? this.profileCategoryIds,
    );
  }
}
