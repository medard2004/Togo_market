class Quartier {
  final int id;
  final int villeId;
  final String nom;

  Quartier({
    required this.id,
    required this.villeId,
    required this.nom,
  });

  factory Quartier.fromJson(Map<String, dynamic> json) {
    return Quartier(
      id: json['id'],
      villeId: json['ville_id'],
      nom: json['nom'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ville_id': villeId,
      'nom': nom,
    };
  }
}

class Ville {
  final int id;
  final String nom;
  final List<Quartier> quartiers;

  Ville({
    required this.id,
    required this.nom,
    required this.quartiers,
  });

  factory Ville.fromJson(Map<String, dynamic> json) {
    return Ville(
      id: json['id'],
      nom: json['nom'],
      quartiers: json['quartiers'] != null
          ? (json['quartiers'] as List)
              .map((q) => Quartier.fromJson(q))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'quartiers': quartiers.map((q) => q.toJson()).toList(),
    };
  }
}
