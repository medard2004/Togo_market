class Boutique {
  final dynamic id;
  final String nom;
  final String telephone;
  final List<dynamic>? contacts; // Rendu optionnel
  final String? adresse;
  final String? detailsAdresse;
  final List<dynamic>? categories;
  final dynamic horaires; // Map ou List selon Laravel
  final double latitude;
  final double longitude;
  final String logoUrl;
  final String bannerUrl;
  final String description;
  final double noteMoyenne;

  const Boutique({
    required this.id,
    required this.nom,
    required this.telephone,
    this.contacts,
    this.adresse,
    this.detailsAdresse,
    this.categories,
    required this.horaires,
    required this.latitude,
    required this.longitude,
    required this.logoUrl,
    required this.bannerUrl,
    required this.description,
    this.noteMoyenne = 0.0,
  });

  factory Boutique.fromJson(Map<String, dynamic> json) {
    return Boutique(
      id: json['id'],
      nom: json['nom'] ?? '',
      telephone: json['telephone'] ?? '',
      contacts: json['contacts'] is List ? json['contacts'] : (json['contacts'] != null ? [json['contacts']] : []),
      adresse: json['adresse'],
      detailsAdresse: json['details_adresse'],
      categories: json['categories'] as List<dynamic>?,
      horaires: json['horaires'] ?? {},
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
      logoUrl: json['logo_url'] ?? '',
      bannerUrl: json['banner_url'] ?? '',
      description: json['description'] ?? '',
      noteMoyenne: double.tryParse(json['note_moyenne']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'telephone': telephone,
      'contacts': contacts,
      'adresse': adresse,
      'details_adresse': detailsAdresse,
      'categories': categories,
      'horaires': horaires,
      'latitude': latitude,
      'longitude': longitude,
      'logo_url': logoUrl,
      'banner_url': bannerUrl,
      'description': description,
      'note_moyenne': noteMoyenne,
    };
  }
}
