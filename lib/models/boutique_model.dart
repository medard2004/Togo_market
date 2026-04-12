class Boutique {
  final dynamic id;
  final String nom;
  final String telephone;
  final List<dynamic>? contacts; // Rendu optionnel
  final String? detailsAdresse;
  final dynamic horaires; // Map ou List selon Laravel
  final double latitude;
  final double longitude;
  final String logoUrl;
  final String description;

  const Boutique({
    required this.id,
    required this.nom,
    required this.telephone,
    this.contacts,
    this.detailsAdresse,
    required this.horaires,
    required this.latitude,
    required this.longitude,
    required this.logoUrl,
    required this.description,
  });

  factory Boutique.fromJson(Map<String, dynamic> json) {
    return Boutique(
      id: json['id'],
      nom: json['nom'] ?? '',
      telephone: json['telephone'] ?? '',
      contacts: json['contacts'] is List ? json['contacts'] : (json['contacts'] != null ? [json['contacts']] : []),
      detailsAdresse: json['details_adresse'],
      horaires: json['horaires'] ?? {},
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
      logoUrl: json['logo_url'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'telephone': telephone,
      'contacts': contacts,
      'details_adresse': detailsAdresse,
      'horaires': horaires,
      'latitude': latitude,
      'longitude': longitude,
      'logo_url': logoUrl,
      'description': description,
    };
  }
}
