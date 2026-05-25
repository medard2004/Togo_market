import 'package:flutter/material.dart';

class DayOpeningHours {
  final String day;
  TimeOfDay? openingTime;
  TimeOfDay? closingTime;
  bool isOpen;
  bool isHalfDay;

  DayOpeningHours({
    required this.day,
    this.openingTime = const TimeOfDay(hour: 8, minute: 0),
    this.closingTime = const TimeOfDay(hour: 18, minute: 0),
    this.isOpen = true,
    this.isHalfDay = false,
  });
}

class StoreConfigData {
  String name = '';
  String description = '';
  String phone = '';
  List<String> secondaryPhones = [];
  int? villeId;
  int? quartierId;
  String address = '';     // Adresse libre saisie par l'utilisateur

  // Catégories sélectionnées (IDs depuis la DB)
  List<int> categoryIds = [];

  // Chemins des images locales sélectionnées
  String? logoPath;
  String? bannerPath;

  // GPS
  double? latitude;
  double? longitude;

  List<DayOpeningHours> openingHours = [
    DayOpeningHours(day: 'Lundi'),
    DayOpeningHours(day: 'Mardi'),
    DayOpeningHours(day: 'Mercredi'),
    DayOpeningHours(day: 'Jeudi'),
    DayOpeningHours(day: 'Vendredi'),
    DayOpeningHours(day: 'Samedi', isHalfDay: true, closingTime: const TimeOfDay(hour: 12, minute: 0)),
    DayOpeningHours(day: 'Dimanche', isOpen: false),
  ];

  /// Construit le payload à envoyer au BoutiqueController.createBoutique()
  Map<String, dynamic> toPayload() {
    // Construire les jours ouverts et horaires
    final List<String> joursOuverts = [];
    final dayMap = {
      'Lundi': 'Lun', 'Mardi': 'Mar', 'Mercredi': 'Mer',
      'Jeudi': 'Jeu', 'Vendredi': 'Ven', 'Samedi': 'Sam', 'Dimanche': 'Dim',
    };

    // Trouver les horaires globales (première heure d'ouverture, dernière de fermeture)
    TimeOfDay? firstOpen;
    TimeOfDay? lastClose;
    for (var h in openingHours) {
      if (h.isOpen) {
        joursOuverts.add(dayMap[h.day] ?? h.day);
        if (h.openingTime != null) {
          if (firstOpen == null ||
              h.openingTime!.hour < firstOpen.hour ||
              (h.openingTime!.hour == firstOpen.hour && h.openingTime!.minute < firstOpen.minute)) {
            firstOpen = h.openingTime;
          }
        }
        if (h.closingTime != null) {
          if (lastClose == null ||
              h.closingTime!.hour > lastClose.hour ||
              (h.closingTime!.hour == lastClose.hour && h.closingTime!.minute > lastClose.minute)) {
            lastClose = h.closingTime;
          }
        }
      }
    }

    String formatTime(TimeOfDay? t) {
      if (t == null) return '08:00';
      return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    }

    String? villeNom;
    String? quartierNom;
    
    // We can't access AuthController from here easily, so we will pass the resolved names or resolve them in the controller.
    // Or we just send the IDs if backend supports it. But backend expects 'adresse' as string.
    // We will let the UI pass the resolved string into 'adresse' or we pass it here.
    // Actually, let's keep 'adresse' as it is, but we will pass the quartierId to the payload.
    final payload = <String, dynamic>{
      'nom': name,
      'telephone': phone,
      if (secondaryPhones.isNotEmpty) 'contacts': secondaryPhones,
      'description': description.isNotEmpty ? description : null,
      'adresse': address.isNotEmpty ? address : null,
      'quartier_id': quartierId, // if the backend can accept it
      'horaires': {
        'jours': joursOuverts,
        'ouverture': formatTime(firstOpen),
        'fermeture': formatTime(lastClose),
      },
      'categories': categoryIds,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (logoPath != null) 'logoPath': logoPath,
      if (bannerPath != null) 'bannerPath': bannerPath,
    };

    return payload;
  }
}
